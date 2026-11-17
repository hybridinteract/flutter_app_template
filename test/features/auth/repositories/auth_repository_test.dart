import 'package:app_template/core/constants/storage_keys.dart';
import 'package:app_template/core/error/failure.dart';
import 'package:app_template/core/session/active_workspace_store.dart';
import 'package:app_template/core/session/session_expiry_notifier.dart';
import 'package:app_template/core/storage/local_storage.dart';
import 'package:app_template/core/storage/secure_storage.dart';
import 'package:app_template/features/auth/models/account_type.dart';
import 'package:app_template/features/auth/models/auth_session_model.dart';
import 'package:app_template/features/auth/models/user_model.dart';
import 'package:app_template/features/auth/models/verification_challenge_model.dart';
import 'package:app_template/features/auth/repositories/auth_failures.dart';
import 'package:app_template/features/auth/repositories/auth_repository_impl.dart';
import 'package:app_template/features/auth/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockSecureStorage extends Mock implements SecureStorage {}

class MockLocalStorage extends Mock implements LocalStorage {}

class MockActiveWorkspaceStore extends Mock implements ActiveWorkspaceStore {}

void main() {
  setUpAll(() => registerFallbackValue(AccountType.influencer));

  late MockAuthService mockAuthService;
  late MockSecureStorage mockSecureStorage;
  late MockLocalStorage mockLocalStorage;
  late MockActiveWorkspaceStore mockWorkspaceStore;
  late SessionExpiryNotifier sessionExpiryNotifier;
  late AuthRepositoryImpl repository;

  const testUser = UserModel(
    id: 'user_1',
    name: 'Test User',
    email: 'test@example.com',
  );

  const testSession = AuthSessionModel(
    user: testUser,
    accessToken: 'test_access_token',
    refreshToken: 'test_refresh_token',
  );

  setUp(() {
    mockAuthService = MockAuthService();
    mockSecureStorage = MockSecureStorage();
    mockLocalStorage = MockLocalStorage();
    mockWorkspaceStore = MockActiveWorkspaceStore();
    when(() => mockWorkspaceStore.clear()).thenAnswer((_) async {});
    sessionExpiryNotifier = SessionExpiryNotifier();
    repository = AuthRepositoryImpl(
      mockAuthService,
      mockSecureStorage,
      mockLocalStorage,
      sessionExpiryNotifier,
      mockWorkspaceStore,
    );
  });

  tearDown(() => sessionExpiryNotifier.dispose());

  group('AuthRepositoryImpl', () {
    test(
      'login should save tokens, cache user, and return UserModel on success',
      () async {
        when(
          () => mockAuthService.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => testSession);

        when(
          () => mockSecureStorage.setAccessToken(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockSecureStorage.setRefreshToken(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalStorage.setString(any(), any()),
        ).thenAnswer((_) async => true);

        final result = await repository.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, equals(testUser));
        verify(
          () => mockSecureStorage.setAccessToken('test_access_token'),
        ).called(1);
        verify(
          () => mockSecureStorage.setRefreshToken('test_refresh_token'),
        ).called(1);
        verify(
          () => mockLocalStorage.setString(StorageKeys.user, any()),
        ).called(1);
        // A workspace chosen by a previous account must not carry over.
        verify(() => mockWorkspaceStore.clear()).called(1);
      },
    );

    test(
      'login turns a 403 into EmailNotVerifiedFailure when a new code can be sent',
      () async {
        when(
          () => mockAuthService.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(
          const ForbiddenFailure(
            message: 'Email not verified. Check your inbox for the code.',
          ),
        );
        when(
          () => mockAuthService.resendVerification(email: any(named: 'email')),
        ).thenAnswer(
          (_) async => const VerificationChallengeModel(
            email: 'test@example.com',
            expiresIn: 900,
            devCode: '123456',
          ),
        );

        await expectLater(
          repository.login(email: 'test@example.com', password: 'Passw0rd!'),
          throwsA(
            isA<EmailNotVerifiedFailure>()
                .having((f) => f.email, 'email', 'test@example.com')
                .having((f) => f.challenge.devCode, 'devCode', '123456')
                .having(
                  (f) => f.message,
                  'message',
                  'Email not verified. Check your inbox for the code.',
                ),
          ),
        );
        verifyNever(() => mockSecureStorage.setAccessToken(any()));
      },
    );

    test(
      'login keeps the 403 when the account is already verified (suspended)',
      () async {
        when(
          () => mockAuthService.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(
          const ForbiddenFailure(message: 'User account is inactive'),
        );
        when(
          () => mockAuthService.resendVerification(email: any(named: 'email')),
        ).thenThrow(
          const ValidationFailure(
            message: 'This account is already verified. Please sign in.',
            statusCode: 400,
          ),
        );

        await expectLater(
          repository.login(email: 'test@example.com', password: 'Passw0rd!'),
          throwsA(
            isA<ForbiddenFailure>().having(
              (f) => f.message,
              'message',
              'User account is inactive',
            ),
          ),
        );
      },
    );

    test('register returns the challenge and stores no tokens', () async {
      when(
        () => mockAuthService.signup(
          accountType: any(named: 'accountType'),
          fullName: any(named: 'fullName'),
          email: any(named: 'email'),
          organisation: any(named: 'organisation'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const VerificationChallengeModel(
          email: 'brand@example.com',
          expiresIn: 900,
        ),
      );

      final result = await repository.register(
        accountType: AccountType.organization,
        fullName: 'Brand Owner',
        email: 'brand@example.com',
        organisation: 'Acme',
        password: 'Passw0rd!',
      );

      expect(result.email, 'brand@example.com');
      verify(
        () => mockAuthService.signup(
          accountType: AccountType.organization,
          fullName: 'Brand Owner',
          email: 'brand@example.com',
          organisation: 'Acme',
          password: 'Passw0rd!',
        ),
      ).called(1);
      verifyNever(() => mockSecureStorage.setAccessToken(any()));
    });

    test('register maps service errors to a Failure', () async {
      when(
        () => mockAuthService.signup(
          accountType: any(named: 'accountType'),
          fullName: any(named: 'fullName'),
          email: any(named: 'email'),
          organisation: any(named: 'organisation'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('raw details'));

      expect(
        () => repository.register(
          accountType: AccountType.influencer,
          fullName: 'Creator',
          email: 'c@example.com',
          organisation: '@creator',
          password: 'Passw0rd!',
        ),
        throwsA(isA<UnexpectedFailure>()),
      );
    });

    test('verifyEmail stores tokens, caches the user and returns it', () async {
      when(
        () => mockAuthService.verifyEmail(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      ).thenAnswer((_) async => testSession);
      when(
        () => mockSecureStorage.setAccessToken(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockSecureStorage.setRefreshToken(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockLocalStorage.setString(any(), any()),
      ).thenAnswer((_) async => true);

      final result = await repository.verifyEmail(
        email: 'test@example.com',
        code: '123456',
      );

      expect(result, testUser);
      verify(
        () => mockSecureStorage.setAccessToken('test_access_token'),
      ).called(1);
      verify(
        () => mockSecureStorage.setRefreshToken('test_refresh_token'),
      ).called(1);
      verify(() => mockWorkspaceStore.clear()).called(1);
    });

    test('verifyEmail maps a wrong code to a Failure', () async {
      when(
        () => mockAuthService.verifyEmail(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      ).thenThrow(
        const ValidationFailure(message: 'Invalid code', statusCode: 400),
      );

      expect(
        () => repository.verifyEmail(email: 'test@example.com', code: '0000'),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('resendVerification returns the new challenge', () async {
      when(
        () => mockAuthService.resendVerification(email: any(named: 'email')),
      ).thenAnswer(
        (_) async => const VerificationChallengeModel(
          email: 'test@example.com',
          expiresIn: 900,
        ),
      );

      final result = await repository.resendVerification(
        email: 'test@example.com',
      );

      expect(result.expiresIn, 900);
    });

    test('login should throw Failure when service throws', () async {
      when(
        () => mockAuthService.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthenticationFailure(message: 'Invalid credentials'));

      expect(
        () => repository.login(email: 'test@example.com', password: 'wrong'),
        throwsA(isA<Failure>()),
      );
    });

    test('logout should clear auth tokens and local cached profile', () async {
      when(
        () => mockSecureStorage.getRefreshToken(),
      ).thenAnswer((_) async => 'refresh_token');
      when(
        () => mockAuthService.logout(refreshToken: any(named: 'refreshToken')),
      ).thenAnswer((_) async {});
      when(() => mockSecureStorage.clearAuthTokens()).thenAnswer((_) async {});
      when(() => mockLocalStorage.remove(any())).thenAnswer((_) async => true);

      await repository.logout();

      verify(() => mockSecureStorage.clearAuthTokens()).called(1);
      verify(() => mockLocalStorage.remove(StorageKeys.user)).called(1);
      verify(() => mockWorkspaceStore.clear()).called(1);
    });

    test(
      'isAuthenticated should return true when access token exists',
      () async {
        when(
          () => mockSecureStorage.getAccessToken(),
        ).thenAnswer((_) async => 'valid_token');

        final result = await repository.isAuthenticated();

        expect(result, isTrue);
      },
    );

    test(
      'isAuthenticated should return false when access token is null',
      () async {
        when(
          () => mockSecureStorage.getAccessToken(),
        ).thenAnswer((_) async => null);

        final result = await repository.isAuthenticated();

        expect(result, isFalse);
      },
    );

    test(
      'getCurrentUser returns null and drops the cached user when there is no token',
      () async {
        when(
          () => mockSecureStorage.getAccessToken(),
        ).thenAnswer((_) async => null);
        when(
          () => mockLocalStorage.remove(any()),
        ).thenAnswer((_) async => true);

        final result = await repository.getCurrentUser();

        expect(result, isNull);
        verify(() => mockLocalStorage.remove(StorageKeys.user)).called(1);
        verifyNever(() => mockLocalStorage.getString(any()));
        verifyNever(() => mockAuthService.getCurrentUser());
      },
    );

    test(
      'getCurrentUser returns the cached user when a token exists',
      () async {
        when(
          () => mockSecureStorage.getAccessToken(),
        ).thenAnswer((_) async => 'valid_token');
        when(() => mockLocalStorage.getString(StorageKeys.user)).thenReturn(
          '{"id":"user_1","name":"Test User","email":"test@example.com"}',
        );

        final result = await repository.getCurrentUser();

        expect(result?.id, 'user_1');
        verifyNever(() => mockAuthService.getCurrentUser());
      },
    );

    test('getCurrentUser maps service errors to a Failure', () async {
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => 'valid_token');
      when(() => mockLocalStorage.getString(any())).thenReturn(null);
      when(
        () => mockAuthService.getCurrentUser(),
      ).thenThrow(Exception('socket closed: raw details'));

      expect(
        () => repository.getCurrentUser(),
        throwsA(
          isA<UnexpectedFailure>().having(
            (f) => f.message,
            'message',
            isNot(contains('raw details')),
          ),
        ),
      );
    });

    test('sessionExpired forwards SessionExpiryNotifier events', () async {
      final expectation = expectLater(repository.sessionExpired, emits(null));
      sessionExpiryNotifier.notifyExpired();
      await expectation;
    });

    test('clearSession removes tokens and the cached user', () async {
      when(() => mockSecureStorage.clearAuthTokens()).thenAnswer((_) async {});
      when(() => mockLocalStorage.remove(any())).thenAnswer((_) async => true);

      await repository.clearSession();

      verify(() => mockSecureStorage.clearAuthTokens()).called(1);
      verify(() => mockLocalStorage.remove(StorageKeys.user)).called(1);
      verify(() => mockWorkspaceStore.clear()).called(1);
      verifyNever(
        () => mockAuthService.logout(refreshToken: any(named: 'refreshToken')),
      );
    });
  });
}
