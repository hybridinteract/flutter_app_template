# Flutter Application Architecture Standard

**Feature-first Modular MVC + Clean Architecture boundaries · Flutter · Dart · BLoC · Dio · GetIt · GoRouter**
*v1.1 · 16 November 2026* (v1.0 used layer-first folders; see ADR-008)

---

## 1. Overview

### Tech Stack
| Category | Technology |
|---|---|
| **Framework / Language** | Flutter / Dart |
| **State management** | flutter_bloc + equatable |
| **API client** | dio |
| **Dependency injection** | get_it |
| **Navigation** | go_router |
| **Serialization** | json_serializable |
| **Local storage** | shared_preferences (preferences), flutter_secure_storage (tokens) |
| **Images** | cached_network_image |
| **Localization** | flutter_localizations + gen-l10n (ARB files) |
| **Formatting** | intl |
| **Crash reporting** | firebase_crashlytics (behind `CrashReportingService`) |
| **Testing** | flutter_test, bloc_test, mocktail |
| **Lint** | flutter_lints + `tool/check_architecture.dart` |

### Request Flow
```
View ──► BLoC ──► Repository ──► Service ──► API
 ▲        │           │             │
 └────────┴───────────┴─────────────┘   states / models / Failures return upward
```

### Why not full Clean Architecture?
The template keeps Clean Architecture's valuable boundaries (repository contracts, typed `Failure`s, DI, a UI-free BLoC layer) but not its per-feature `domain/data/presentation` split, entity/model duplication or mandatory use cases. Those roughly double the files per feature for typical CRUD apps. A `usecases/` folder is allowed when a feature has real business rules (ADR-011).

---

## 2. Directory Structure

```
lib/
├── app/                          # Composition root (may import any feature)
│   ├── app.dart                  # Root widget; provides app-wide BLoCs (AuthBloc)
│   ├── app_router.dart           # Combines <Feature>Routes + auth redirect
│   └── injection_container.dart  # All GetIt registrations
├── core/                         # Shared + feature-agnostic; never imports features/ or app/
│   ├── config/                   # AppConfig (from .env)
│   ├── constants/                # ApiConstants, AppConstants, StorageKeys, AppAssets
│   ├── di/                       # service_locator.dart (getIt instance)
│   ├── error/                    # AppException, Failure, mapExceptionToFailure
│   ├── extensions/               # Context / String extensions
│   ├── l10n/                     # arb/app_en.arb (all UI text), generated/ (gen-l10n), l10n.dart (context.l10n, appLocalizationsDelegates)
│   ├── network/                  # DioClient, ApiInterceptor, api_exception, ApiResponse, NetworkInfo
│   ├── responsive/               # ScreenBreakpoints, ResponsiveLayout, AdaptiveBuilder
│   ├── routes/                   # RouteNames (all paths), GoRouterRefreshStream
│   ├── services/                 # CrashReportingService
│   ├── session/                  # SessionExpiryNotifier
│   ├── storage/                  # LocalStorage (prefs), SecureStorage (tokens)
│   ├── theme/                    # AppTheme, AppColors, AppTextStyles, AppDimensions
│   ├── utils/                    # Validators, Formatters, DateUtils, Helpers, AppBlocObserver
│   └── widgets/                  # AppButton, AppTextField, AppLoader, AppErrorWidget, AppEmptyWidget, AppNetworkImage, AppPaginatedList, AppConfirmDialog
├── features/
│   ├── auth/
│   │   ├── auth.dart             # PUBLIC API: the only file other features may import
│   │   ├── auth_routes.dart
│   │   ├── models/ services/ repositories/ controllers/
│   │   └── views/ (+ widgets/permission_guard.dart, auth_context_extensions.dart)
│   ├── booking/                  # Reference feature: full stack + route-scoped BLoC
│   │   ├── booking_routes.dart
│   │   └── models/ services/ repositories/ controllers/ views/
│   ├── home/  profile/  settings/   # View-only features (views/ + *_routes.dart)
└── main.dart                     # Config → BLoC observer → DI → crash reporting → runApp(App)

test/                             # Mirrors lib/ (test/core/..., test/features/<feature>/...)
tool/                             # check_architecture.dart, sync_agent_config.dart
```

### Inside a feature
| Folder | Responsibility | Depends on |
|---|---|---|
| `models/` | Data classes, JSON (`@JsonSerializable`), `Equatable`, `copyWith` | nothing |
| `services/` | API calls through `DioClient`; returns models | `core/network`, `core/constants`, `models/` |
| `repositories/` | Contract + implementation; coordinates services and `core/storage`; maps errors to `Failure` | `services/`, `core/` |
| `controllers/` | BLoC + events + states; business logic | repository **contract** only |
| `views/` | Screens and `widgets/`; render states, dispatch events | own BLoC, `core/widgets`, `core/theme` |
| `<feature>_routes.dart` | `GoRoute`s; creates route-scoped BLoCs via `getIt` | own views + controllers |

---

## 3. Rules

The rules are written once and enforced in three places:
- **Layer rules and anti-patterns**: `CLAUDE.md`.
- **Detailed, path-scoped rules**: `.claude/rules/` (`layering`, `bloc`, `views`, `routing`, `networking`, `errors`, `models`, `di`, `testing`).
- **Automated import audit**: `dart run tool/check_architecture.dart` (runs in CI).

### Cross-feature dependencies
Features never import each other. The single exception is the session: `auth` exposes `features/auth/auth.dart` (`AuthBloc`, auth events and states, `UserModel`, `PermissionGuard`, permission helpers), which any feature may import. Navigation between features uses `RouteNames` constants, never screen imports.

### BLoC scope
| Scope | Where provided | When |
|---|---|---|
| Route-scoped (default) | `BlocProvider(create: (_) => getIt<XBloc>())` in `<feature>_routes.dart` | Any feature BLoC. Each route gets a fresh instance, closed on pop. |
| App-wide | `lib/app/app.dart` | Only when the whole app depends on it (`AuthBloc`, used by the router redirect). |

---

## 4. Cross-cutting flows

### Session expiry
```
API 401 ──► ApiInterceptor (QueuedInterceptor)
              ├─ token already refreshed by another request? ──► retry
              ├─ refresh once ──► success ──► retry
              └─ refresh failed ──► clear tokens ──► SessionExpiryNotifier.notifyExpired()
                                                      │
AuthRepository.sessionExpired ◄───────────────────────┘
        │
AuthBloc: SessionExpired ──► clearSession() ──► AuthUnauthenticated ──► router redirects to /login
```

### Errors
`DioException` ──► `mapDioExceptionToAppException` (`core/network/api_exception.dart`) ──► `mapExceptionToFailure` (`core/error/failure.dart`) ──► repository throws `Failure` ──► BLoC emits `XFailure(failure.message)` ──► view shows `AppErrorWidget` or a snackbar. Technical text stays in `details` and crash logs.

---

## 5. Responsive Breakpoints
- **Mobile**: < 600
- **Tablet**: 600 – 1023
- **Desktop**: >= 1024

---

## 6. Agent configuration
`CLAUDE.md` and `.claude/` are the source of truth. `GEMINI.md` and `.agent/` (Antigravity) are generated by `dart run tool/sync_agent_config.dart`; CI fails if they drift.
