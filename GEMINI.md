# GEMINI.md - Antigravity Agent Guidelines
<!-- Generated from CLAUDE.md by tool/sync_agent_config.dart. Do not edit; edit CLAUDE.md and re-run the script. -->
Stack: Flutter · BLoC · Dio · GetIt · GoRouter
Architecture: feature-first Modular MVC with Clean Architecture boundaries (no use-case layer by default).

Commands:
- Run: `flutter run --dart-define-from-file=.env`
- Format: `dart format .`
- Analyze: `flutter analyze --fatal-infos`
- Test: `flutter test --coverage`
- Code generation: `dart run build_runner build`
- Localization (after editing lib/core/l10n/arb/*.arb): `flutter gen-l10n`
- Architecture audit: `dart run tool/check_architecture.dart`
- Sync agent config (after editing this file or .claude/): `dart run tool/sync_agent_config.dart`

Structure (details: docs/ARCHITECTURE.md; read it before creating a feature or folder):
```
lib/
├── app/          # composition root: app.dart, app_router.dart, injection_container.dart
├── core/         # shared, feature-agnostic code (never imports features/ or app/)
├── features/
│   └── <feature>/
│       ├── models/ services/ repositories/ controllers/ views/
│       └── <feature>_routes.dart
└── main.dart
test/             # mirrors lib/
```

Layer Rules:
1. View → BLoC → Repository → Service. No layer skips another.
2. Views contain no API calls and no business logic.
3. BLoCs contain no UI code and no direct Dio or service calls.
4. Repositories define a contract (abstract class) and an implementation; they map exceptions to failures.
5. Services only perform API calls and return models.
6. Raw exceptions never reach the UI.
7. Every dependency is registered in lib/app/injection_container.dart.
8. Features do not import each other; the only shared feature API is features/auth/auth.dart. Other shared code goes in core/.
9. core/ holds no feature-specific code.
10. Constants, colors and dimensions come from core/; user-facing text comes from core/l10n (ARB) via context.l10n. Nothing inline.

Detailed rules (auto-loaded by path):
- Layering & modules: .agent/rules/layering.md
- BLoC: .agent/rules/bloc.md
- Views & UI: .agent/rules/views.md
- Routing: .agent/rules/routing.md
- Networking: .agent/rules/networking.md
- Errors: .agent/rules/errors.md
- Models & JSON: .agent/rules/models.md
- Dependency injection: .agent/rules/di.md
- Testing: .agent/rules/testing.md
- Performance & memory: .agent/rules/performance.md
- Clean code & reuse: .agent/rules/clean-code.md

Skills:
- New feature: `.agent/skills/new-feature/SKILL.md`
- New endpoint: `.agent/skills/new-api-endpoint/SKILL.md`
- Add screen: `.agent/skills/add-screen/SKILL.md`
- Write tests: `.agent/skills/write-tests/SKILL.md`
- Quality check: `.agent/skills/code-quality-check/SKILL.md`
- Debug flow: `.agent/skills/debug-flow/SKILL.md`

New Feature Checklist (master prompt: docs/PROMPT_TEMPLATE.md):
1. Model with JSON serialization in features/<feature>/models/.
2. Service method(s) using DioClient.
3. Repository contract and implementation with error mapping.
4. BLoC with events and states.
5. Screen and widgets using shared core/widgets.
6. <feature>_routes.dart, spread into lib/app/app_router.dart; path constants in core/routes/route_names.dart.
7. Register service, repository and BLoC in lib/app/injection_container.dart.
8. Add constants (endpoints, keys, assets) in core/constants.
9. Tests under test/features/<feature>/ (BLoC, repository, screen).
10. code-quality-check passes (format, analyze, test, architecture audit).

Anti-Patterns:
1. API call inside a view or BLoC.
2. BLoC importing BuildContext, widgets, navigation or getIt.
3. Repository without a contract, or a view talking to a repository directly.
4. Raw exception text (`e.toString()`, Dio messages) shown to users.
5. Empty catch blocks.
6. Hardcoded URLs, colors, user-facing text, keys or dimensions.
7. Tokens or passwords in SharedPreferences or logs.
8. A feature importing another feature's files (anything but features/auth/auth.dart).
9. Dependency created manually instead of through GetIt, or getIt used outside main.dart, lib/app/ and *_routes.dart.
10. Fixed screen widths and heights.
11. Routes defined outside <feature>_routes.dart, or path strings outside core/routes/route_names.dart.
12. A feature BLoC provided app-wide when only its own routes use it.
13. A .agent/rules file without paths: frontmatter.
14. The same rule copied into several docs; editing .agent/ or GEMINI.md by hand (they are generated).
15. Editing *.g.dart by hand instead of changing the model annotations.
16. Controllers, timers or subscriptions not disposed; `Image.network` instead of `AppNetworkImage`; `ListView(children:)` for API data.
17. Copying a widget or helper instead of reusing or promoting it to core/.
