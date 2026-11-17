import 'dart:convert';

import 'package:app_template/core/constants/storage_keys.dart';
import 'package:app_template/core/error/failure.dart';
import 'package:app_template/core/session/active_workspace_store.dart';
import 'package:app_template/core/session/session_expiry_notifier.dart';
import 'package:app_template/core/storage/local_storage.dart';
import 'package:app_template/core/storage/secure_storage.dart';

import '../models/account_type.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';
import '../models/verification_challenge_model.dart';
import '../services/auth_service.dart';
import 'auth_failures.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._authService,
    this._secureStorage,
    this._localStorage,
    this._sessionExpiryNotifier,
    this._activeWorkspaceStore,
  );

  final AuthService _authService;
  final SecureStorage _secureStorage;
  final LocalStorage _localStorage;
  final SessionExpiryNotifier _sessionExpiryNotifier;
  final ActiveWorkspaceStore _activeWorkspaceStore;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final AuthSessionModel session;
      try {
        session = await _authService.login(email: email, password: password);
      } catch (e) {
        final failure = mapExceptionToFailure(e);
        if (failure is ForbiddenFailure) {
          throw await _classifyForbiddenLogin(email, failure);
        }
        throw failure;
      }
      return await _startSession(session);
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }

  /// Login answered 403: either the email is unverified or the account is
  /// suspended. Asking for a new code succeeds only for an unverified account
  /// (a verified one answers 400), and it also gives the user the fresh code
  /// they need. Any other outcome keeps the original 403 and its message.
  Future<Failure> _classifyForbiddenLogin(
    String email,
    ForbiddenFailure loginFailure,
  ) async {
    try {
      final challenge = await _authService.resendVerification(email: email);
      return EmailNotVerifiedFailure(
        email: email,
        challenge: challenge,
        message: loginFailure.message,
      );
    } on Object {
      // Already verified (so: suspended), throttled or offline. The login
      // failure is the answer the user needs; this probe's error is not.
      return loginFailure;
    }
  }

  @override
  Future<VerificationChallengeModel> register({
    required AccountType accountType,
    required String fullName,
    required String email,
    required String organisation,
    required String password,
  }) async {
    try {
      final challenge = await _authService.signup(
        accountType: accountType,
        fullName: fullName,
        email: email,
        organisation: organisation,
        password: password,
      );
      return challenge.email == null
          ? challenge.copyWith(email: email)
          : challenge;
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }

  @override
  Future<UserModel> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final session = await _authService.verifyEmail(email: email, code: code);
      return await _startSession(session);
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }

  @override
  Future<VerificationChallengeModel> resendVerification({
    required String email,
  }) async {
    try {
      return await _authService.resendVerification(email: email);
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }

  /// Stores the tokens, loads `/auth/me` and caches it. A workspace chosen by
  /// a previous account must not ride on this one's requests, so it is
  /// dropped first.
  Future<UserModel> _startSession(AuthSessionModel session) async {
    await _activeWorkspaceStore.clear();
    await _secureStorage.setAccessToken(session.accessToken);
    if (session.refreshToken != null) {
      await _secureStorage.setRefreshToken(session.refreshToken!);
    }

    final user = session.user ?? await _authService.getCurrentUser();
    await _localStorage.setString(StorageKeys.user, jsonEncode(user.toJson()));
    return user;
  }

  @override
  Future<void> logout() async {
    try {
      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        await _authService.logout(refreshToken: refreshToken);
      } catch (_) {
        // Even if remote logout fails, clear local tokens & user cache
      }
      await clearSession();
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // No token means no session, even if a user profile is still cached.
      final token = await _secureStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        await _localStorage.remove(StorageKeys.user);
        return null;
      }

      final cachedUserStr = _localStorage.getString(StorageKeys.user);
      if (cachedUserStr != null && cachedUserStr.isNotEmpty) {
        try {
          final json = jsonDecode(cachedUserStr) as Map<String, dynamic>;
          return UserModel.fromJson(json);
        } on Object {
          // Corrupt cache is not fatal: fall through and fetch from the API.
          await _localStorage.remove(StorageKeys.user);
        }
      }

      final user = await _authService.getCurrentUser();
      await _localStorage.setString(
        StorageKeys.user,
        jsonEncode(user.toJson()),
      );
      return user;
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await _secureStorage.getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<void> get sessionExpired => _sessionExpiryNotifier.onExpired;

  @override
  Future<void> clearSession() async {
    try {
      await _secureStorage.clearAuthTokens();
      await _localStorage.remove(StorageKeys.user);
      await _activeWorkspaceStore.clear();
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }
}
