# New App Prompt

Start a new app from a fresh clone of this template.

## Claude Code
```
/new-app <your-app-name>
```
`/new-app` is the only keyword. Replace `<your-app-name>` with your app's name, without the `< >`. For example, `/new-app shop_app` creates an app called Shop App.

To set a different display name: `/new-app <your-app-name> "<Display Name>"`.

Everything else comes from the name:

| Item | Value |
|---|---|
| Dart package | `<your-app-name>` (snake_case: `Shop App` becomes `shop_app`) |
| Display name | Title case of the name (`shop_app` gives `Shop App`) |
| Android applicationId / namespace | `com.hybridinteractive.<your-app-name>` |
| iOS bundle id | `com.hybridinteractive.<your-app-name>` (underscores become camelCase: `shopApp`) |

The name must start with a letter and can be at most 3 words or 30 characters.

## Other agents (Antigravity, Gemini, ...)
Paste this, replacing only `<your-app-name>`:
```
Create a new app from this template.
App name: <your-app-name>
Follow .claude/skills/new-app/SKILL.md (.agent/skills/new-app/SKILL.md) end to end:
pre-flight, dry run, one confirmation, rename with tool/new_app.dart,
regenerate, pass every quality check, then start a fresh git history.
```

## Before you run it
- Clone into a folder named after the app: `git clone https://github.com/hybridinteract/flutter_app_template.git <your-app-name>`.
- Have Flutter installed (`flutter doctor`).
- Don't change anything first: the skill stops if the working tree has uncommitted changes.
