---
paths:
  - "test/**"
---
# Testing Rules

- `test/` mirrors `lib/`: `lib/features/auth/controllers/auth_bloc.dart` → `test/features/auth/controllers/auth_bloc_test.dart`.
- Tools: `flutter_test`, `bloc_test` (`blocTest`, `MockBloc`) and `mocktail`. Mock contracts, not implementations: `class MockXRepository extends Mock implements XRepository {}`.
- Minimum per feature: BLoC test (success + failure per event), repository test (success, error → `Failure`), widget test per screen (loading, error, success).
- Mocks of `AuthRepository` must stub `sessionExpired` (e.g. `thenAnswer((_) => const Stream.empty())`) because `AuthBloc` subscribes to it in its constructor.
- Tests that use `getIt` (e.g. route tests) register what they need in `setUp` and call `getIt.reset()` in `tearDown`.
- Widget tests that render screens or `AppErrorWidget` must give the `MaterialApp` `localizationsDelegates: appLocalizationsDelegates` and `supportedLocales: AppLocalizations.supportedLocales` (import `core/l10n/l10n.dart`). Assert on the English strings.
- Call `AppConfig.initialize(baseUrl: ...)` in `setUpAll` when code under test reads `AppConfig` (network, app root).
- Never hit the real network; fake it with mocks or a fake `HttpClientAdapter` (see `test/core/network/api_interceptor_test.dart`).
- Never depend on real files under `assets/`; supply them with `FakeAssetBundle` (`test/helpers/fake_asset_bundle.dart`) through `DefaultAssetBundle` (see `test/core/widgets/app_svg_test.dart`). Lottie parses asynchronously: pump inside `tester.runAsync` (see `app_lottie_test.dart`).
