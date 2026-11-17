import 'package:app_template/core/l10n/l10n.dart';
import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('appLocalizationsDelegates', () {
    final types = appLocalizationsDelegates.map((d) => d.type).toSet();

    // MaterialApp adds English defaults itself, so a widget test in English
    // passes even with the wrong delegates. Check the types instead: gen-l10n's
    // own list registers the deprecated SDK types, which material_ui and
    // cupertino_ui widgets never look up.
    test('translate material_ui and cupertino_ui widgets', () {
      expect(types, contains(MaterialLocalizations));
      expect(types, contains(CupertinoLocalizations));
    });

    test('include the app strings and widgets localizations', () {
      expect(types, contains(AppLocalizations));
      expect(types, contains(WidgetsLocalizations));
    });

    test('differ from the gen-l10n list', () {
      final generatedTypes = AppLocalizations.localizationsDelegates
          .map((d) => d.type)
          .toSet();
      expect(generatedTypes, isNot(contains(MaterialLocalizations)));
    });
  });
}
