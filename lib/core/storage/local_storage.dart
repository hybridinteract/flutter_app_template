import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

abstract class LocalStorage {
  String? getThemeMode();
  Future<bool> setThemeMode(String theme);

  String? getLanguage();
  Future<bool> setLanguage(String lang);

  bool isOnboardingCompleted();
  Future<bool> setOnboardingCompleted(bool completed);

  String? getString(String key);
  Future<bool> setString(String key, String value);

  bool? getBool(String key);
  Future<bool> setBool(String key, bool value);

  int? getInt(String key);
  Future<bool> setInt(String key, int value);

  Future<bool> remove(String key);
  Future<bool> clear();
}

class LocalStorageImpl implements LocalStorage {
  LocalStorageImpl(this._preferences);

  final SharedPreferences _preferences;

  @override
  String? getThemeMode() => _preferences.getString(StorageKeys.themeMode);

  @override
  Future<bool> setThemeMode(String theme) =>
      _preferences.setString(StorageKeys.themeMode, theme);

  @override
  String? getLanguage() => _preferences.getString(StorageKeys.language);

  @override
  Future<bool> setLanguage(String lang) =>
      _preferences.setString(StorageKeys.language, lang);

  @override
  bool isOnboardingCompleted() =>
      _preferences.getBool(StorageKeys.isOnboardingCompleted) ?? false;

  @override
  Future<bool> setOnboardingCompleted(bool completed) =>
      _preferences.setBool(StorageKeys.isOnboardingCompleted, completed);

  @override
  String? getString(String key) => _preferences.getString(key);

  @override
  Future<bool> setString(String key, String value) =>
      _preferences.setString(key, value);

  @override
  bool? getBool(String key) => _preferences.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) =>
      _preferences.setBool(key, value);

  @override
  int? getInt(String key) => _preferences.getInt(key);

  @override
  Future<bool> setInt(String key, int value) => _preferences.setInt(key, value);

  @override
  Future<bool> remove(String key) => _preferences.remove(key);

  @override
  Future<bool> clear() => _preferences.clear();
}
