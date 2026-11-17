---
paths:
  - "lib/**"
---
# Layering & Module Rules

## Folder ownership
- `lib/app/`: composition root only (`app.dart`, `app_router.dart`, `injection_container.dart`). It may import any feature.
- `lib/core/`: shared, feature-agnostic code. It never imports `lib/features/` or `lib/app/`.
- `lib/features/<feature>/`: one folder per feature with `models/`, `services/`, `repositories/`, `controllers/`, `views/` (+ `views/widgets/`) and `<feature>_routes.dart`. Only create the sub-folders a feature needs (a static screen may have only `views/`).

## Flow
- View → BLoC → Repository → Service → API. No layer skips another.
- Views talk only to BLoCs (events in, states out).
- BLoCs call only repository contracts.
- Repositories coordinate services and `core/storage`, and map every exception to a `Failure`.
- Services call the API through `DioClient` and return models.

## Cross-feature imports
- Features never import each other's files.
- One exception: `auth` owns the session, so any feature may import `package:app_template/features/auth/auth.dart` (its public API: `AuthBloc`, auth events/states, `UserModel`, `PermissionGuard`, permission helpers). Never import auth's services, repositories or screens directly.
- Navigate to another feature with `RouteNames` from `core/routes/`, never by importing its screen.
- Code needed by two or more features moves to `core/` (if it is feature-agnostic) or is exposed through `auth.dart` (if it is session-related).

## Imports
- Inside a feature, import its own files with relative paths (`../models/x.dart`).
- Import anything outside the feature with `package:app_template/...`.

## Optional use cases
- Do not add a use-case layer by default. Add `features/<feature>/usecases/` only when logic combines several repositories or holds real business rules; the BLoC then calls the use case, and the use case calls repositories.
