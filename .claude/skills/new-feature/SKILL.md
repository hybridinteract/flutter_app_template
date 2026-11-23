---
name: new-feature
description: Scaffold a new feature module under lib/features/<feature>/ (model, service, repository, BLoC, views, routes, DI, minimum tests) following the modular architecture. Use when adding a feature.
---
# Workflow: Scaffold New Feature Module

Reference implementation for the full stack (model → service → repository → BLoC → views → tests): `lib/features/auth/` and `test/features/auth/`. Auth is app-wide; a new feature's BLoC is route-scoped (step 2). For list → detail screens with a path parameter, copy the pattern in `.claude/rules/routing.md`; for paginated lists use `AppPaginatedList` (its doc comment has a full example).
Read `docs/ARCHITECTURE.md` first if you have not this session.

## 0. Clarify
- Feature name (`snake_case`, singular, e.g. `product`), base route, endpoints, model fields, screens.
- Does it need the signed-in user? Then import only `package:app_template/features/auth/auth.dart`.
- Does it need any other feature's code? Stop: move that code to `core/` instead.

## 1. Constants (`lib/core/`)
- Endpoints → `core/constants/api_constants.dart`.
- Route paths (+ builders for params, e.g. `productDetailsPath(id)`) → `core/routes/route_names.dart`.
- Storage keys / assets → `core/constants/storage_keys.dart` / `app_assets.dart`.
- UI text → `core/l10n/arb/app_en.arb` with keys prefixed by the feature (`product*`), then `flutter gen-l10n`.

## 2. Files (`lib/features/<feature>/`)
```
<feature>/
├── models/<feature>_model.dart              # @JsonSerializable + Equatable + copyWith
├── services/<feature>_service.dart          # DioClient calls only, returns models
├── repositories/<feature>_repository.dart   # abstract contract
├── repositories/<feature>_repository_impl.dart  # try/catch → mapExceptionToFailure
├── controllers/<feature>_event.dart
├── controllers/<feature>_state.dart         # Initial, Loading, Success, Failure
├── controllers/<feature>_bloc.dart          # depends on the repository contract only
├── views/<feature>_screen.dart              # handles loading/error/empty/success
├── views/widgets/                           # feature-only widgets
└── <feature>_routes.dart                    # <Feature>Routes.routes
```
- Imports inside the feature are relative; everything else uses `package:app_template/...`.
- Route file: provide the BLoC per route:
  ```dart
  GoRoute(
    path: RouteNames.products,
    builder: (context, state) => BlocProvider(
      create: (_) => getIt<ProductBloc>(),
      child: const ProductScreen(),
    ),
  ),
  ```

## 3. Wire up (`lib/app/`)
- `injection_container.dart`: add a `// ─── Feature: <feature>` block: Service (`registerLazySingleton`) → Repository by contract (`registerLazySingleton<XRepository>`) → BLoC (`registerFactory`).
- `app_router.dart`: add `...<Feature>Routes.routes` to `routes`. If the route must work without login, add it to `_publicRoutes`.

## 4. Generate code
`dart run build_runner build`

## 5. Tests (mirror `lib/` under `test/features/<feature>/`)
Only the minimum in `.claude/rules/testing.md` (write-tests skill): BLoC main event success + failure; repository, models and forms only where they hold logic.

## 6. Verify
Run the `code-quality-check` skill. Done means: analyze 0 issues, all tests pass, architecture audit clean.
