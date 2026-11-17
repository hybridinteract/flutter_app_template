import 'package:app_template/core/constants/api_constants.dart';
import 'package:app_template/core/network/dio_client.dart';
import '../models/account_type.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';
import '../models/verification_challenge_model.dart';

/// Calls the Influen backend's auth endpoints (`app/iam/auth`).
///
/// The backend returns plain JSON (no `{success, data}` envelope);
/// [_payload] still unwraps `data` if one ever appears.
class AuthService {
  AuthService(this._dioClient);

  final DioClient _dioClient;

  /// `POST /auth/password/login`. A 403 here means the email is not verified
  /// or the account is suspended; the repository tells the two apart.
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return AuthSessionModel.fromJson(_payload(response.data));
  }

  /// `POST /auth/password/signup`. Returns NO tokens: the account is created
  /// unverified and a code is emailed.
  ///
  /// [organisation] is the organization name for a brand, or the social
  /// handle for a creator. The British spelling is the backend's wire name.
  Future<VerificationChallengeModel> signup({
    required AccountType accountType,
    required String fullName,
    required String email,
    required String organisation,
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.signup,
      data: {
        'account_type': accountType.apiValue,
        'full_name': fullName,
        'email': email,
        'organisation': organisation,
        'password': password,
      },
    );
    return VerificationChallengeModel.fromJson(_payload(response.data));
  }

  /// `POST /auth/password/verify-email`. Consumes the code, activates the
  /// account and signs in.
  Future<AuthSessionModel> verifyEmail({
    required String email,
    required String code,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.verifyEmail,
      data: {'email': email, 'code': code},
    );
    return AuthSessionModel.fromJson(_payload(response.data));
  }

  /// `POST /auth/password/resend-verification`. Answers 400 when the account
  /// is already verified.
  Future<VerificationChallengeModel> resendVerification({
    required String email,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.resendVerification,
      data: {'email': email},
    );
    return VerificationChallengeModel.fromJson(
      _payload(response.data),
    ).copyWith(email: email);
  }

  Future<AuthSessionModel> refreshToken(String refreshToken) async {
    final response = await _dioClient.post(
      ApiConstants.refreshToken,
      data: {'refresh_token': refreshToken},
    );
    return AuthSessionModel.fromJson(_payload(response.data));
  }

  /// Revokes the refresh token server-side. Without it the session stays
  /// alive on the backend even though the app forgot it.
  Future<void> logout({String? refreshToken}) async {
    await _dioClient.post(
      ApiConstants.logout,
      data: refreshToken != null ? {'refresh_token': refreshToken} : null,
    );
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _dioClient.get(ApiConstants.currentUser);
    return UserModel.fromJson(_payload(response.data));
  }

  static Map<String, dynamic> _payload(Object? body) {
    final data = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final nested = data['data'];
    return nested is Map<String, dynamic> ? nested : data;
  }
}
