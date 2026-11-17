import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/routes/go_router_refresh_stream.dart';
import 'package:app_template/core/routes/route_names.dart';
import 'package:app_template/core/widgets/app_error_widget.dart';
import 'package:app_template/features/auth/auth.dart';
import 'package:app_template/features/auth/auth_routes.dart';
import 'package:app_template/features/booking/booking_routes.dart';
import 'package:app_template/features/home/home_routes.dart';
import 'package:app_template/features/profile/profile_routes.dart';
import 'package:app_template/features/settings/settings_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Assembles every feature's routes into one [GoRouter] and applies the
/// auth redirect. Features define their own routes in `<feature>_routes.dart`;
/// path constants live in `core/routes/route_names.dart`.
abstract final class AppRouter {
  static const Set<String> _publicRoutes = {
    RouteNames.login,
    RouteNames.register,
    RouteNames.verifyEmail,
  };

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: RouteNames.home,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final isAuthenticated = authBloc.state is AuthSuccess;
        final isPublicRoute = _publicRoutes.contains(state.matchedLocation);

        if (!isAuthenticated && !isPublicRoute) return RouteNames.login;
        if (isAuthenticated && isPublicRoute) return RouteNames.home;
        return null;
      },
      routes: [
        ...AuthRoutes.routes,
        ...HomeRoutes.routes,
        ...BookingRoutes.routes,
        ...ProfileRoutes.routes,
        ...SettingsRoutes.routes,
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.errorTitle)),
        body: AppErrorWidget(
          title: context.l10n.errorPageNotFoundTitle,
          message: context.l10n.errorPageNotFoundMessage(state.uri.toString()),
          onRetry: () => context.go(RouteNames.home),
          retryText: context.l10n.errorBackToHome,
        ),
      ),
    );
  }
}
