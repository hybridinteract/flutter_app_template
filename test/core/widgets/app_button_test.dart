import 'package:app_template/core/widgets/app_button.dart';
import 'package:app_template/core/widgets/app_loader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AppButton', () {
    testWidgets(
      'shows loading indicator and disables tap when isLoading is true',
      (tester) async {
        var pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                text: 'Submit',
                isLoading: true,
                onPressed: () {
                  pressed = true;
                },
              ),
            ),
          ),
        );

        expect(find.byType(AppLoader), findsOneWidget);
        expect(find.text('Submit'), findsNothing);

        await tester.tap(find.byType(AppLoader));
        await tester.pump();

        expect(pressed, isFalse);
      },
    );
  });
}
