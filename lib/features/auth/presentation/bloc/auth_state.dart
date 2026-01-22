part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final bool rememberMe;

  const AuthLoading({this.rememberMe = false});

  @override
  List<Object> get props => [rememberMe];
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  final bool rememberMe;
  final String? username;

  const AuthUnauthenticated({this.rememberMe = false, this.username});

  @override
  List<Object> get props => [rememberMe, if (username != null) username!];
}

class AuthError extends AuthState {
  final String message;
  final bool rememberMe;

  const AuthError({required this.message, this.rememberMe = false});

  @override
  List<Object> get props => [message, rememberMe];
}
