import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import 'dart:io';
import '../../../../core/services/file_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final FileStorageService fileStorageService;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.fileStorageService,
  });

  @override
  Future<Either<Failure, User>> login(
    String username,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      final user = await localDataSource.login(
        username,
        password,
        rememberMe: rememberMe,
      );
      return Right(user);
    } on LockoutException catch (e) {
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return const Left(AuthFailure());
    }
  }

  @override
  Future<Either<Failure, User>> register(User user, String password) async {
    try {
      String? persistentPath = user.profilePicturePath;
      if (persistentPath != null) {
        final file = File(persistentPath);
        if (await file.exists()) {
          persistentPath = await fileStorageService.saveFile(
            file,
            'pfp_${user.id}',
          );
        }
      }

      final updatedUser = User(
        id: user.id,
        username: user.username,
        fullName: user.fullName,
        dateOfBirth: user.dateOfBirth,
        profilePicturePath: persistentPath,
      );

      final userModel = UserModel.fromEntity(updatedUser, password);
      final createdUser = await localDataSource.register(userModel);
      return Right(createdUser);
    } on CacheException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return const Left(AuthFailure('Registration failed'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.logout();
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String?>> getRememberedUsername() async {
    try {
      final username = await localDataSource.getRememberedUsername();
      return Right(username);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }
}
