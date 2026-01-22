import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(
    String username,
    String password, {
    bool rememberMe = false,
  });
  Future<Either<Failure, User>> register(User user, String password);
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, String?>> getRememberedUsername();
}
