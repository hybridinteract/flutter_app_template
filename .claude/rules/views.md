---
paths:
  - "lib/features/**/views/**"
  - "lib/core/widgets/**"
---
# Views & UI Rules

- Views hold zero business logic and zero API, service or repository calls.
- Views interact with their feature only through BLoC events and `BlocBuilder` / `BlocListener` / `BlocConsumer`:
  - `BlocBuilder` to rebuild UI, `BlocListener` for side effects (navigation, snackbars), `BlocConsumer` for both.
- Read BLoCs with `context.read<XBloc>()`; never create them in a view or call `getIt` from a view. They are provided by the route (`<feature>_routes.dart`) or the app (`lib/app/app.dart`).
- Handle every state: loading (`AppLoader`), error (`AppErrorWidget` with retry), empty (`AppEmptyWidget`) and success.
- Reuse `core/widgets/`; do not duplicate them. Feature-only widgets go in `views/widgets/` (when to promote one: clean-code.md):
  - `AppButton`, `AppTextField`: buttons and form fields.
  - `AppLoader`, `AppErrorWidget`, `AppEmptyWidget`: loading, error (with retry) and empty states.
  - `AppNetworkImage`: every image from a URL (cached, decoded at display size).
  - `AppPaginatedList`: lists fed by a paginated API (infinite scroll, pull-to-refresh, load-more footer).
  - `AppConfirmDialog.show(...)`: yes/no before destructive actions; returns `Future<bool>`.
  - `Debouncer` (`core/utils/`): search and filter input.
- No hardcoded colors, sizes or spacing: use `Theme.of(context)` / `context.colorScheme` / `context.textTheme` and `AppDimensions`.
- No hardcoded user-facing text: add the key to `lib/core/l10n/arb/app_en.arb` (prefixed by feature: `auth*`, `booking*`, `common*` ...), run `flutter gen-l10n`, and read it with `context.l10n.key` (`final l10n = context.l10n;` at the top of `build`).
- Pass localized messages to `Validators` (e.g. `Validators.email(v, requiredMessage: l10n.validationEmailRequired, message: l10n.validationEmailInvalid)`).
- Navigate with `context.go` / `context.push` and `RouteNames` constants only.
- Responsive: Mobile < 600, Tablet 600–1023, Desktop ≥ 1024 (`ScreenBreakpoints`, `ResponsiveLayout`). No fixed screen widths or heights.
- `ListTile.trailing` has a capped height: keep it to one line (move chips/extra lines into `subtitle`).
- Rebuilds, lists, disposing controllers: performance.md.
