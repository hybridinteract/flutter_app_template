---
paths:
  - "lib/features/**/models/**"
---
# Model Rules

- Models are immutable: `@JsonSerializable()` + `extends Equatable` + `const` constructor + `copyWith`; list every field in `props`.
- Never edit `*.g.dart` by hand. Any custom JSON behavior goes into annotations, then run `dart run build_runner build`. `/code-quality-check` fails if generated files are stale.
- Match the backend's key casing in the annotation. The auth backend (FastAPI) uses snake_case: `@JsonSerializable(fieldRename: FieldRename.snake)`.
- Accept alternative keys with `@JsonKey(readValue: _readX)` helpers (e.g. `json['created_at'] ?? json['createdAt']`) and give them a sensible default.
- Models that contain other models use `@JsonSerializable(explicitToJson: true)` so nested objects serialize as maps.
- Model tests: only custom parsing and branching getters (testing.md).
