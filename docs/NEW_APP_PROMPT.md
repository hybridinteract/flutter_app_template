# New App Prompt

Start a new app from a fresh clone of this template.

## Claude Code
```
/new-app influen
```
Optional display name: `/new-app influen "Influen Pro"`. Everything else is derived:

| Item | Value for `influen` |
|---|---|
| Dart package | `influen` |
| Display name | `Influen` |
| Android applicationId / namespace | `com.hybridinteractive.influen` |
| iOS bundle id | `com.hybridinteractive.influen` |

## Other agents (Antigravity, Gemini, ...)
Paste this, changing only the name:
```
Create a new app from this template.
App name: influen
Follow .claude/skills/new-app/SKILL.md (.agent/skills/new-app/SKILL.md) end to end:
pre-flight, dry run, one confirmation, rename with tool/new_app.dart,
regenerate, pass every quality check, then start a fresh git history.
```

## Before you run it
- Clone into a folder named after the app: `git clone <template-url> influen`.
- Have Flutter installed (`flutter doctor`).
- Don't change anything first: the skill stops if the working tree has uncommitted changes.
