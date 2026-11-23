import 'package:app_template/features/auth/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    const testUser = UserModel(
      id: 'user_1',
      name: 'Alice Smith',
      email: 'alice@example.com',
      roles: ['admin'],
      permissions: ['users:read', 'users:create'],
    );

    test('should support legacy single role json format', () {
      final json = {
        'id': 'user_1',
        'name': 'Alice Smith',
        'email': 'alice@example.com',
        'role': 'admin',
      };

      final result = UserModel.fromJson(json);
      expect(result.roles, equals(['admin']));
      expect(result.role, equals('admin'));
    });

    test('RBAC: hasPermission verifies atomic permissions', () {
      expect(testUser.hasPermission('users:read'), isTrue);
      expect(testUser.hasPermission('users:create'), isTrue);
      expect(testUser.hasPermission('users:delete'), isFalse);
    });

    test(
      'RBAC: developer_admin automatically bypasses all permission checks',
      () {
        const devAdmin = UserModel(
          id: 'super_1',
          name: 'Super Dev',
          email: 'dev@example.com',
          roles: ['developer_admin'],
          permissions: [],
        );

        expect(devAdmin.isDeveloperAdmin, isTrue);
        expect(devAdmin.hasPermission('anything:action'), isTrue);
        expect(devAdmin.hasPermission('users:delete'), isTrue);
        expect(devAdmin.hasAnyPermission(['a:b', 'c:d']), isTrue);
        expect(devAdmin.hasAllPermissions(['a:b', 'c:d']), isTrue);
      },
    );
  });
}
