import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/services/file_storage_service.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final AuthLocalDataSource authLocalDataSource;
  final FileStorageService fileStorageService;

  ProfileRepositoryImpl({
    required this.authLocalDataSource,
    required this.fileStorageService,
  });

  @override
  Future<Either<Failure, User>> updateProfile(
    User user, {
    String? imagePath,
  }) async {
    try {
      final currentUserModel = await authLocalDataSource.getCurrentUser();
      if (currentUserModel == null) {
        return const Left(CacheFailure('User not logged in'));
      }

      if (currentUserModel.id != user.id) {
        return const Left(CacheFailure('User mismatch'));
      }

      String? finalImagePath = user.profilePicturePath;

      if (imagePath != null) {
        if (currentUserModel.profilePicturePath != null) {
          await fileStorageService.deleteFile(
            currentUserModel.profilePicturePath!,
          );
        }

        final file = File(imagePath);
        if (await file.exists()) {
          finalImagePath = await fileStorageService.saveFile(
            file,
            'pfp_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
          );
        }
      }

      final updatedModel = UserModel(
        id: user.id,
        username: user.username,
        fullName: user.fullName,
        profilePicturePath: finalImagePath,
        dateOfBirth: user.dateOfBirth,
        password: currentUserModel.password,
        failedAttempts: currentUserModel.failedAttempts,
        lockoutUntil: currentUserModel.lockoutUntil,
      );

      await authLocalDataSource.updateUser(updatedModel);
      return Right(updatedModel);
    } catch (e) {
      return const Left(CacheFailure('Failed to update profile'));
    }
  }
}
