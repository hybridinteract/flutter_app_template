import '../models/account_type.dart';
import '../models/user_model.dart';
import '../models/verification_challenge_model.dart';

abstract class AuthRepository {
  /// Signs in. Throws [EmailNotVerifiedFailure] (from `auth_failures.dart`)
  /// when the account exists but its email was never verified; a fresh code
  /// has already been sent by then.
  Future<UserModel> login({required String email, required String password});

  /// Creates an unverified account and emails a code. Does NOT sign in:
  /// call [verifyEmail] with the code next.
  Future<VerificationChallengeModel> register({
    required AccountType accountType,
    required String fullName,
    required String email,
    required String organisation,
    required String password,
  });

  /// Verifies the emailed code and signs in.
  Future<UserModel> verifyEmail({required String email, required String code});

  /// Emails a new code, retiring the previous one.
  Future<VerificationChallengeModel> resendVerification({
    required String email,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<bool> isAuthenticated();

  /// Emits when the session expired and could not be refreshed.
  Stream<void> get sessionExpired;

  /// Clears tokens, the cached user and the active workspace without calling
  /// the API.
  Future<void> clearSession();
}
