---
paths:
  - "test/**"
---
# Testing Rules

Test logic that can break, nothing else. This file is the only place that says what to test; skills and other rules point here. When in doubt, do not write the test.

## When to write tests
- Only when the change adds or changes logic (a BLoC handler, repository mapping, parsing fallback, validator, formatter).
- UI-only, copy, styling, layout, routing, DI and refactor-only changes add no tests; just keep existing tests passing.
- Budget: a change rarely needs more than 4 new cases. Past 6, you are over-testing: cut back.
- Fix tests your change breaks; do not add cases to a file just because you touched its code.

## The minimum
- **BLoC**: success and failure for its main repository event (load or submit). Other events only if they hold logic the UI relies on (pagination merge, optimistic update, local validation). Refresh, reset, retry, select and toggle events need none.
- **Repository**: only a status code mapped to a specific `Failure`, or a storage/session write. One case per branch. Pass-through methods need none.
- **Model**: only custom parsing (`readValue` fallbacks, unknown-enum defaults) and getters that branch. One case each. Plain fields, `toJson`, equality and `copyWith` need none. `json_contract_test.dart` changes only when the backend shape changes.
- **Screen / form widget**: only forms. Two cases: invalid submit shows the error and dispatches nothing; valid submit dispatches the right event.
- **core/**: logic only (validators, formatters, network, storage, session).

## Do not test
- Static text, layout, styling, theme values, constants, generated code, DI wiring, routes, navigation, Flutter or package behaviour.
- Edge-case extras: stale responses, double taps, retries, loading-more failures, equality, round-trips.
- The same rule twice: a validator covered in `validators_test.dart` is not re-tested in a screen.

## Running (time and tokens)
- While working, run only the touched test files, failures only: `flutter test <files> -r failures-only 2>&1 | tail -5`.
- On a failure, re-run that one test with `--plain-name "<name>"` to read its error.
- The full suite runs once, in the code-quality-check skill, before finishing. Never run it repeatedly.

## Conventions
- `test/` mirrors `lib/`: `lib/features/auth/controllers/auth_bloc.dart` → `test/features/auth/controllers/auth_bloc_test.dart`. Reference: `test/features/auth/`.
- Tools: `flutter_test`, `bloc_test` (`blocTest`, `MockBloc`) and `mocktail`. Mock contracts, not implementations: `class MockXRepository extends Mock implements XRepository {}`.
- Mocks of `AuthRepository` must stub `sessionExpired` (e.g. `thenAnswer((_) => const Stream.empty())`) because `AuthBloc` subscribes to it in its constructor.
- Tests that use `getIt` register what they need in `setUp` and call `getIt.reset()` in `tearDown`.
- Widget tests that render screens or `AppErrorWidget` must give the `MaterialApp` `localizationsDelegates: appLocalizationsDelegates` and `supportedLocales: AppLocalizations.supportedLocales` (import `core/l10n/l10n.dart`). Assert on the English strings.
- Call `AppConfig.initialize(baseUrl: ...)` in `setUpAll` when code under test reads `AppConfig` (network, app root).
- Never hit the real network; fake it with mocks or a fake `HttpClientAdapter` (see `test/core/network/api_interceptor_test.dart`).
- Never depend on real files under `assets/`; supply them with `FakeAssetBundle` (`test/helpers/fake_asset_bundle.dart`) through `DefaultAssetBundle` (see `test/core/widgets/app_svg_test.dart`). Lottie parses asynchronously: pump inside `tester.runAsync` (see `app_lottie_test.dart`).
