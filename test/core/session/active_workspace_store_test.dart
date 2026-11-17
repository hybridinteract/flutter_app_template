import 'package:app_template/core/constants/storage_keys.dart';
import 'package:app_template/core/session/active_workspace_store.dart';
import 'package:app_template/core/storage/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ActiveWorkspaceStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    store = ActiveWorkspaceStoreImpl(LocalStorageImpl(preferences));
  });

  test('has no workspace until one is set', () {
    expect(store.workspaceId, isNull);
  });

  test('remembers the chosen workspace', () async {
    await store.setWorkspaceId('ws_1');

    expect(store.workspaceId, 'ws_1');
  });

  test('clear forgets it', () async {
    await store.setWorkspaceId('ws_1');
    await store.clear();

    expect(store.workspaceId, isNull);
  });

  test('treats an empty stored value as no workspace', () async {
    SharedPreferences.setMockInitialValues({StorageKeys.activeWorkspaceId: ''});
    final preferences = await SharedPreferences.getInstance();
    store = ActiveWorkspaceStoreImpl(LocalStorageImpl(preferences));

    expect(store.workspaceId, isNull);
  });
}
