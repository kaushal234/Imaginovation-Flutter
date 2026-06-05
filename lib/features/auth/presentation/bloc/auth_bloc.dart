import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:imaginovation_app/core/usecase/usecase.dart';
import 'package:imaginovation_app/features/auth/domain/entities/user.dart';
import 'package:imaginovation_app/features/auth/domain/usecases/check_auth_status.dart';
import 'package:imaginovation_app/features/auth/domain/usecases/login.dart';
import 'package:imaginovation_app/features/auth/domain/usecases/logout.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required Login login,
    required Logout logout,
    required CheckAuthStatus checkAuthStatus,
  })  : _login = login,
        _logout = logout,
        _checkAuthStatus = checkAuthStatus,
        super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final Login _login;
  final Logout _logout;
  final CheckAuthStatus _checkAuthStatus;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final authenticated = await _checkAuthStatus();
    emit(
      state.copyWith(
        status: authenticated
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
      ),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _login(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: failure.firstError() ?? failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isSubmitting: false,
        ),
      ),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout(const NoParams());
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
