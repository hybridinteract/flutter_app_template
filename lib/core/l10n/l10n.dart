import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations;

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// Localization delegates for every `MaterialApp` (the app and widget tests).
///
/// Use this instead of `AppLocalizations.localizationsDelegates`: gen-l10n
/// still emits the SDK's deprecated Material/Cupertino delegates, whose
/// localization types differ from the `material_ui` / `cupertino_ui` widgets
/// we use. With those, any non-English locale would find no
/// `MaterialLocalizations` (MaterialApp only adds English defaults).
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates =
    <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];

/// Shortcut for localized strings in widgets: `context.l10n.authSignIn`.
///
/// Strings live in `lib/core/l10n/arb/app_<locale>.arb` (keys prefixed by
/// feature: `auth*`, `home*`, `common*` ...). To add a language, add
/// `app_<locale>.arb` with the same keys and run `flutter gen-l10n`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
