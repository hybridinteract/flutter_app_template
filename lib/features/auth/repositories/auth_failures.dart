import 'package:app_template/core/error/failure.dart';

import '../models/verification_challenge_model.dart';

/// Login was refused because the email address was never verified.
///
/// The backend answers 403 for both "email not verified" and "account
/// suspended", with only the message text differing, and its own rules say
/// clients must not branch on that text. The repository tells them apart by
/// asking for a fresh code: that succeeds only for an unverified account.
/// [challenge] describes the code just sent.
class EmailNotVerifiedFailure extends Failure {
  const EmailNotVerifiedFailure({
    required this.email,
    required this.challenge,
    super.message = 'Email not verified. Check your inbox for the code.',
    super.statusCode = 403,
    super.code = 'EMAIL_NOT_VERIFIED',
  });

  final String email;
  final VerificationChallengeModel challenge;

  @override
  List<Object?> get props => [...super.props, email, challenge];
}
