# Architectural Decisions Log (ADR)

## ADR-001: Modular MVC + Clean Architecture Principles
- **Context**: Need a scalable, maintainable architecture for Flutter applications that balances simplicity with testability.
- **Decision**: Adopt a Modular MVC structure guided by Clean Architecture layer boundaries: `View -> BLoC (Controller) -> Repository -> Service`.
- **Consequences**: Clear separation of concerns, no layer skipping, predictable data flow, and isolated unit testing.
- **Update**: Folder layout superseded by ADR-008 (feature-first); the layer flow is unchanged.

## ADR-002: State Management via flutter_bloc and equatable
- **Context**: State management must be predictable, testable, and strictly decoupled from the UI.
- **Decision**: Use `flutter_bloc` combined with `equatable`. Standardize feature states into `Initial`, `Loading`, `Success`, `Failure`.
- **Consequences**: Reactive UI updates, easy mockability in unit tests with `bloc_test`, and no UI imports in business logic.

## ADR-003: Centralized Networking with Dio & Custom Interceptors
- **Context**: HTTP communication requires token injection, token refresh, logging, and error transformation.
- **Decision**: Centralize all HTTP calls through a singleton `DioClient` with `ApiInterceptor`.
- **Consequences**: Sensitive parameters (passwords, tokens) are consistently sanitized. HTTP status codes (400, 401, 403, 404, 422, 429, 500, 503) are mapped deterministically.

## ADR-004: Dependency Injection via GetIt
- **Context**: Need inversion of control and loose coupling between layers.
- **Decision**: Use `get_it` with `registerLazySingleton` for clients, services, and repositories, and `registerFactory` for BLoCs.
- **Consequences**: Centralized dependency graph initialized before `runApp`. Trivial mocking during widget and integration tests.

## ADR-005: Declarative Routing with GoRouter
- **Context**: Multiplatform support, deep links, and auth-state redirection are required.
- **Decision**: Use `go_router` with path constants in `core/routes/route_names.dart` and redirection based on `AuthBloc` states. (Route definitions moved to each feature by ADR-008.)
- **Consequences**: Navigation is decoupled from UI widget hierarchy, route transitions are declarative, and unauthorized access is blocked at the router boundary.

## ADR-006: Local Storage Separation
- **Context**: Need distinct handling for non-sensitive preferences vs. sensitive tokens.
- **Decision**: Use `shared_preferences` for theme, language, and onboarding flags; use `flutter_secure_storage` for access/refresh tokens.
- **Consequences**: Sensitive tokens are encrypted using platform secure keychains/keystores, preventing leakage.

## ADR-007: Domain Failures vs. Raw Exceptions
- **Context**: Raw network or platform exceptions must never reach the user interface.
- **Decision**: Repositories catch all exceptions and translate them into typed, user-friendly `Failure` objects (`NetworkFailure`, `AuthFailure`, `ValidationFailure`, `ServerFailure`).
- **Consequences**: Clean UI error handling; technical details remain in crash logs while users receive actionable messages.

## ADR-008: Feature-First Folder Structure
- **Date**: 16 November 2026
- **Context**: The v1.0 layer-first layout (`lib/controllers/`, `lib/models/`, `lib/views/`...) spread one feature over five folders, made "features do not import each other" impossible to check, and let `core/` import feature code (router, `PermissionGuard`, context extensions).
- **Decision**: Group code by feature under `lib/features/<feature>/{models,services,repositories,controllers,views}` with a `<feature>_routes.dart`. Add `lib/app/` as the composition root (root widget, router, DI). Keep `lib/core/` feature-agnostic.
- **Consequences**: A feature can be added, reviewed or deleted as one folder. Import boundaries are enforced automatically by `tool/check_architecture.dart`. `test/` mirrors `lib/`.

## ADR-009: Auth Is the Only Shared Feature
- **Context**: Several features (home, profile, any permission-gated UI) need the signed-in user, which belongs to `auth`.
- **Decision**: `features/auth/auth.dart` is a public API (BLoC, events, states, `UserModel`, `PermissionGuard`, permission helpers). It is the only cross-feature import allowed. Everything else shared moves to `core/`.
- **Consequences**: One documented, checkable exception instead of ad-hoc cross-feature imports.

## ADR-010: Route-Scoped BLoCs
- **Context**: `BookingBloc` was provided app-wide; opening a booking's details replaced the list state, so going back showed an empty list.
- **Decision**: Feature BLoCs are created per route in `<feature>_routes.dart` (`BlocProvider(create: (_) => getIt<XBloc>())`, registered with `registerFactory`). Only BLoCs the whole app depends on (`AuthBloc`) are provided in `lib/app/app.dart`.
- **Consequences**: No state leaking between screens; BLoCs are closed automatically when their route is popped.

## ADR-011: No Mandatory Use-Case Layer
- **Context**: Full Clean Architecture adds entities, use cases and data sources per feature. For typical client apps most use cases only forward one repository call.
- **Decision**: Keep repository contracts, typed `Failure`s and DI; do not require `domain/`, entities or use cases. A feature may add `usecases/` when logic combines several repositories or holds real business rules.
- **Consequences**: About half the boilerplate per feature, with the same testability.

## ADR-012: Session Expiry via SessionExpiryNotifier
- **Context**: The network layer (core) detects an unrecoverable 401 but must not import the auth feature; previously the `onUnauthorized` callback was empty, so users stayed "logged in" after tokens were cleared.
- **Decision**: `core/session/SessionExpiryNotifier` broadcasts expiry. `ApiInterceptor` (now a `QueuedInterceptor` that refreshes once for concurrent 401s) reports to it; `AuthRepository.sessionExpired` exposes it and `AuthBloc` signs out.
- **Consequences**: Correct logout on expiry with no core → feature dependency; covered by `test/core/network/api_interceptor_test.dart` and the auth tests.

## ADR-013: Localization with gen-l10n
- **Date**: 17 November 2026
- **Context**: About 60 user-facing strings were hardcoded in views, core widgets and the router, breaking rule 10, and the settings screen already offers a language option.
- **Decision**: Use Flutter's official gen-l10n. All UI text lives in `lib/core/l10n/arb/app_en.arb` (keys prefixed by feature); views read `context.l10n.key`. `Validators` stay pure Dart with English defaults and accept localized messages. `Failure` messages stay English in core; views can map `failure.code` to l10n keys when an app needs localized errors.
- **Consequences**: Adding a language is one ARB file and no code changes. Widget tests must register the localization delegates. Generated files are committed and checked in CI.

## ADR-014: Generated Code Is Never Hand-Edited
- **Date**: 17 November 2026
- **Context**: `user_model.g.dart` and `auth_session_model.g.dart` had been edited by hand (snake_case keys, `created_at` fallback, nested `toJson`). Running build_runner would have silently changed the API payloads.
- **Decision**: Express JSON behavior in annotations (`fieldRename: FieldRename.snake`, `explicitToJson: true`, `readValue`). Lock the backend contract with `json_contract_test.dart`. CI regenerates code and fails on any diff.
- **Consequences**: `build_runner` is safe to run at any time.

## ADR-015: Material via material_ui on Flutter 3.47+
- **Date**: 17 November 2026
- **Context**: Flutter 3.47 deprecated `package:flutter/material.dart` and `flutter/cupertino.dart` in favor of the `material_ui` and `cupertino_ui` packages, which define their own `MaterialApp`, `Theme` and `MaterialLocalizations` types. `flutter analyze --fatal-infos` failed on every import. gen-l10n (Flutter 3.50) still emits the old `flutter_localizations` Material/Cupertino delegates.
- **Decision**: Import `material_ui` / `cupertino_ui` everywhere. Upgrade `go_router` to 18 and `cached_network_image` to 4, which use `material_ui`, so no widget mixes the two type sets. Every `MaterialApp` uses `appLocalizationsDelegates` from `core/l10n/l10n.dart` instead of `AppLocalizations.localizationsDelegates`; `lib/core/l10n/generated/` is excluded from analysis. Minimum SDK is Flutter 3.47 / Dart 3.13.
- **Consequences**: Analysis is clean on current Flutter. A package still on `flutter/material.dart` can miss our `Theme`/localizations; check a new UI package's dependencies before adding it. go_router 15+ matches URLs case-sensitively (all `RouteNames` paths are lowercase).
