abstract final class ApiConstants {
  static const String apiVersion = 'v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // Headers
  /// Tells the backend which brand workspace a request is about. Attached by
  /// `ApiInterceptor` from `ActiveWorkspaceStore`.
  static const String workspaceIdHeader = 'X-Workspace-Id';

  // Authentication & IAM Endpoints (Influen backend, app/iam).
  // Paths are relative to BASE_URL, which already ends in /api/v1.
  static const String login = '/auth/password/login';
  static const String signup = '/auth/password/signup';
  static const String verifyEmail = '/auth/password/verify-email';
  static const String resendVerification = '/auth/password/resend-verification';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';
  static const String refreshToken = '/auth/refresh';
  static const String currentUser = '/auth/me';

  // Workspaces (app/organization). These two answer "which workspaces do I
  // have?", so the backend ignores X-Workspace-Id on them; the interceptor
  // does not send it there.
  static const String workspaces = '/workspaces';
  static const String workspaceOptions = '/workspaces/options';

  // Feature Endpoints
  static const String bookings = '/bookings';
  static const String bookingDetails = '/bookings'; // + '/{id}'
}
