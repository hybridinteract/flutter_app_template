import 'dart:async';

import 'package:app_template/core/error/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/auth_failures.dart';
import '../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<VerifyEmailRequested>(_onVerifyEmailRequested);
    on<ResendVerificationRequested>(_onResendVerificationRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SessionExpired>(_onSessionExpired);

    _sessionExpiredSubscription = _authRepository.sessionExpired.listen(
      (_) => add(const SessionExpired()),
    );
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<void> _sessionExpiredSubscription;

  @override
  Future<void> close() async {
    await _sessionExpiredSubscription.cancel();
    return super.close();
  }

  Future<void> _onSessionExpired(
    SessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthUnauthenticated) return;
    try {
      await _authRepository.clearSession();
    } on Failure {
      // Tokens were already cleared by the interceptor; signing out locally
      // must still happen, so a failed cache clear is not surfaced.
    }
    emit(const AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthSuccess(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } on Failure catch (failure) {
      emit(AuthFailure(message: failure.message));
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthSuccess(user: user));
    } on EmailNotVerifiedFailure catch (failure) {
      emit(
        AuthVerificationRequired(
          email: failure.email,
          devCode: failure.challenge.devCode,
          message: failure.message,
        ),
      );
    } on Failure catch (failure) {
      emit(AuthFailure(message: failure.message));
    } catch (e) {
      emit(const AuthFailure(message: 'Login failed. Please try again.'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final challenge = await _authRepository.register(
        accountType: event.accountType,
        fullName: event.fullName,
        email: event.email,
        organisation: event.organisation,
        password: event.password,
      );
      emit(
        AuthVerificationRequired(
          email: challenge.email ?? event.email,
          devCode: challenge.devCode,
        ),
      );
    } on Failure catch (failure) {
      emit(AuthFailure(message: failure.message));
    } catch (e) {
      emit(
        const AuthFailure(message: 'Registration failed. Please try again.'),
      );
    }
  }

  Future<void> _onVerifyEmailRequested(
    VerifyEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.verifyEmail(
        email: event.email,
        code: event.code,
      );
      emit(AuthSuccess(user: user));
    } on Failure catch (failure) {
      emit(AuthFailure(message: failure.message));
    } catch (e) {
      emit(
        const AuthFailure(message: 'Verification failed. Please try again.'),
      );
    }
  }

  Future<void> _onResendVerificationRequested(
    ResendVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final challenge = await _authRepository.resendVerification(
        email: event.email,
      );
      emit(
        AuthVerificationCodeResent(
          email: event.email,
          devCode: challenge.devCode,
        ),
      );
    } on Failure catch (failure) {
      emit(AuthFailure(message: failure.message));
    } catch (e) {
      emit(
        const AuthFailure(
          message: 'Could not send a new code. Please try again.',
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    } on Failure catch (failure) {
      emit(AuthFailure(message: failure.message));
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }
}
