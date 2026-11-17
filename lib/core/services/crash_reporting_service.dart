import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

abstract class CrashReportingService {
  Future<void> initialize();
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  });
  Future<void> log(String message);
  Future<void> setUserId(String userId);
}

class CrashReportingServiceImpl implements CrashReportingService {
  bool _isFirebaseAvailable = false;

  /// Initializes Firebase and routes uncaught errors to Crashlytics.
  ///
  /// Requires the platform Firebase config (run `flutterfire configure`, which
  /// adds google-services.json / GoogleService-Info.plist). Without it the app
  /// still runs and errors are printed in debug mode instead.
  @override
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      );
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      _isFirebaseAvailable = true;
    } catch (e) {
      debugPrint('[CrashReporting] Firebase Crashlytics unavailable: $e');
      _isFirebaseAvailable = false;
    }
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  }) async {
    if (_isFirebaseAvailable) {
      await FirebaseCrashlytics.instance.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );
    } else if (kDebugMode) {
      debugPrint('[ERROR] $exception\nStackTrace: $stack');
    }
  }

  @override
  Future<void> log(String message) async {
    if (_isFirebaseAvailable) {
      await FirebaseCrashlytics.instance.log(message);
    } else if (kDebugMode) {
      debugPrint('[LOG] $message');
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    if (_isFirebaseAvailable) {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    }
  }
}
