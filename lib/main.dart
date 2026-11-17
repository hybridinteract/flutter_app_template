import 'package:app_template/app/app.dart';
import 'package:app_template/app/injection_container.dart';
import 'package:app_template/core/config/app_config.dart';
import 'package:app_template/core/di/service_locator.dart';
import 'package:app_template/core/services/crash_reporting_service.dart';
import 'package:app_template/core/utils/app_bloc_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Environment config from .env (--dart-define-from-file=.env)
  AppConfig.initialize();

  // 2. Global BLoC observer for debug logging
  Bloc.observer = const AppBlocObserver();

  // 3. Dependency injection
  await setupDependencies();

  // 4. Crash reporting (Firebase Crashlytics, falls back to debug logs)
  await getIt<CrashReportingService>().initialize();

  runApp(const App());
}
