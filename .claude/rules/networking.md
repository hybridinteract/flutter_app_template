---
paths:
  - "lib/features/**/services/**"
  - "lib/core/network/**"
  - "lib/core/session/**"
---
# Networking Rules

- Every request goes through the shared `DioClient` (injected). Never create a `Dio` in a service.
- Endpoint paths live in `core/constants/api_constants.dart`; never inline URLs.
- Services only call the API and parse the response into models. They do not catch errors, touch storage or return raw `Response`/JSON.
- `ApiInterceptor` (a `QueuedInterceptor`) owns:
  - attaching the access token,
  - refreshing it once on 401 (queued requests retry with the new token),
  - clearing tokens and calling `SessionExpiryNotifier.notifyExpired()` when refresh fails,
  - attaching `X-Workspace-Id` from `ActiveWorkspaceStore` when a brand workspace is active (never on `/workspaces` or `/workspaces/options`),
  - debug-only logging with sensitive keys masked (passwords, tokens, secrets).
- Status codes are mapped in `core/network/api_exception.dart`: 400, 401, 403, 404, 409, 422, 429, 500, 503, plus timeouts, no connection, bad certificate and malformed JSON.
- The backend (FastAPI) puts the user-facing error text in `detail` (a string, an object with `message`, or a 422 list); `extractServerMessage` reads it. Never branch on that text, only on the status code.
- Technical messages (Dio's `error.message`, stack traces) go into `details`, never into the user-facing `message`.
