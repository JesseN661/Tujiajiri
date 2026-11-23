import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/auth/domain/auth_failure.dart';
import 'package:tujiajiri/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tujiajiri/features/auth/presentation/bloc/auth_state.dart';

import '../test_support.dart';

void main() {
  late FakeAuthRepository repository;

  setUp(() => repository = FakeAuthRepository());

  group('session', () {
    blocTest<AuthCubit, AuthState>(
      'saved session restores as authenticated on start',
      build: () =>
          AuthCubit(repository: FakeAuthRepository(initialUser: verifiedUser)),
      expect: () => [
        const AuthState(status: AuthStatus.authenticated, user: verifiedUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'no saved session starts unauthenticated',
      build: () => AuthCubit(repository: repository),
      expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    );

    blocTest<AuthCubit, AuthState>(
      'unverified saved user needs verification',
      build: () => AuthCubit(
        repository: FakeAuthRepository(initialUser: unverifiedUser),
      ),
      expect: () => [
        const AuthState(
          status: AuthStatus.needsVerification,
          user: unverifiedUser,
        ),
      ],
    );
  });

  group('signIn', () {
    blocTest<AuthCubit, AuthState>(
      'success moves to authenticated',
      build: () => AuthCubit(repository: repository),
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.signIn(email: 'amina@example.com', password: 'secret');
      },
      verify: (cubit) {
        expect(cubit.state.status, AuthStatus.authenticated);
        expect(cubit.state.isBusy, isFalse);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'failure shows the message and stays signed out',
      build: () {
        repository.failure = const AuthFailure('Incorrect email or password.');
        return AuthCubit(repository: repository);
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.signIn(email: 'amina@example.com', password: 'wrong');
      },
      verify: (cubit) {
        expect(cubit.state.status, AuthStatus.unauthenticated);
        expect(cubit.state.message, 'Incorrect email or password.');
        expect(cubit.state.isError, isTrue);
        expect(cubit.state.isBusy, isFalse);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'invalid input is rejected before reaching the repository',
      build: () => AuthCubit(repository: repository),
      act: (cubit) => cubit.signIn(email: '', password: ''),
      verify: (cubit) {
        expect(cubit.state.message, 'Enter your email address.');
        expect(repository.calls, isEmpty);
      },
    );
  });

  group('register', () {
    blocTest<AuthCubit, AuthState>(
      'new account must verify its email before continuing',
      build: () => AuthCubit(repository: repository),
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.register(
          name: 'Amina',
          email: 'amina@example.com',
          password: 'abcdefg1',
          confirmation: 'abcdefg1',
        );
      },
      verify: (cubit) {
        expect(cubit.state.status, AuthStatus.needsVerification);
        expect(cubit.state.user?.displayName, 'Amina');
        expect(cubit.state.isError, isFalse);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'mismatched confirmation shows a validation message',
      build: () => AuthCubit(repository: repository),
      act: (cubit) => cubit.register(
        name: 'Amina',
        email: 'amina@example.com',
        password: 'abcdefg1',
        confirmation: 'different1',
      ),
      verify: (cubit) {
        expect(cubit.state.message, 'Passwords do not match.');
        expect(repository.calls, isEmpty);
      },
    );
  });

  group('password reset', () {
    test('returns true and shows a generic message', () async {
      final cubit = AuthCubit(repository: repository);

      final sent = await cubit.sendPasswordReset('amina@example.com');

      expect(sent, isTrue);
      expect(cubit.state.message, contains('If an account exists'));
      await cubit.close();
    });

    test('returns false for an invalid email', () async {
      final cubit = AuthCubit(repository: repository);

      final sent = await cubit.sendPasswordReset('nope');

      expect(sent, isFalse);
      expect(cubit.state.isError, isTrue);
      await cubit.close();
    });
  });

  group('email verification', () {
    test('refresh moves to authenticated once verified', () async {
      repository = FakeAuthRepository(initialUser: unverifiedUser)
        ..reloadResult = verifiedUser;
      final cubit = AuthCubit(repository: repository);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.status, AuthStatus.needsVerification);

      await cubit.refreshVerification();

      expect(cubit.state.status, AuthStatus.authenticated);
      await cubit.close();
    });

    test('refresh warns when still unverified', () async {
      repository = FakeAuthRepository(initialUser: unverifiedUser);
      final cubit = AuthCubit(repository: repository);
      await Future<void>.delayed(Duration.zero);

      await cubit.refreshVerification();

      expect(cubit.state.status, AuthStatus.needsVerification);
      expect(cubit.state.message, contains('not verified'));
      await cubit.close();
    });

    test('resend sends another email', () async {
      repository = FakeAuthRepository(initialUser: unverifiedUser);
      final cubit = AuthCubit(repository: repository);

      await cubit.resendVerificationEmail();

      expect(repository.calls, ['verify']);
      expect(cubit.state.message, contains('Verification email sent'));
      await cubit.close();
    });
  });

  group('signOut', () {
    test('clears the user and returns to unauthenticated', () async {
      repository = FakeAuthRepository(initialUser: verifiedUser);
      final cubit = AuthCubit(repository: repository);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.status, AuthStatus.authenticated);

      await cubit.signOut();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.state.user, isNull);
      await cubit.close();
    });
  });
}
