import 'package:app_template/core/constants/app_constants.dart';
import 'package:app_template/core/di/service_locator.dart';
import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/theme/app_theme.dart';
import 'package:app_template/features/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';

/// Root widget. Only app-wide BLoCs are provided here (currently [AuthBloc],
/// which the router redirect depends on). Feature BLoCs are provided by their
/// own routes in `<feature>_routes.dart`.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>()..add(const CheckAuthStatusRequested());
    _router = AppRouter.createRouter(_authBloc);
  }

  @override
  void dispose() {
    _router.dispose();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _router,
      ),
    );
  }
}
