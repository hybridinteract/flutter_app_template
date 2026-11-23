import 'dart:async';

import 'package:app_template/core/error/failure.dart';
import 'package:app_template/features/auth/controllers/auth_bloc.dart';
import 'package:app_template/features/auth/controllers/auth_event.dart';
import 'package:app_template/features/auth/controllers/auth_state.dart';
import 'package:app_template/features/auth/models/user_model.dart';
import 'package:app_template/features/auth/models/verification_challenge_model.dart';
import 'package:app_template/features/auth/repositories/auth_failures.dart';
import 'package:app_template/features/auth/repositories/auth_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
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
    when(() => mockAuthRepository.sessionExpired)
        .thenAnswer((_) => sessionExpiredController.stream);
  });

  tearDown(() => sessionExpiredController.close());

  group('AuthBloc', () {
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
  });
}
