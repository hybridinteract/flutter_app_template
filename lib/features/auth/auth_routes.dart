import 'package:app_template/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';

import 'views/login_screen.dart';
import 'views/register_screen.dart';
import 'views/verify_email_screen.dart';

/// Routes owned by the auth feature. [AuthBloc] is app-wide (see
/// `lib/app/app.dart`) because the router redirect depends on it.
abstract final class AuthRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RouteNames.verifyEmail,
      // Opened with RouteNames.verifyEmailPath(email). Without an email there
      // is nothing to verify, so send the user to sign in instead.
      redirect: (context, state) {
        final email = state.uri.queryParameters['email'];
        return email == null || email.isEmpty ? RouteNames.login : null;
      },
      builder: (context, state) =>
          VerifyEmailScreen(email: state.uri.queryParameters['email'] ?? ''),
    ),
  ];
}
