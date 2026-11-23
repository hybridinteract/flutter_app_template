import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/features/auth/controllers/auth_bloc.dart';
import 'package:app_template/features/auth/controllers/auth_event.dart';
import 'package:app_template/features/auth/controllers/auth_state.dart';
import 'package:app_template/features/auth/views/verify_email_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  const email = 'jane@example.com';
  late MockAuthBloc mockAuthBloc;

  setUpAll(() => registerFallbackValue(const LogoutRequested()));

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const VerifyEmailScreen(email: email),
      ),
    );
  }

  group('VerifyEmailScreen', () {
    testWidgets('requires a code before verifying', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildTestableWidget());
      await tester.tap(find.text('Verify'));
      await tester.pump();

      expect(find.text('This field is required.'), findsOneWidget);
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('submits VerifyEmailRequested with the code', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildTestableWidget());
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Verification Code'),
        '123456',
      );
      await tester.tap(find.text('Verify'));
      await tester.pump();

      verify(
        () => mockAuthBloc.add(
          const VerifyEmailRequested(email: email, code: '123456'),
        ),
      ).called(1);
    });
  });
}
