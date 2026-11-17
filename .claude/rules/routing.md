---
paths:
  - "lib/app/app_router.dart"
  - "lib/core/routes/**"
  - "lib/features/**/*_routes.dart"
---
# Routing Rules

- Path constants (and path builders such as `bookingDetailsPath(id)`) live only in `core/routes/route_names.dart`.
- Each feature defines its routes in `lib/features/<feature>/<feature>_routes.dart` as `abstract final class <Feature>Routes { static List<RouteBase> get routes => [...]; }`.
- `lib/app/app_router.dart` spreads every feature's routes into one `GoRouter` and owns the auth `redirect`. Add new public (no-login) paths to `_publicRoutes` there.
- Route-scoped BLoCs are created in the route builder: `BlocProvider(create: (_) => getIt<XBloc>(), child: const XScreen())`.
- The redirect returns `null` when no change is needed and never returns the current location (prevents loops). `refreshListenable` uses `GoRouterRefreshStream(authBloc.stream)`.
- Views navigate with `context.go` / `context.push` + `RouteNames`; no `Navigator.push` with screen instances.
