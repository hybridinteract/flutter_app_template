---
paths:
  - "lib/app/injection_container.dart"
  - "lib/core/di/**"
  - "lib/features/**/*_routes.dart"
---
# Dependency Injection Rules

- `getIt` is defined in `core/di/service_locator.dart`; every registration lives in `lib/app/injection_container.dart` and runs before `runApp`.
- Registration order: External → Storage → Core (crash reporting, session, network) → one block per feature (Service → Repository → BLoC), each under a `// ─── Feature: <name>` header.
- `registerLazySingleton` for clients, services, repositories and core singletons.
- `registerFactory` for BLoCs, so every route or test gets a fresh instance.
- Register repositories by their contract: `registerLazySingleton<XRepository>(() => XRepositoryImpl(...))`.
- Resolve with `getIt<T>()` only in composition code: `lib/main.dart`, `lib/app/` and `<feature>_routes.dart`. Views, BLoCs, repositories and services receive dependencies through their constructors.
- Never instantiate services or repositories manually (`XService(...)`) outside `injection_container.dart` and tests.
