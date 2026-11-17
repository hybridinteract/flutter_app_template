import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

abstract class SecureStorage {
  Future<String?> getAccessToken();
  Future<void> setAccessToken(String token);
  Future<String?> getRefreshToken();
  Future<void> setRefreshToken(String token);
  Future<void> clearAuthTokens();
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

class SecureStorageImpl implements SecureStorage {
  SecureStorageImpl(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> getAccessToken() =>
      _storage.read(key: StorageKeys.accessToken);

  @override
  Future<void> setAccessToken(String token) =>
      _storage.write(key: StorageKeys.accessToken, value: token);

  @override
  Future<String?> getRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  @override
  Future<void> setRefreshToken(String token) =>
      _storage.write(key: StorageKeys.refreshToken, value: token);

  @override
  Future<void> clearAuthTokens() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}
