---
paths:
  - "lib/**"
  - "test/**"
---
# Clean Code & Reuse Rules

## Reuse before you write
- Before writing a widget, check `lib/core/widgets/` (list in views.md) and the feature's `views/widgets/`. If one is close, add an optional parameter to it instead of making a copy.
- A widget used by one feature lives in that feature's `views/widgets/`. As soon as a second feature needs it, move it to `core/widgets/`, make it feature-agnostic (text, data and callbacks come in as parameters) and delete the copies.
- The same goes for helpers: formatting, validation and dates live once in `core/utils/`, never as a private copy in a feature.

## Size
- One public class per file, named after the class in snake_case.
- Files stay under 400 lines; the architecture check fails above that. Split long before: aim for `build()` under ~60 lines and other functions under ~40.
- Keep nesting shallow (about 3 levels of `if` / callbacks); return early instead.
- A BLoC that handles more than ~8 events or serves unrelated screens is doing two jobs: split it.

## Names
- Names say what a thing is: `productCount`, not `n` or `data2`. Booleans read as questions: `isLoading`, `hasMore`, `canEdit`.
- Events are requests or facts (`LoginRequested`, `SearchQueryChanged`); states describe the screen (`ProductLoading`, `ProductSuccess`).
- No abbreviations beyond the common ones (`id`, `url`, `api`, `json`).

## Keep it clean
- No dead code: no commented-out code, unused parameters, imports or files. Git keeps the history.
- A `TODO` carries a reason and a ticket or owner: `// TODO(team): remove after API v2 (#123)`.
- Comments explain why, not what. Every public class in `core/` has a `///` doc saying when to use it.
- Data is immutable: `final` fields, `const` constructors, `copyWith`. Never mutate a list or map held in a state; emit a new one (Equatable compares by value, so a mutated list emitted again looks unchanged and the UI does not rebuild).

## Built to grow
- New behaviour goes in a new file or feature folder, not into an ever-growing `utils` file or BLoC.
- BLoCs depend on repository contracts, so implementations can change without touching them.
- New logic in `core/` (utils, network, storage, session) gets the minimum test in testing.md; presentational widgets get none.
