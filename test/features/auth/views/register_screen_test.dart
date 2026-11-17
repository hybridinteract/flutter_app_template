import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/features/auth/controllers/auth_bloc.dart';
import 'package:app_template/features/auth/controllers/auth_event.dart';
import 'package:app_template/features/auth/controllers/auth_state.dart';
import 'package:app_template/features/auth/models/account_type.dart';
import 'package:app_template/features/auth/views/register_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
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
        child: const RegisterScreen(),
      ),
    );
  }

  Future<void> enterText(WidgetTester tester, String label, String text) =>
      tester.enterText(find.widgetWithText(TextFormField, label), text);

  group('RegisterScreen', () {
    testWidgets('defaults to Creator and asks for a social handle', (
      tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Creator'), findsOneWidget);
      expect(find.text('Brand'), findsOneWidget);
      expect(find.text('Social Handle'), findsOneWidget);
      expect(find.text('Organization Name'), findsNothing);
    });

    testWidgets('asks for an organization name once Brand is chosen', (
      tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildTestableWidget());
      await tester.tap(find.text('Brand'));
      await tester.pump();

      expect(find.text('Organization Name'), findsOneWidget);
      expect(find.text('Social Handle'), findsNothing);
    });

    testWidgets('rejects a password the backend would refuse', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildTestableWidget());
      await enterText(tester, 'Password', 'password123');
      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(
        find.text(
          'Use an uppercase letter, a lowercase letter, a digit and a special character.',
        ),
        findsOneWidget,
      );
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('submits RegisterRequested with the chosen account type', (
      tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildTestableWidget());
      await tester.tap(find.text('Brand'));
      await tester.pump();
      await enterText(tester, 'Full Name', 'Brand Owner');
      await enterText(tester, 'Email', 'brand@example.com');
      await enterText(tester, 'Organization Name', 'Acme');
      await enterText(tester, 'Password', 'Passw0rd!');
      await enterText(tester, 'Confirm Password', 'Passw0rd!');
      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      verify(
        () => mockAuthBloc.add(
          const RegisterRequested(
            accountType: AccountType.organization,
            fullName: 'Brand Owner',
            email: 'brand@example.com',
            organisation: 'Acme',
            password: 'Passw0rd!',
          ),
        ),
      ).called(1);
    });

    testWidgets('shows the server message on failure', (tester) async {
      whenListen(
        mockAuthBloc,
        Stream<AuthState>.fromIterable(const [
          AuthLoading(),
          AuthFailure(message: 'An account with this email already exists.'),
        ]),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(
        find.text('An account with this email already exists.'),
        findsOneWidget,
      );
    });
  });
}
