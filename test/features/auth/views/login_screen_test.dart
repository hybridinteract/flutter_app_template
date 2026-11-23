import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/features/auth/controllers/auth_bloc.dart';
import 'package:app_template/features/auth/controllers/auth_event.dart';
import 'package:app_template/features/auth/controllers/auth_state.dart';
import 'package:app_template/features/auth/views/login_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<AuthBloc>.value(value: mockAuthBloc, child: child),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets(
      'displays validation errors when fields are empty and submit is tapped',
      (tester) async {
        when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

        await tester.tap(find.text('Sign In'));
        await tester.pump();

        expect(find.text('Email is required.'), findsOneWidget);
        expect(find.text('Password is required.'), findsOneWidget);
      },
    );
  });
}
