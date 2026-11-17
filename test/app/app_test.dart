import 'package:app_template/app/app_router.dart';
import 'package:app_template/core/config/app_config.dart';
import 'package:app_template/core/constants/app_constants.dart';
import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/theme/app_theme.dart';
import 'package:app_template/features/auth/controllers/auth_bloc.dart';
import 'package:app_template/features/auth/controllers/auth_event.dart';
import 'package:app_template/features/auth/controllers/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  setUpAll(() {
    AppConfig.initialize(baseUrl: 'https://api-test.example.com/v1');
  });

  testWidgets(
    'App root initializes correctly and renders login screen when unauthenticated',
    (tester) async {
      final mockAuthBloc = MockAuthBloc();
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
      when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

      final router = AppRouter.createRouter(mockAuthBloc);

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: MaterialApp.router(
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    },
  );
}
