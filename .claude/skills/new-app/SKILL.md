---
name: new-app
description: Turn a fresh clone of this template into a new app, like `flutter create` with this architecture. Usage `/new-app <your-app-name> ["Display Name"]`, e.g. `/new-app shop_app`. Renames the Dart package, Android applicationId/namespace/Kotlin folder and iOS bundle id to com.hybridinteractive.<your-app-name>, sets the display name, regenerates code, runs every quality check and starts a fresh git history. Use when the user asks for a new app, new project or app name from this template.
---
# Workflow: New App from Template

Input: `<your-app-name>` (required; any spelling, normalized to snake_case: `Shop App` → `shop_app`, `ShopApp` → `shop_app`) and an optional display name (default from the name: `shop_app` → `Shop App`). The org is always `com.hybridinteractive` unless the user names another one (`--org`). Below, `<name>` means the app name the user gave.

Before anything else, check the arguments are really a name:
- No name given → ask for it.
- Still the placeholder (contains `<` or `>`), or a sentence or request (more than 3 words, words like "please", "change", "show") → do NOT run the tool. Answer the request if there is one, and ask for the app name, e.g. `/new-app shop_app`.
Ask nothing else. The tool also rejects these (`validateRawName`), but never rely on that alone.

The rename is done by `tool/new_app.dart`; never rename files by hand.

## 1. Pre-flight (stop and tell the user if any fails)
- `pubspec.yaml` says `name: app_template`. Anything else means this app was already created; stop.
- `git status --porcelain` is empty. Uncommitted work would be lost when git history is reset; stop and ask.
- `flutter --version` works.

## 2. Dry run and one confirmation
```bash
dart run tool/new_app.dart <name> [--display-name "Name"] --dry-run
```
Show the user the first lines (package, display name, Android id, iOS bundle id) and the number of changes. Then ask ONE confirmation question (AskUserQuestion) that says plainly: "This renames the app and replaces the template's git history with a single fresh commit." If the tool printed a validation error, show it and ask for another name.

## 3. Rename
```bash
dart run tool/new_app.dart <name> [--display-name "Name"]
```
It edits every text file (pubspec, `package:` imports, Gradle, manifest, Kotlin package + folder, `project.pbxproj`, `Info.plist`, `AppConstants.appName`, `.vscode/launch.json`, docs, rules, skills), creates `.env` from `.env.example` if missing, and deletes the generator (this skill, `tool/new_app.dart`, `test/tool/`, `docs/NEW_APP_PROMPT.md`, and the new-app lines in `CLAUDE.md` / `README.md`).

## 4. Regenerate
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
dart run tool/sync_agent_config.dart
dart fix --apply --code=directives_ordering
dart format .
```
`dart fix` re-sorts imports: `package:<name>/` no longer sorts where `package:app_template/` did (e.g. after `package:flutter_bloc/`), which `directives_ordering` reports.

## 5. Verify against every rule
- Run the `code-quality-check` skill steps 1–6 (format, analyze, tests, architecture audit, agent-config sync). All must pass.
- No template identity left (must print nothing):
  ```bash
  grep -rIn -e app_template -e appTemplate -e "App Template" -e com.example --exclude-dir={.git,.dart_tool,build,coverage,.idea,.gradle,Pods} --exclude=*.iml .
  ```
- `android/app/src/main/kotlin/com/hybridinteractive/<name>/MainActivity.kt` exists and nothing is left under `kotlin/com/example/`.

If anything fails, fix it with the project rules and re-run step 5. Do NOT reset git until step 5 passes; the user can still undo everything with `git checkout . && git clean -fd`.

## 6. Fresh git history
```bash
rm -rf .git
git init -b main
git add -A
git commit -m "Initial commit: <name> from app_template"
```

## 7. Report
Give the user a short table (package, display name, Android id, iOS bundle id, checks passed) and the next steps:
- Create the remote repo, then `git remote add origin <url>` and `git push -u origin main`.
- Set `BASE_URL` in `.env`.
- Reopen the project in Android Studio (the old `*.iml` files are git-ignored and regenerate).
- Not done by this skill: app icon / splash, Android release signing, Firebase.
