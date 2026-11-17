import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verification_challenge_model.g.dart';

/// A verification code was emailed and is waiting to be entered.
///
/// Parsed from both `POST /auth/password/signup` (which also carries `email`)
/// and `POST /auth/password/resend-verification`. Neither returns tokens: the
/// account cannot sign in until `verify-email` succeeds.
@JsonSerializable(fieldRename: FieldRename.snake)
class VerificationChallengeModel extends Equatable {
  const VerificationChallengeModel({
    this.email,
    this.expiresIn = 0,
    this.devCode,
  });

  final String? email;

  /// Seconds until the code expires.
  final int expiresIn;

  /// The code itself, returned ONLY when the backend runs with
  /// `AUTH_EXPOSE_DEV_CODES=true` (local development without a mail
  /// provider). Always null in production; the backend refuses to boot
  /// otherwise.
  final String? devCode;

  factory VerificationChallengeModel.fromJson(Map<String, dynamic> json) =>
      _$VerificationChallengeModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationChallengeModelToJson(this);

  VerificationChallengeModel copyWith({
    String? email,
    int? expiresIn,
    String? devCode,
  }) {
    return VerificationChallengeModel(
      email: email ?? this.email,
      expiresIn: expiresIn ?? this.expiresIn,
      devCode: devCode ?? this.devCode,
    );
  }

  @override
  List<Object?> get props => [email, expiresIn, devCode];
}
