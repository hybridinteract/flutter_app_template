abstract final class AppConstants {
  static const String appName = 'App Template';
  static const String appVersion = '1.0.0';
  static const int defaultPageSize = 20;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  // Signup and verification limits, mirroring the backend's schemas
  // (app/iam/auth/schemas.py) so the form catches them before the request.
  static const int minFullNameLength = 2;
  static const int maxFullNameLength = 100;
  static const int minOrganisationLength = 2;
  static const int maxOrganisationLength = 160;
  static const int minVerificationCodeLength = 4;
  static const int maxVerificationCodeLength = 12;
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int sendTimeoutSeconds = 30;

  /// Wait after the last keystroke before searching (see `Debouncer`).
  static const Duration searchDebounce = Duration(milliseconds: 400);
}
