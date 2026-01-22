import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUser implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(
      params.username,
      params.password,
      rememberMe: params.rememberMe,
    );
  }
}

class LoginParams extends Equatable {
  final String username;
  final String password;
  final bool rememberMe;

  const LoginParams({
    required this.username,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object> get props => [username, password, rememberMe];
}

class RegisterUser implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(params.user, params.password);
  }
}

class RegisterParams extends Equatable {
  final User user;
  final String password;

  const RegisterParams({required this.user, required this.password});

  @override
  List<Object> get props => [user, password];
}

class GetCurrentUser implements UseCase<User?, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}

class LogoutUser implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUser(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}

class GetRememberedUser implements UseCase<String?, NoParams> {
  final AuthRepository repository;

  GetRememberedUser(this.repository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    return await repository.getRememberedUsername();
  }
}
