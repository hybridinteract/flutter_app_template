abstract final class RouteNames {
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String home = '/home';
  static const String bookings = '/bookings';
  static const String bookingDetails = '/booking-details/:id';
  static const String profile = '/profile';
  static const String settings = '/settings';

  /// Verify-code screen for [email], e.g. `/verify-email?email=a%40b.com`.
  static String verifyEmailPath(String email) =>
      Uri(path: verifyEmail, queryParameters: {'email': email}).toString();

  // Helper method to construct booking details path with ID
  static String bookingDetailsPath(String id) => '/booking-details/$id';
}
