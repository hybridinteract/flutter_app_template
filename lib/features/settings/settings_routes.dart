import 'package:app_template/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';

import 'views/settings_screen.dart';

abstract final class SettingsRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: RouteNames.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ];
}
