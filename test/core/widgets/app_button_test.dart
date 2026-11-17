import 'package:app_template/core/widgets/app_button.dart';
import 'package:app_template/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders button text and triggers onPressed when tapped', (
      tester,
    ) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Submit',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(AppLoader), findsNothing);

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(pressed, isTrue);
    });

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
