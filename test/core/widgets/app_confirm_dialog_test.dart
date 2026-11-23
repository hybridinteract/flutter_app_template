import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/widgets/app_confirm_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AppConfirmDialog.show', () {
    late bool? result;

    Future<void> openDialog(WidgetTester tester) async {
      result = null;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await AppConfirmDialog.show(
                    context,
                    title: 'Delete item?',
                    message: 'This cannot be undone.',
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('resolves true on Confirm', (tester) async {
      await openDialog(tester);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.byType(AppConfirmDialog), findsNothing);
    });

    testWidgets('resolves false on Cancel', (tester) async {
      await openDialog(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('resolves false when dismissed by tapping outside', (
      tester,
    ) async {
      await openDialog(tester);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(result, isFalse);
      expect(find.byType(AppConfirmDialog), findsNothing);
    });
  });
}
