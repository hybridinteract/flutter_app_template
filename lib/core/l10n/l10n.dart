import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// Shortcut for localized strings in widgets: `context.l10n.authSignIn`.
///
/// Strings live in `lib/core/l10n/arb/app_<locale>.arb` (keys prefixed by
/// feature: `auth*`, `booking*`, `common*` ...). To add a language, add
/// `app_<locale>.arb` with the same keys and run `flutter gen-l10n`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
