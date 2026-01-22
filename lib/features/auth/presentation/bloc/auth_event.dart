part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;
  final bool rememberMe;

  const AuthLoginRequested({
    required this.username,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object> get props => [username, password, rememberMe];
}

class AuthRegisterRequested extends AuthEvent {
  final User user;
  final String password;

  const AuthRegisterRequested({required this.user, required this.password});

  @override
  List<Object> get props => [user, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthToggleRememberMe extends AuthEvent {}

class AuthLoadRememberedUser extends AuthEvent {}
