import 'dart:async';

import 'package:app_template/core/error/failure.dart';
import 'package:app_template/features/auth/controllers/auth_bloc.dart';
import 'package:app_template/features/auth/controllers/auth_event.dart';
import 'package:app_template/features/auth/controllers/auth_state.dart';
import 'package:app_template/features/auth/models/account_type.dart';
import 'package:app_template/features/auth/models/user_model.dart';
import 'package:app_template/features/auth/models/verification_challenge_model.dart';
import 'package:app_template/features/auth/repositories/auth_failures.dart';
import 'package:app_template/features/auth/repositories/auth_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() => registerFallbackValue(AccountType.influencer));

  late MockAuthRepository mockAuthRepository;
  late StreamController<void> sessionExpiredController;

  const testUser = UserModel(
    id: 'user_1',
    name: 'Jane Doe',
    email: 'jane@example.com',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    sessionExpiredController = StreamController<void>.broadcast();
    when(
      () => mockAuthRepository.sessionExpired,
    ).thenAnswer((_) => sessionExpiredController.stream);
  });

  tearDown(() => sessionExpiredController.close());

  group('AuthBloc', () {
    test('initial state should be AuthInitial', () {
      final bloc = AuthBloc(mockAuthRepository);
      expect(bloc.state, equals(const AuthInitial()));
      bloc.close();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when CheckAuthStatusRequested finds logged in user',
      build: () {
        when(
          () => mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => testUser);
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(const CheckAuthStatusRequested()),
      expect: () => [const AuthLoading(), const AuthSuccess(user: testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when CheckAuthStatusRequested finds no user',
      build: () {
        when(
          () => mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => null);
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(const CheckAuthStatusRequested()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when LoginRequested succeeds',
      build: () {
        when(
          () => mockAuthRepository.login(
            email: 'jane@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => testUser);
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const LoginRequested(
          email: 'jane@example.com',
          password: 'password123',
        ),
      ),
      expect: () => [const AuthLoading(), const AuthSuccess(user: testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when LoginRequested fails',
      build: () {
        when(
          () => mockAuthRepository.login(
            email: 'jane@example.com',
            password: 'wrong',
          ),
        ).thenThrow(
          const AuthenticationFailure(message: 'Invalid email or password.'),
        );
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const LoginRequested(email: 'jane@example.com', password: 'wrong'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailure(message: 'Invalid email or password.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthVerificationRequired] when login finds the email unverified',
      build: () {
        when(
          () => mockAuthRepository.login(
            email: 'jane@example.com',
            password: 'Passw0rd!',
          ),
        ).thenThrow(
          const EmailNotVerifiedFailure(
            email: 'jane@example.com',
            challenge: VerificationChallengeModel(
              email: 'jane@example.com',
              expiresIn: 900,
              devCode: '123456',
            ),
            message: 'Email not verified. Check your inbox for the code.',
          ),
        );
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const LoginRequested(email: 'jane@example.com', password: 'Passw0rd!'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthVerificationRequired(
          email: 'jane@example.com',
          devCode: '123456',
          message: 'Email not verified. Check your inbox for the code.',
        ),
      ],
    );

    const registerEvent = RegisterRequested(
      accountType: AccountType.influencer,
      fullName: 'Jane Doe',
      email: 'jane@example.com',
      organisation: '@jane',
      password: 'Passw0rd!',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthVerificationRequired] when RegisterRequested succeeds',
      build: () {
        when(
          () => mockAuthRepository.register(
            accountType: AccountType.influencer,
            fullName: 'Jane Doe',
            email: 'jane@example.com',
            organisation: '@jane',
            password: 'Passw0rd!',
          ),
        ).thenAnswer(
          (_) async => const VerificationChallengeModel(
            email: 'jane@example.com',
            expiresIn: 900,
          ),
        );
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(registerEvent),
      expect: () => [
        const AuthLoading(),
        const AuthVerificationRequired(email: 'jane@example.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when RegisterRequested fails',
      build: () {
        when(
          () => mockAuthRepository.register(
            accountType: any(named: 'accountType'),
            fullName: any(named: 'fullName'),
            email: any(named: 'email'),
            organisation: any(named: 'organisation'),
            password: any(named: 'password'),
          ),
        ).thenThrow(
          const ValidationFailure(message: 'An account already exists.'),
        );
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(registerEvent),
      expect: () => [
        const AuthLoading(),
        const AuthFailure(message: 'An account already exists.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when VerifyEmailRequested succeeds',
      build: () {
        when(
          () => mockAuthRepository.verifyEmail(
            email: 'jane@example.com',
            code: '123456',
          ),
        ).thenAnswer((_) async => testUser);
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const VerifyEmailRequested(email: 'jane@example.com', code: '123456'),
      ),
      expect: () => [const AuthLoading(), const AuthSuccess(user: testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when VerifyEmailRequested fails',
      build: () {
        when(
          () => mockAuthRepository.verifyEmail(
            email: any(named: 'email'),
            code: any(named: 'code'),
          ),
        ).thenThrow(const ValidationFailure(message: 'Invalid code.'));
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const VerifyEmailRequested(email: 'jane@example.com', code: '0000'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailure(message: 'Invalid code.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthVerificationCodeResent] when ResendVerificationRequested succeeds',
      build: () {
        when(
          () =>
              mockAuthRepository.resendVerification(email: 'jane@example.com'),
        ).thenAnswer(
          (_) async => const VerificationChallengeModel(
            email: 'jane@example.com',
            expiresIn: 900,
            devCode: '654321',
          ),
        );
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const ResendVerificationRequested(email: 'jane@example.com'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthVerificationCodeResent(
          email: 'jane@example.com',
          devCode: '654321',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when ResendVerificationRequested is throttled',
      build: () {
        when(
          () =>
              mockAuthRepository.resendVerification(email: any(named: 'email')),
        ).thenThrow(const RateLimitFailure(message: 'Too many requests.'));
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const ResendVerificationRequested(email: 'jane@example.com'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailure(message: 'Too many requests.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when LogoutRequested succeeds',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'clears the session and emits [AuthUnauthenticated] when the repository reports session expiry',
      build: () {
        when(() => mockAuthRepository.clearSession()).thenAnswer((_) async {});
        return AuthBloc(mockAuthRepository);
      },
      seed: () => const AuthSuccess(user: testUser),
      act: (_) => sessionExpiredController.add(null),
      expect: () => [const AuthUnauthenticated()],
      verify: (_) {
        verify(() => mockAuthRepository.clearSession()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'still signs out when clearing the session fails',
      build: () {
        when(
          () => mockAuthRepository.clearSession(),
        ).thenThrow(const StorageFailure());
        return AuthBloc(mockAuthRepository);
      },
      seed: () => const AuthSuccess(user: testUser),
      act: (bloc) => bloc.add(const SessionExpired()),
      expect: () => [const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'ignores session expiry when already signed out',
      build: () => AuthBloc(mockAuthRepository),
      seed: () => const AuthUnauthenticated(),
      act: (bloc) => bloc.add(const SessionExpired()),
      expect: () => <AuthState>[],
      verify: (_) {
        verifyNever(() => mockAuthRepository.clearSession());
      },
    );
  });
}
