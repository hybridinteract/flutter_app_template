import 'package:equatable/equatable.dart';
import '../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess({required this.user});

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// The account exists but its email is unverified, and a code was just
/// emailed: after signup, or after a login refused for that reason. The
/// screen that triggered it opens the verify-code screen.
class AuthVerificationRequired extends AuthState {
  const AuthVerificationRequired({
    required this.email,
    this.devCode,
    this.message,
  });

  final String email;

  /// Present only against a local backend with `AUTH_EXPOSE_DEV_CODES=true`.
  final String? devCode;

  /// Server text to show, e.g. why a login was refused. Null after signup.
  final String? message;

  @override
  List<Object?> get props => [email, devCode, message];
}

/// A new code was emailed from the verify-code screen. Distinct from
/// [AuthVerificationRequired] so screens further down the stack do not open
/// the verify screen a second time.
class AuthVerificationCodeResent extends AuthState {
  const AuthVerificationCodeResent({required this.email, this.devCode});

  final String email;
  final String? devCode;

  @override
  List<Object?> get props => [email, devCode];
}

class AuthFailure extends AuthState {
  const AuthFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
