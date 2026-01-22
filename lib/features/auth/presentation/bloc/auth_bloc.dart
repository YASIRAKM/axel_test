import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final GetCurrentUser getCurrentUser;
  final LogoutUser logoutUser;
  final GetRememberedUser getRememberedUser;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.getCurrentUser,
    required this.logoutUser,
    required this.getRememberedUser,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthToggleRememberMe>(_onAuthToggleRememberMe);
    on<AuthLoadRememberedUser>(_onAuthLoadRememberedUser);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await getCurrentUser(NoParams());

    await result.fold(
      (failure) async {
        add(AuthLoadRememberedUser());
        emit(const AuthUnauthenticated());
      },
      (user) async {
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          add(AuthLoadRememberedUser());
        }
      },
    );
  }

  Future<void> _onAuthLoadRememberedUser(
    AuthLoadRememberedUser event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getRememberedUser(NoParams());
    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (username) => emit(
        AuthUnauthenticated(rememberMe: username != null, username: username),
      ),
    );
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(rememberMe: event.rememberMe));
    final result = await loginUser(
      LoginParams(
        username: event.username,
        password: event.password,
        rememberMe: event.rememberMe,
      ),
    );
    emit(
      result.fold(
        (failure) =>
            AuthError(message: failure.message, rememberMe: event.rememberMe),
        (user) => AuthAuthenticated(user: user),
      ),
    );
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await registerUser(
      RegisterParams(user: event.user, password: event.password),
    );
    emit(
      result.fold(
        (failure) => AuthError(message: failure.message),
        (user) => AuthAuthenticated(user: user),
      ),
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await logoutUser(NoParams());
    add(AuthLoadRememberedUser());
  }

  void _onAuthToggleRememberMe(
    AuthToggleRememberMe event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthUnauthenticated) {
      final currentState = state as AuthUnauthenticated;
      emit(
        AuthUnauthenticated(
          rememberMe: !currentState.rememberMe,
          username: currentState.username,
        ),
      );
    } else if (state is AuthError) {
      final currentState = state as AuthError;
      emit(
        AuthError(
          message: currentState.message,
          rememberMe: !currentState.rememberMe,
        ),
      );
    }
  }
}
