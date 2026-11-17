import 'package:equatable/equatable.dart';

import '../models/account_type.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusRequested extends AuthEvent {
  const CheckAuthStatusRequested();
}

class LoginRequested extends AuthEvent {
  const LoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  const RegisterRequested({
    required this.accountType,
    required this.fullName,
    required this.email,
    required this.organisation,
    required this.password,
  });

  final AccountType accountType;
  final String fullName;
  final String email;

  /// Organization name for a brand, social handle for a creator.
  final String organisation;
  final String password;

  @override
  List<Object?> get props => [
    accountType,
    fullName,
    email,
    organisation,
    password,
  ];
}

class VerifyEmailRequested extends AuthEvent {
  const VerifyEmailRequested({required this.email, required this.code});

  final String email;
  final String code;

  @override
  List<Object?> get props => [email, code];
}

class ResendVerificationRequested extends AuthEvent {
  const ResendVerificationRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Dispatched internally when the network layer reports that the session can
/// no longer be refreshed.
class SessionExpired extends AuthEvent {
  const SessionExpired();
}
