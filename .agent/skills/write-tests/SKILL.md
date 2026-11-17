---
name: write-tests
description: Generate unit tests (BLoC, repository, service, model, core) and widget/route tests that mirror lib/ under test/, using bloc_test and mocktail conventions.
---
# Workflow: Write Tests for Architecture Layers

## Location
`test/` mirrors `lib/`:
| Source | Test |
|---|---|
| `lib/features/<f>/controllers/<f>_bloc.dart` | `test/features/<f>/controllers/<f>_bloc_test.dart` |
| `lib/features/<f>/repositories/<f>_repository_impl.dart` | `test/features/<f>/repositories/<f>_repository_test.dart` |
| `lib/features/<f>/models/<m>_model.dart` | `test/features/<f>/models/<m>_model_test.dart` |
| `lib/features/<f>/views/<s>_screen.dart` | `test/features/<f>/views/<s>_screen_test.dart` |
| `lib/features/<f>/<f>_routes.dart` | `test/features/<f>/<f>_routes_test.dart` |
| `lib/core/<area>/<file>.dart` | `test/core/<area>/<file>_test.dart` |

Reference tests: `test/features/booking/` and `test/core/network/api_interceptor_test.dart`.

## 1. BLoC (`bloc_test` + `mocktail`)
- `class MockXRepository extends Mock implements XRepository {}` (mock the contract).
- Cases: initial state; per event `[Loading, Success]` and, with the repository throwing a `Failure`, `[Loading, Failure(message)]`.
- Mocking `AuthRepository`? Stub `sessionExpired` in `setUp` (`thenAnswer((_) => const Stream.empty())` or a `StreamController`), because `AuthBloc` subscribes in its constructor.
- Use `seed:` to start from a given state.

## 2. Repository (`mocktail`)
- Mock the service and storage (`MockXService`, `MockSecureStorage`, `MockLocalStorage`).
- Cases: success (data returned, storage writes verified with `verify(...).called(1)`); service throws `DioException` / `Exception` → `throwsA(isA<Failure>())`; the failure message never contains raw exception text.

## 3. Model
- Equality, `fromJson`, `toJson`, `copyWith`, and any `readValue` fallbacks (e.g. `full_name` vs `name`).

## 4. Widget (screen)
- `class MockXBloc extends MockBloc<XEvent, XState> implements XBloc {}`; wrap with `BlocProvider<XBloc>.value`.
- The `MaterialApp` needs `localizationsDelegates: AppLocalizations.localizationsDelegates` and `supportedLocales: AppLocalizations.supportedLocales` (from `core/l10n/l10n.dart`).
- Cases: loading shows `AppLoader` (use `tester.pump()`, not `pumpAndSettle()`, because it animates); success shows content; error shows `AppErrorWidget` and retry dispatches the event; forms show validation errors.

## 5. Routes
- Register real or mock dependencies in `getIt` in `setUp`; call `getIt.reset()` in `tearDown`.
- Build `GoRouter(routes: XRoutes.routes)` and drive it with `router.push` / `router.pop`.

## 6. Network / core
- Call `AppConfig.initialize(baseUrl: ..., enableLogging: false)` in `setUpAll` when the code reads `AppConfig`.
- Never call the real network: use a fake `HttpClientAdapter`.

## Verify
`flutter test <path_to_test>` then the full `flutter test`.
