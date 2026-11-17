import '../constants/storage_keys.dart';
import '../storage/local_storage.dart';

/// Which brand workspace the signed-in organization account is working in.
///
/// The backend scopes brand data by the `X-Workspace-Id` header, and
/// [ApiInterceptor] attaches it from here on every request. Creator
/// (influencer) accounts never set one, so they never send the header.
///
/// The id is not a secret (it is a row id the user can already see), so it
/// lives in [LocalStorage]. Reads are synchronous so the interceptor can use
/// them without awaiting.
///
/// It must not outlive the account that chose it: the auth repository clears
/// it on login, logout and session expiry. A stale id from a previous account
/// would make every brand request 404.
abstract class ActiveWorkspaceStore {
  String? get workspaceId;

  Future<void> setWorkspaceId(String workspaceId);

  Future<void> clear();
}

class ActiveWorkspaceStoreImpl implements ActiveWorkspaceStore {
  ActiveWorkspaceStoreImpl(this._localStorage);

  final LocalStorage _localStorage;

  @override
  String? get workspaceId {
    final id = _localStorage.getString(StorageKeys.activeWorkspaceId);
    return id == null || id.isEmpty ? null : id;
  }

  @override
  Future<void> setWorkspaceId(String workspaceId) =>
      _localStorage.setString(StorageKeys.activeWorkspaceId, workspaceId);

  @override
  Future<void> clear() => _localStorage.remove(StorageKeys.activeWorkspaceId);
}
