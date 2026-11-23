import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/auth/domain/validators/auth_validators.dart';

void main() {
  group('name', () {
    test('rejects empty and too short names', () {
      expect(AuthValidators.name(null), isNotNull);
      expect(AuthValidators.name('   '), isNotNull);
      expect(AuthValidators.name('A'), isNotNull);
    });

    test('rejects names over 60 characters', () {
      expect(AuthValidators.name('a' * 61), isNotNull);
    });

    test('accepts a normal name', () {
      expect(AuthValidators.name('Amina Uwase'), isNull);
    });
  });

  group('email', () {
    test('rejects empty input', () {
      expect(AuthValidators.email(''), isNotNull);
      expect(AuthValidators.email(null), isNotNull);
    });

    test('rejects malformed addresses', () {
      for (final bad in ['plain', 'a@b', 'a b@c.com', '@c.com', 'a@.com']) {
        expect(AuthValidators.email(bad), isNotNull, reason: bad);
      }
    });

    test('accepts valid addresses and trims spaces', () {
      expect(AuthValidators.email('amina@example.com'), isNull);
      expect(AuthValidators.email(' a.b+c@mail.example.org '), isNull);
    });
  });

  group('newPassword', () {
    test('rejects empty, short, letter-less and digit-less passwords', () {
      expect(AuthValidators.newPassword(''), isNotNull);
      expect(AuthValidators.newPassword('abc123'), isNotNull);
      expect(AuthValidators.newPassword('12345678'), isNotNull);
      expect(AuthValidators.newPassword('abcdefgh'), isNotNull);
    });

    test('accepts a password with 8+ chars, a letter and a number', () {
      expect(AuthValidators.newPassword('abcdefg1'), isNull);
    });
  });

  group('loginPassword', () {
    test('only requires a value', () {
      expect(AuthValidators.loginPassword(''), isNotNull);
      expect(AuthValidators.loginPassword('x'), isNull);
    });
  });

  group('confirmPassword', () {
    test('requires a value that matches', () {
      expect(AuthValidators.confirmPassword('abc12345', ''), isNotNull);
      expect(AuthValidators.confirmPassword('abc12345', 'abc12346'), isNotNull);
      expect(AuthValidators.confirmPassword('abc12345', 'abc12345'), isNull);
    });
  });
}
