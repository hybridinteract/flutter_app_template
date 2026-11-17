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

    test('should support value equality', () {
      const sameUser = UserModel(
        id: 'user_1',
        name: 'Alice Smith',
        email: 'alice@example.com',
        roles: ['admin'],
        permissions: ['users:read', 'users:create'],
      );

      expect(testUser, equals(sameUser));
    });

    test(
      'should deserialize from json correctly with roles and permissions',
      () {
        final json = {
          'id': 'user_1',
          'name': 'Alice Smith',
          'email': 'alice@example.com',
          'roles': ['admin'],
          'permissions': ['users:read', 'users:create'],
        };

        final result = UserModel.fromJson(json);
        expect(result, equals(testUser));
        expect(result.role, equals('admin'));
      },
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

    test('should serialize to json correctly', () {
      final json = testUser.toJson();

      expect(json['id'], equals('user_1'));
      expect(json['name'], equals('Alice Smith'));
      expect(json['email'], equals('alice@example.com'));
      expect(json['roles'], equals(['admin']));
      expect(json['permissions'], equals(['users:read', 'users:create']));
      expect(json['role'], equals('admin'));
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

    test('copyWith should update fields correctly', () {
      final updated = testUser.copyWith(name: 'Alice Johnson');

      expect(updated.name, equals('Alice Johnson'));
      expect(updated.id, equals(testUser.id));
      expect(updated.email, equals(testUser.email));
      expect(updated.roles, equals(testUser.roles));
      expect(updated.permissions, equals(testUser.permissions));
    });
  });
}
