import 'package:app_template/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';

import 'views/home_screen.dart';

abstract final class HomeRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomeScreen(),
    ),
  ];
}
