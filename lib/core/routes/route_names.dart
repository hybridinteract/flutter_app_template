abstract final class RouteNames {
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String home = '/home';

  /// Verify-code screen for [email], e.g. `/verify-email?email=a%40b.com`.
  static String verifyEmailPath(String email) =>
      Uri(path: verifyEmail, queryParameters: {'email': email}).toString();
}
