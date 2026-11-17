---
paths:
  - "lib/features/**/controllers/**"
---
# BLoC Rules

- Three files per BLoC: `<feature>_event.dart`, `<feature>_state.dart`, `<feature>_bloc.dart`.
- Events and states extend `Equatable` and list every field in `props`.
- Standard states: `<Feature>Initial`, `<Feature>Loading`, `<Feature>Success`, `<Feature>Failure`. Add more only when the screen needs them (e.g. `AuthUnauthenticated`).
- BLoCs depend only on repository contracts (or an optional use case). Never on services, `DioClient`, storage or `getIt`.
- No `BuildContext`, Flutter widget, `go_router` or navigation imports. Pure Dart plus `flutter_bloc`/`equatable`.
- Catch `on Failure` and emit a failure state with `failure.message`. Add a final `catch (_)` with a friendly fallback message; never show `e.toString()`.
- One BLoC per feature, focused on that feature's state.
- Scope:
  - Route-scoped (default): created in `<feature>_routes.dart` with `BlocProvider(create: (_) => getIt<XBloc>())`. Each route gets a fresh instance, closed automatically on pop.
  - App-wide: only when the whole app depends on it (today only `AuthBloc`, provided in `lib/app/app.dart`).
- If a BLoC listens to a stream (e.g. `sessionExpired`), keep the `StreamSubscription` and cancel it in `close()`.
