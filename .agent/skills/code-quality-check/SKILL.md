---
name: code-quality-check
description: Run the complete pre-commit quality pipeline (code generation, format check, strict analysis, tests with coverage, architecture audit, agent-config sync check). Same checks as CI.
---
# Workflow: Code Quality & Architecture Audit

Run before committing or opening a PR. Every step must pass; CI runs the same commands.

1. **Code generation** (generated files must match the annotations; never hand-edit `*.g.dart`):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
   If it hangs with no CPU use (stale cache after moving files), run `dart run build_runner clean` and build again.
   After editing an ARB file also run `flutter gen-l10n` (output in `lib/core/l10n/generated/`, never hand-edited).
2. **Format**:
   ```bash
   dart format --output=none --set-exit-if-changed .
   ```
   If it fails, run `dart format .` and re-check.
3. **Static analysis** (zero errors, warnings and infos):
   ```bash
   flutter analyze --fatal-infos
   ```
4. **Tests with coverage**:
   ```bash
   flutter test --coverage
   ```
5. **Architecture audit** (import boundaries and code rules from `.agent/rules/`):
   ```bash
   dart run tool/check_architecture.dart
   ```
   Checks: `core/` imports no feature or `app/`; features import other features only via `features/auth/auth.dart`; views import no services/repositories/Dio; controllers import no Flutter UI, `go_router`, services, Dio or `getIt`; `getIt` is used only in `main.dart`, `lib/app/` and `*_routes.dart`; no `Image.network` / `NetworkImage` outside `AppNetworkImage`; no file in `lib/` over 400 lines.
6. **Agent config in sync** (`.agent/` and `GEMINI.md` are generated from `.claude/` and `CLAUDE.md`):
   ```bash
   dart run tool/sync_agent_config.dart --check
   ```
   If it fails, run `dart run tool/sync_agent_config.dart` and commit the result.
7. **Manual review**:
   - New services, repositories and BLoCs are registered in `lib/app/injection_container.dart`.
   - New feature routes are spread into `lib/app/app_router.dart`.
   - No hardcoded URLs, colors, sizes, secrets or tokens; no tokens/passwords in logs or `SharedPreferences`.
   - Every controller, timer, `Debouncer` and subscription a `State` creates is released in `dispose()`; growing lists use a builder or `AppPaginatedList` (performance.md).
   - No widget or helper copied from another feature or from `core/` (clean-code.md).
