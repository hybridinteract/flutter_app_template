---
name: debug-flow
description: Systematic troubleshooting runbook for API/network errors, token refresh and session expiry, BLoC state issues, GetIt registration failures, and GoRouter redirect loops.
---
# Workflow: Systematic Architecture Debugging

Reproduce first, then fix at the layer that owns the problem, then, if the bug was in logic (BLoC, repository, parsing, core), add one test that fails without the fix.

## 1. Network & API (Dio, `lib/core/network/`)
- **Symptoms**: requests failing, timeouts, wrong base URL.
- **Checklist**:
  1. `.env`: `BASE_URL` set (no trailing slash) and the app run with `--dart-define-from-file=.env`.
  2. Debug console: `--> METHOD URI` / `<-- STATUS URI` logs from `ApiInterceptor` (needs `ENABLE_LOGGING=true` and debug mode).
  3. Error mapping: status → `AppException` in `core/network/api_exception.dart`, → `Failure` in `core/error/failure.dart`.
  4. Wrong message on screen? The repository must `throw mapExceptionToFailure(e)`; the BLoC must emit `failure.message`.

## 2. Token refresh & session expiry
- **Symptoms**: 401 loops, several refresh calls, user stuck on a screen after the token expired.
- **Flow**: 401 → `ApiInterceptor.onError` (queued) → if the stored token changed, retry; else refresh once → retry. Refresh fails → tokens cleared → `SessionExpiryNotifier.notifyExpired()` → `AuthRepository.sessionExpired` → `AuthBloc` handles `SessionExpired` → `AuthUnauthenticated` → router redirects to login.
- **Checklist**:
  1. Refresh endpoint and payload keys (`access_token`/`accessToken`) in `_refreshAccessToken`.
  2. `SessionExpiryNotifier` is the same singleton in the interceptor and `AuthRepositoryImpl` (`lib/app/injection_container.dart`).
  3. Reproduce with `test/core/network/api_interceptor_test.dart` (fake server).

## 3. BLoC state
- **Symptoms**: UI not updating, events ignored, infinite loading, a screen showing another screen's state.
- **Checklist**:
  1. `AppBlocObserver` logs: `[BLOC EVENT]`, `[BLOC CHANGE]`, `[BLOC ERROR]`.
  2. Events/states extend `Equatable` with every field in `props` (identical states are not re-emitted).
  3. No `emit` after the handler finished; `await` every async call inside handlers.
  4. Shared-state bugs: a feature BLoC must be route-scoped (`BlocProvider(create: ...)` in `<feature>_routes.dart`), not provided app-wide.

## 4. Dependency injection (GetIt)
- **Symptom**: `Object/factory with type X is not registered inside GetIt`.
- **Checklist**:
  1. Registered in `lib/app/injection_container.dart`, by contract (`registerLazySingleton<XRepository>(() => XRepositoryImpl(...))`).
  2. Order: External → Storage → Core → Feature (Service → Repository → BLoC).
  3. `await setupDependencies()` finishes before `runApp` in `lib/main.dart`.
  4. In tests: register in `setUp`, `getIt.reset()` in `tearDown`.

## 5. Navigation & redirect loops (GoRouter)
- **Symptoms**: flicker between login and home, blank screen, "page not found".
- **Checklist**:
  1. Route defined in `<feature>_routes.dart` and spread into `lib/app/app_router.dart`.
  2. Path constant in `core/routes/route_names.dart` matches what views navigate to.
  3. `redirect` returns `null` when no change is needed and never returns the current location; public paths are in `_publicRoutes`.
  4. `refreshListenable: GoRouterRefreshStream(authBloc.stream)` is attached.
