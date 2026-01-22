
import 'package:axel_todo_test/core/error/failures.dart';
import 'package:axel_todo_test/features/auth/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  Future<Either<Failure, User>> updateProfile(User user, {String? imagePath});
}
