---
name: new-api-endpoint
description: Add a new API endpoint to an existing feature under lib/features/<feature>/ (constant, model, service method, repository contract + implementation, BLoC event/state, UI, minimum tests).
---
# Workflow: Add New API Endpoint

All feature paths below are relative to `lib/features/<feature>/`.

1. **Constant**: add the path to `lib/core/constants/api_constants.dart`.
2. **Model**: add or update `models/<name>_model.dart` (`@JsonSerializable()`, `Equatable`, `copyWith`). Run `dart run build_runner build`.
3. **Service**: add the method to `services/<feature>_service.dart`. It calls `DioClient`, unwraps the `data` envelope if present, and returns a model. No try/catch here.
4. **Repository contract**: add the signature to `repositories/<feature>_repository.dart`.
5. **Repository implementation**: implement it in `repositories/<feature>_repository_impl.dart`:
   ```dart
   try {
     return await _service.newCall();
   } catch (e) {
     throw mapExceptionToFailure(e);
   }
   ```
6. **BLoC**: add the event in `controllers/<feature>_event.dart`, any new state in `controllers/<feature>_state.dart`, and the handler in `controllers/<feature>_bloc.dart` (`on Failure catch` → failure state with `failure.message`).
7. **UI**: update the screen in `views/` to dispatch the event and render the new state.
8. **Tests** (in `test/features/<feature>/`, per `.agent/rules/testing.md`): BLoC success + failure only if the new event is a main load/submit or holds logic; a repository test only if it maps a status code or writes storage.
9. **Verify**: `flutter analyze --fatal-infos` and `flutter test <touched test files> -r failures-only 2>&1 | tail -5`.
