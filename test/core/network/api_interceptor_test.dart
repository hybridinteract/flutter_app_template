import 'dart:convert';
import 'dart:typed_data';

import 'package:app_template/core/config/app_config.dart';
import 'package:app_template/core/constants/api_constants.dart';
import 'package:app_template/core/network/api_interceptor.dart';
import 'package:app_template/core/session/active_workspace_store.dart';
import 'package:app_template/core/session/session_expiry_notifier.dart';
import 'package:app_template/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory [SecureStorage] so token state can be inspected.
class _FakeSecureStorage implements SecureStorage {
  _FakeSecureStorage({this.accessToken, this.refreshToken});

  String? accessToken;
  String? refreshToken;

  @override
  Future<String?> getAccessToken() async => accessToken;
  @override
  Future<void> setAccessToken(String token) async => accessToken = token;
  @override
  Future<String?> getRefreshToken() async => refreshToken;
  @override
  Future<void> setRefreshToken(String token) async => refreshToken = token;
  @override
  Future<void> clearAuthTokens() async {
    accessToken = null;
    refreshToken = null;
  }

  @override
  Future<void> write(String key, String value) async {}
  @override
  Future<String?> read(String key) async => null;
  @override
  Future<void> delete(String key) async {}
  @override
  Future<void> deleteAll() async {}
}

class _FakeWorkspaceStore implements ActiveWorkspaceStore {
  _FakeWorkspaceStore([this.workspaceId]);

  @override
  String? workspaceId;

  @override
  Future<void> setWorkspaceId(String id) async => workspaceId = id;

  @override
  Future<void> clear() async => workspaceId = null;
}

/// Fake server: protected endpoints accept only `new_access`; the refresh
/// endpoint succeeds or fails depending on [refreshSucceeds].
class _FakeServer implements HttpClientAdapter {
  _FakeServer({this.refreshSucceeds = true});

  final bool refreshSucceeds;
  int refreshCalls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));

    if (options.path == ApiConstants.refreshToken) {
      refreshCalls++;
      return refreshSucceeds
          ? _json(200, {
              'access_token': 'new_access',
              'refresh_token': 'new_refresh',
            })
          : _json(401, {'message': 'Refresh token expired'});
    }

    final authorized = options.headers['Authorization'] == 'Bearer new_access';
    return authorized
        ? _json(200, {
            'ok': true,
            'workspace': options.headers[ApiConstants.workspaceIdHeader],
          })
        : _json(401, {'message': 'Token expired'});
  }

  @override
  void close({bool force = false}) {}

  static ResponseBody _json(int status, Object body) => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  const baseUrl = 'https://api-test.example.com/v1';

  setUpAll(() {
    AppConfig.initialize(baseUrl: baseUrl, enableLogging: false);
  });

  late _FakeSecureStorage storage;
  late SessionExpiryNotifier notifier;

  Dio buildClient(_FakeServer server, {ActiveWorkspaceStore? workspaces}) {
    final refreshDio = Dio(BaseOptions(baseUrl: baseUrl))
      ..httpClientAdapter = server;
    return Dio(BaseOptions(baseUrl: baseUrl))
      ..httpClientAdapter = server
      ..interceptors.add(
        ApiInterceptor(
          secureStorage: storage,
          sessionExpiryNotifier: notifier,
          activeWorkspaceStore: workspaces,
          refreshDio: refreshDio,
        ),
      );
  }

  setUp(() {
    storage = _FakeSecureStorage(
      accessToken: 'old_access',
      refreshToken: 'old_refresh',
    );
    notifier = SessionExpiryNotifier();
  });

  tearDown(() => notifier.dispose());

  test('attaches the stored access token to requests', () async {
    storage.accessToken = 'new_access';
    final server = _FakeServer();

    final response = await buildClient(server).get<dynamic>('/bookings');

    expect(response.statusCode, 200);
    expect(server.refreshCalls, 0);
  });

  group('X-Workspace-Id', () {
    setUp(() => storage.accessToken = 'new_access');

    test('is attached when a workspace is active', () async {
      final dio = buildClient(
        _FakeServer(),
        workspaces: _FakeWorkspaceStore('ws_1'),
      );

      final response = await dio.get<dynamic>('/campaigns');

      expect((response.data as Map)['workspace'], 'ws_1');
    });

    test('is not sent when no workspace is active', () async {
      final dio = buildClient(_FakeServer(), workspaces: _FakeWorkspaceStore());

      final response = await dio.get<dynamic>('/campaigns');

      expect((response.data as Map)['workspace'], isNull);
    });

    test('is not sent on the workspace discovery routes', () async {
      final dio = buildClient(
        _FakeServer(),
        workspaces: _FakeWorkspaceStore('ws_1'),
      );

      final list = await dio.get<dynamic>(ApiConstants.workspaces);
      final options = await dio.get<dynamic>(ApiConstants.workspaceOptions);

      expect((list.data as Map)['workspace'], isNull);
      expect((options.data as Map)['workspace'], isNull);
    });
  });

  test('concurrent 401s trigger exactly one token refresh', () async {
    final server = _FakeServer();
    final dio = buildClient(server);

    final responses = await Future.wait([
      dio.get<dynamic>('/bookings'),
      dio.get<dynamic>('/bookings/1'),
      dio.get<dynamic>('/auth/me'),
    ]);

    expect(responses.map((r) => r.statusCode), everyElement(200));
    expect(server.refreshCalls, 1);
    expect(storage.accessToken, 'new_access');
    expect(storage.refreshToken, 'new_refresh');
  });

  test(
    'failed refresh clears tokens, reports session expiry and rethrows',
    () async {
      final server = _FakeServer(refreshSucceeds: false);
      final dio = buildClient(server);
      var expiredEvents = 0;
      final subscription = notifier.onExpired.listen((_) => expiredEvents++);

      await expectLater(
        dio.get<dynamic>('/bookings'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(server.refreshCalls, 1);
      expect(storage.accessToken, isNull);
      expect(storage.refreshToken, isNull);
      expect(expiredEvents, 1);
      await subscription.cancel();
    },
  );

  test('does not try to refresh when the login endpoint returns 401', () async {
    final server = _FakeServer();
    final dio = buildClient(server);

    await expectLater(
      dio.post<dynamic>(ApiConstants.login, data: {'email': 'a@b.c'}),
      throwsA(isA<DioException>()),
    );

    expect(server.refreshCalls, 0);
    expect(storage.accessToken, 'old_access');
  });
}
