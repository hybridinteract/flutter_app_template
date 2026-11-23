---
name: add-screen
description: Add a new screen or sub-view to an existing feature under lib/features/<feature>/views/, connect it to the feature BLoC, register its route in the feature's routes file, and add a widget test only if it has a form.
---
# Workflow: Add New Screen / Sub-View

## 1. Clarify
- Target feature (`lib/features/<feature>/`). If the screen needs data from another feature, stop: only `features/auth/auth.dart` may be imported across features.
- Path and parameters (e.g. `/products/:id`), and whether it is public (no login).
- Which BLoC state it observes. A new state/event goes in `controllers/` first.

## 2. Route path
- Add the constant (and a builder for parameters) to `lib/core/routes/route_names.dart`:
  ```dart
  static const String productDetails = '/products/:id';
  static String productDetailsPath(String id) => '/products/$id';
  ```

## 3. Screen
- File: `lib/features/<feature>/views/<screen_name>_screen.dart`; feature-only widgets in `views/widgets/`.
- Read the BLoC with `context.read<XBloc>()`; dispatch the initial load in `initState`.
- `BlocBuilder` / `BlocListener` / `BlocConsumer` only. No service, repository, Dio or `getIt` usage.
- Handle loading (`AppLoader`), error (`AppErrorWidget` + retry), empty (`AppEmptyWidget`) and success.
- Use `AppDimensions`, `context.colorScheme`, `context.textTheme`; no hardcoded colors/sizes; responsive via `ConstrainedBox` / `ResponsiveLayout`.
- Text: add keys to `lib/core/l10n/arb/app_en.arb` (prefixed by feature), run `flutter gen-l10n`, use `context.l10n.key`.

## 4. Register the route
- In `lib/features/<feature>/<feature>_routes.dart` add a `GoRoute` that provides a fresh BLoC:
  ```dart
  GoRoute(
    path: RouteNames.productDetails,
    builder: (context, state) => BlocProvider(
      create: (_) => getIt<ProductBloc>(),
      child: ProductDetailScreen(id: state.pathParameters['id'] ?? ''),
    ),
  ),
  ```
- Public screen? Add its path to `_publicRoutes` in `lib/app/app_router.dart`.
- Navigate to it with `context.push(RouteNames.productDetailsPath(id))`.

## 5. Widget test
- Only for a screen with a form: the two cases in `.claude/rules/testing.md` (invalid submit shows the error and dispatches nothing; valid submit dispatches the right event), in `test/features/<feature>/views/<screen_name>_screen_test.dart`.
- Give the `MaterialApp` `localizationsDelegates: appLocalizationsDelegates` and `supportedLocales: AppLocalizations.supportedLocales`.
- Wrap the screen in `BlocProvider<XBloc>.value(value: mockBloc, ...)` with `class MockXBloc extends MockBloc<XEvent, XState> implements XBloc {}`.

## 6. Verify
`flutter analyze --fatal-infos`, and `flutter test <touched test files> -r failures-only 2>&1 | tail -5` (skip if none).
