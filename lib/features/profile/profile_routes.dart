import 'package:app_template/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';

import 'views/profile_screen.dart';

abstract final class ProfileRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: RouteNames.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
  ];
}
