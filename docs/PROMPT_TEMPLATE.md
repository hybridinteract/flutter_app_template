# Feature Scaffolding Prompt Template

Use this template whenever you want an AI agent (Antigravity, Claude Code, etc.) to build a complete, production-grade feature module adhering strictly to this repository's feature-first Modular MVC standards (see `docs/ARCHITECTURE.md`).

---

```markdown
Create a new feature module called "[Feature Name]" following the project's architecture rules and skills.

## 1. Feature Overview
- Module Name: [e.g. products]
- Base Route: [e.g. /products]
- Purpose: [one line describing what the feature does]

## 2. API Endpoints
- [METHOD /path -> response, e.g. GET /products -> List<ProductModel>]
- [METHOD /path/{id} -> response, e.g. GET /products/{id} -> ProductModel]
- [e.g. POST /products/{id}/favorite -> Mark as favorite]

## 3. Model Fields
- [ModelName]: [field: Type, e.g. id: String, title: String, price: double, description: String, imageUrl: String, stock: int, createdAt: DateTime]

## 4. UI Requirements
- Screen(s): [e.g. ProductsScreen (search + list), ProductDetailScreen]
- Interactions: [e.g. pull-to-refresh, search, pagination]
- State handling:
  - Loading -> `AppLoader`
  - Failure -> `AppErrorWidget` with a retry action
  - Empty -> `AppEmptyWidget`
- Reuse existing widgets from `core/widgets/`. Do not create duplicates.

## 5. Architecture Rules
- All code lives in `lib/features/[module]/` (models, services, repositories, controllers, views, [module]_routes.dart).
- Follow the flow: View -> BLoC -> Repository -> Service.
- The View talks only to the BLoC, never to a Repository or Service.
- The Repository catches exceptions and maps them to domain `Failure`s.
- The Model uses `@JsonSerializable()` and extends `Equatable`.
- BLoC has separate Event, State, and BLoC files, with Equatable states; it is provided per route.
- Do not import other features. If the signed-in user is needed, import only `features/auth/auth.dart`.

## 6. Execution Steps (in order)
1. Scaffold the module using the `/new-feature` skill
   (Model, Service, Repository contract + implementation, BLoC, Views, Widgets, [module]_routes.dart).
2. Add endpoints to `lib/core/constants/api_constants.dart` and paths to `lib/core/routes/route_names.dart`.
3. Register Service, Repository, and BLoC in `lib/app/injection_container.dart`.
4. Spread `[Module]Routes.routes` into `lib/app/app_router.dart`.
5. Run `dart run build_runner build --delete-conflicting-outputs`.
6. Write tests in `test/features/[module]/` using the `/write-tests` skill:
   - BLoC unit tests (`bloc_test`)
   - Repository unit tests (`mocktail`)
   - Widget tests (`flutter_test`)
7. Run the `/code-quality-check` skill:
   - `dart format --output=none --set-exit-if-changed .`
   - `flutter analyze --fatal-infos`
   - `flutter test --coverage`
   - `dart run tool/check_architecture.dart`
8. If analysis or tests fail, use the `/debug-flow` skill to diagnose and fix, then re-run step 7.

## 7. Definition of Done
- `flutter analyze --fatal-infos` reports 0 issues and `tool/check_architecture.dart` reports 0 violations.
- All tests pass, including the new ones.
- Generated files (`*.g.dart`) are up to date.
- No hardcoded URLs, strings, or duplicate widgets.
- End with a short summary listing files created, files modified, and any assumptions you made.
```

