import 'package:app_template/core/di/service_locator.dart';
import 'package:app_template/core/network/api_interceptor.dart';
import 'package:app_template/core/network/dio_client.dart';
import 'package:app_template/core/network/network_info.dart';
import 'package:app_template/core/services/crash_reporting_service.dart';
import 'package:app_template/core/session/active_workspace_store.dart';
import 'package:app_template/core/session/session_expiry_notifier.dart';
import 'package:app_template/core/storage/local_storage.dart';
import 'package:app_template/core/storage/secure_storage.dart';
import 'package:app_template/features/auth/controllers/auth_bloc.dart';
import 'package:app_template/features/auth/repositories/auth_repository.dart';
import 'package:app_template/features/auth/repositories/auth_repository_impl.dart';
import 'package:app_template/features/auth/services/auth_service.dart';
import 'package:app_template/features/booking/controllers/booking_bloc.dart';
import 'package:app_template/features/booking/repositories/booking_repository.dart';
import 'package:app_template/features/booking/repositories/booking_repository_impl.dart';
import 'package:app_template/features/booking/services/booking_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registers every dependency. Order: External -> Storage -> Core -> then one
/// block per feature (Service -> Repository -> BLoC).
Future<void> setupDependencies() async {
  // ─── External & Platform ────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  // ─── Storage ────────────────────────────────────────────────────────
  getIt.registerLazySingleton<LocalStorage>(
    () => LocalStorageImpl(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<SecureStorage>(
    () => SecureStorageImpl(getIt<FlutterSecureStorage>()),
  );

  // ─── Core: crash reporting, session, network ────────────────────────
  getIt.registerLazySingleton<CrashReportingService>(
    CrashReportingServiceImpl.new,
  );
  getIt.registerLazySingleton<SessionExpiryNotifier>(SessionExpiryNotifier.new);
  getIt.registerLazySingleton<ActiveWorkspaceStore>(
    () => ActiveWorkspaceStoreImpl(getIt<LocalStorage>()),
  );
  getIt.registerLazySingleton<NetworkInfo>(NetworkInfoImpl.new);
  getIt.registerLazySingleton<ApiInterceptor>(
    () => ApiInterceptor(
      secureStorage: getIt<SecureStorage>(),
      sessionExpiryNotifier: getIt<SessionExpiryNotifier>(),
      activeWorkspaceStore: getIt<ActiveWorkspaceStore>(),
    ),
  );
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(interceptor: getIt<ApiInterceptor>()),
  );

  // ─── Feature: auth ──────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthService>(),
      getIt<SecureStorage>(),
      getIt<LocalStorage>(),
      getIt<SessionExpiryNotifier>(),
      getIt<ActiveWorkspaceStore>(),
    ),
  );
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));

  // ─── Feature: booking ───────────────────────────────────────────────
  getIt.registerLazySingleton<BookingService>(
    () => BookingService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(getIt<BookingService>()),
  );
  getIt.registerFactory<BookingBloc>(
    () => BookingBloc(getIt<BookingRepository>()),
  );
}
