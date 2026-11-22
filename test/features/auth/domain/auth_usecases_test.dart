import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/auth/domain/auth_failure.dart';
import 'package:tujiajiri/features/auth/domain/usecases/register_with_email.dart';
import 'package:tujiajiri/features/auth/domain/usecases/send_password_reset.dart';
import 'package:tujiajiri/features/auth/domain/usecases/sign_in_with_email.dart';

import '../test_support.dart';

void main() {
  late FakeAuthRepository repository;

  setUp(() => repository = FakeAuthRepository());

  group('RegisterWithEmail', () {
    test('creates the account with trimmed name and email', () async {
      final user = await RegisterWithEmail(repository)(
        name: ' Amina ',
        email: ' amina@example.com ',
        password: 'abcdefg1',
        confirmation: 'abcdefg1',
      );

      expect(user.displayName, 'Amina');
      expect(repository.calls, ['register:amina@example.com']);
    });

    test('rejects a weak password without calling the repository', () {
      expect(
        () => RegisterWithEmail(repository)(
          name: 'Amina',
          email: 'amina@example.com',
          password: 'short',
          confirmation: 'short',
        ),
        throwsA(isA<AuthFailure>()),
      );
      expect(repository.calls, isEmpty);
    });

    test('rejects mismatched confirmation', () {
      expect(
        () => RegisterWithEmail(repository)(
          name: 'Amina',
          email: 'amina@example.com',
          password: 'abcdefg1',
          confirmation: 'abcdefg2',
        ),
        throwsA(
          isA<AuthFailure>().having(
            (e) => e.message,
            'message',
            'Passwords do not match.',
          ),
        ),
      );
    });
  });

  group('SignInWithEmail', () {
    test('signs in with valid input', () async {
      await SignInWithEmail(repository)(
        email: 'amina@example.com',
        password: 'secret',
      );
      expect(repository.calls, ['signIn:amina@example.com']);
    });

    test('rejects blank input without calling the repository', () {
      expect(
        () => SignInWithEmail(repository)(email: '', password: ''),
        throwsA(isA<AuthFailure>()),
      );
      expect(repository.calls, isEmpty);
    });
  });

  group('SendPasswordReset', () {
    test('sends a reset for a valid email', () async {
      await SendPasswordReset(repository)('amina@example.com');
      expect(repository.calls, ['reset:amina@example.com']);
    });

    test('rejects an invalid email', () {
      expect(
        () => SendPasswordReset(repository)('not-an-email'),
        throwsA(isA<AuthFailure>()),
      );
      expect(repository.calls, isEmpty);
    });
  });
}
