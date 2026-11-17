class AppConfig {
  AppConfig._({required this.baseUrl, required this.enableLogging});

  final String baseUrl;
  final bool enableLogging;

  static AppConfig? _instance;

  static AppConfig get instance {
    if (_instance == null) {
      throw StateError(
        'AppConfig is not initialized! Call AppConfig.initialize() before accessing AppConfig.instance.',
      );
    }
    return _instance!;
  }

  static void initialize({String? baseUrl, bool? enableLogging}) {
    // 1. Read compile-time environment flags from .env via --dart-define-from-file
    const envBaseUrl = String.fromEnvironment('BASE_URL');
    const hasEnvLogging = bool.hasEnvironment('ENABLE_LOGGING');
    const envLogging = bool.fromEnvironment('ENABLE_LOGGING');

    // 2. Base URL must come from .env (or explicit parameter override for tests)
    final resolvedBaseUrl =
        baseUrl ?? (envBaseUrl.isNotEmpty ? envBaseUrl : '');

    if (resolvedBaseUrl.isEmpty) {
      throw StateError(
        'BASE_URL is not defined! Please provide BASE_URL in your .env file and run with --dart-define-from-file=.env',
      );
    }

    // 3. Resolve Logging flag: override > .env > default (true)
    final resolvedEnableLogging =
        enableLogging ?? (hasEnvLogging ? envLogging : true);

    _instance = AppConfig._(
      baseUrl: resolvedBaseUrl,
      enableLogging: resolvedEnableLogging,
    );
  }
}
