---
paths:
  - "lib/app/app_router.dart"
  - "lib/core/routes/**"
  - "lib/features/**/*_routes.dart"
---
# Routing Rules

- Path constants (and path builders such as `productDetailsPath(id)`) live only in `core/routes/route_names.dart`.
- Each feature defines its routes in `lib/features/<feature>/<feature>_routes.dart` as `abstract final class <Feature>Routes { static List<RouteBase> get routes => [...]; }`.
- `lib/app/app_router.dart` spreads every feature's routes into one `GoRouter` and owns the auth `redirect`. Add new public (no-login) paths to `_publicRoutes` there.
- Route-scoped BLoCs are created in the route builder: `BlocProvider(create: (_) => getIt<XBloc>(), child: const XScreen())`.
- The redirect returns `null` when no change is needed and never returns the current location (prevents loops). `refreshListenable` uses `GoRouterRefreshStream(authBloc.stream)`.
- Views navigate with `context.go` / `context.push` + `RouteNames`; no `Navigator.push` with screen instances.

## Pattern: list → detail with a path parameter
Each route creates its own BLoC (registered with `registerFactory`), so opening the detail screen never overwrites the list's state, and each BLoC closes when its route is popped.
```dart
// core/routes/route_names.dart
static const String products = '/products';
static const String productDetails = '/products/:id';
static String productDetailsPath(String id) => '/products/$id';

// features/product/product_routes.dart
abstract final class ProductRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: RouteNames.products,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<ProductBloc>(),
        child: const ProductScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.productDetails,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<ProductBloc>(),
        child: ProductDetailScreen(id: state.pathParameters['id'] ?? ''),
      ),
    ),
  ];
}

// In the list view: context.push(RouteNames.productDetailsPath(product.id));
// The screen dispatches its own load event in initState, e.g.
// context.read<ProductBloc>().add(ProductDetailsRequested(widget.id));
```
- Test it with a route test (`<feature>_routes_test.dart`): push the detail path, pop, and assert the list is still shown and the factory ran twice (see the write-tests skill).
