import 'package:app_template/features/auth/models/account_type.dart';
import 'package:app_template/features/auth/models/auth_session_model.dart';
import 'package:app_template/features/auth/models/user_model.dart';
import 'package:app_template/features/auth/models/verification_challenge_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Locks the JSON contract with the snake_case backend, so regenerating the
/// `.g.dart` files with build_runner can never silently change payloads.
void main() {
  group('UserModel JSON contract', () {
    test('toJson writes snake_case keys', () {
      final json = UserModel(
        id: 'u1',
        name: 'Jane',
        email: 'jane@example.com',
        isSuperuser: true,
        avatarUrl: 'https://cdn.example.com/a.png',
        createdAt: DateTime.utc(2026, 1, 2, 3, 4, 5),
      ).toJson();

      expect(json['is_superuser'], isTrue);
      expect(json['is_active'], isTrue);
      expect(json['avatar_url'], 'https://cdn.example.com/a.png');
      expect(json['created_at'], '2026-01-02T03:04:05.000Z');
      expect(json['role'], 'member');
      expect(
        json.keys,
        isNot(contains(anyOf('isSuperuser', 'isActive', 'avatarUrl'))),
      );
      expect(json.keys, isNot(contains('createdAt')));
    });

    test('fromJson reads snake_case keys', () {
      final user = UserModel.fromJson(const {
        'id': 'u1',
        'full_name': 'Jane Doe',
        'email': 'jane@example.com',
        'is_superuser': true,
        'is_active': false,
        'avatar_url': 'a.png',
        'created_at': '2026-01-02T03:04:05.000Z',
      });

      expect(user.name, 'Jane Doe');
      expect(user.isSuperuser, isTrue);
      expect(user.isActive, isFalse);
      expect(user.avatarUrl, 'a.png');
      expect(user.createdAt, DateTime.utc(2026, 1, 2, 3, 4, 5));
    });

    test('fromJson also accepts camelCase keys', () {
      final user = UserModel.fromJson(const {
        'id': 'u1',
        'name': 'Jane',
        'email': 'jane@example.com',
        'isSuperuser': true,
        'isActive': false,
        'avatarUrl': 'a.png',
        'createdAt': '2026-01-02T03:04:05.000Z',
      });

      expect(user.isSuperuser, isTrue);
      expect(user.isActive, isFalse);
      expect(user.avatarUrl, 'a.png');
      expect(user.createdAt, DateTime.utc(2026, 1, 2, 3, 4, 5));
    });

    test('fromJson reads the Influen /auth/me fields', () {
      final user = UserModel.fromJson(const {
        'id': 'u1',
        'full_name': 'Jane Doe',
        'email': 'jane@example.com',
        'status': 'active',
        'email_verified': true,
        'is_active': true,
        'is_superuser': false,
        'roles': ['organization'],
        'permissions': ['campaigns:read'],
        'account_type': 'organization',
        'organization_name': 'Acme',
        'social_handle': null,
        'created_at': '2026-01-02T03:04:05Z',
        'updated_at': '2026-01-02T03:04:05Z',
      });

      expect(user.accountType, AccountType.organization);
      expect(user.isOrganization, isTrue);
      expect(user.isInfluencer, isFalse);
      expect(user.emailVerified, isTrue);
      expect(user.organizationName, 'Acme');
      expect(user.socialHandle, isNull);
    });

    test('an unknown or missing account_type reads as null', () {
      final unknown = UserModel.fromJson(const {
        'id': 'u1',
        'email': 'a@b.com',
        'account_type': 'something_new',
      });
      final missing = UserModel.fromJson(const {
        'id': 'u1',
        'email': 'a@b.com',
      });

      expect(unknown.accountType, isNull);
      expect(missing.accountType, isNull);
    });

    test('toJson writes account_type as the backend value', () {
      const user = UserModel(
        id: 'u1',
        name: 'Jane',
        email: 'jane@example.com',
        accountType: AccountType.influencer,
        socialHandle: '@jane',
      );
      final json = user.toJson();

      expect(json['account_type'], 'influencer');
      expect(json['social_handle'], '@jane');
      expect(UserModel.fromJson(json), user);
    });

    test('fromJson round-trips toJson output', () {
      final original = UserModel(
        id: 'u1',
        name: 'Jane',
        email: 'jane@example.com',
        roles: const ['admin'],
        permissions: const ['users:read'],
        createdAt: DateTime.utc(2026, 1, 2),
      );
      expect(UserModel.fromJson(original.toJson()), original);
    });
  });

  group('VerificationChallengeModel JSON contract', () {
    test('reads the signup response', () {
      final challenge = VerificationChallengeModel.fromJson(const {
        'user_id': '6f1c0e1e-0000-0000-0000-000000000000',
        'email': 'jane@example.com',
        'verification_required': true,
        'expires_in': 900,
        'dev_code': '123456',
      });

      expect(challenge.email, 'jane@example.com');
      expect(challenge.expiresIn, 900);
      expect(challenge.devCode, '123456');
    });

    test('reads the resend response, which has no email or dev code', () {
      final challenge = VerificationChallengeModel.fromJson(const {
        'status': 'sent',
        'expires_in': 900,
        'dev_code': null,
      });

      expect(challenge.email, isNull);
      expect(challenge.expiresIn, 900);
      expect(challenge.devCode, isNull);
    });
  });

  group('AuthSessionModel JSON contract', () {
    test('fromJson reads snake_case and camelCase token keys', () {
      final snake = AuthSessionModel.fromJson(const {
        'access_token': 'a',
        'refresh_token': 'r',
        'token_type': 'bearer',
      });
      final camel = AuthSessionModel.fromJson(const {
        'accessToken': 'a',
        'refreshToken': 'r',
      });
      expect(snake, camel);
      expect(snake.accessToken, 'a');
      expect(snake.refreshToken, 'r');
    });

    test('toJson serializes the nested user as a map', () {
      const session = AuthSessionModel(
        accessToken: 'a',
        user: UserModel(id: 'u1', name: 'Jane', email: 'jane@example.com'),
      );
      final json = session.toJson();
      expect(json['user'], isA<Map<String, dynamic>>());
      expect((json['user'] as Map<String, dynamic>)['is_active'], isTrue);
    });
  });
}
