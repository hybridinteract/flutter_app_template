---
paths:
  - "lib/features/**/repositories/**"
  - "lib/core/error/**"
---
# Error Handling Rules

- Every repository method wraps its body in `try { ... } catch (e) { throw mapExceptionToFailure(e); }`.
- Only typed `Failure`s (`NetworkFailure`, `AuthenticationFailure`, `ValidationFailure`, `ServerFailure`, ...) leave a repository. Raw Dio, socket, parsing or storage exceptions never reach BLoCs or UI.
- `mapExceptionToFailure` (`core/error/failure.dart`) is the single mapping point. Never build user messages from `e.toString()` or Dio's `error.message`.
- User-facing messages are friendly and actionable ("No internet connection", "Session expired"). Server-provided `message` fields may be shown because the backend writes them for users.
- No empty catch blocks. An intentional fallback (e.g. remote logout failing while local sign-out must still happen) catches the narrowest type possible and carries a comment explaining why it is safe to ignore.
- Technical details (stack traces, raw payloads) go to `CrashReportingService`, never to the UI.
- `Failure` default messages are English (no BuildContext in core). To localize an error, map `failure.code` to an l10n key in the view.
