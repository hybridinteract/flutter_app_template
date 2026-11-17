import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/features/auth/controllers/auth_bloc.dart';
import 'package:app_template/features/auth/controllers/auth_event.dart';
import 'package:app_template/features/auth/controllers/auth_state.dart';
import 'package:app_template/features/auth/views/verify_email_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const VerifyEmailScreen(email: email),
      ),
    );
  }

  TextFormField codeField(WidgetTester tester) => tester.widget<TextFormField>(
    find.widgetWithText(TextFormField, 'Verification Code'),
  );

  group('VerifyEmailScreen', () {
    testWidgets('names the address the code went to', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Enter the code we sent to $email'), findsOneWidget);
      expect(find.text('Verify'), findsOneWidget);
      expect(find.text('Resend Code'), findsOneWidget);
    });

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

    testWidgets('Resend Code dispatches ResendVerificationRequested', (
      tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildTestableWidget());
      await tester.tap(find.text('Resend Code'));
      await tester.pump();

      verify(
        () => mockAuthBloc.add(const ResendVerificationRequested(email: email)),
      ).called(1);
    });

    testWidgets('prefills the dev code a local backend returns', (
      tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(
        const AuthVerificationRequired(email: email, devCode: '424242'),
      );

      await tester.pumpWidget(buildTestableWidget());

      expect(codeField(tester).controller?.text, '424242');
    });

    testWidgets('disables the form while loading', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(buildTestableWidget());

      expect(codeField(tester).enabled, isFalse);
      final resend = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Resend Code'),
      );
      expect(resend.onPressed, isNull);
    });

    testWidgets('shows the server message when the code is wrong', (
      tester,
    ) async {
      whenListen(
        mockAuthBloc,
        Stream<AuthState>.fromIterable(const [
          AuthLoading(),
          AuthFailure(message: 'Invalid or expired verification code.'),
        ]),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(
        find.text('Invalid or expired verification code.'),
        findsOneWidget,
      );
    });
  });
}
