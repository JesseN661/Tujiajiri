import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/profile/domain/validators/profile_validators.dart';

void main() {
  group('fullName, location and text fields', () {
    test('reject empty, too short and too long values', () {
      expect(ProfileValidators.fullName(''), isNotNull);
      expect(ProfileValidators.fullName('A'), isNotNull);
      expect(ProfileValidators.fullName('a' * 61), isNotNull);
      expect(ProfileValidators.location('  '), isNotNull);
      expect(ProfileValidators.school(null), isNotNull);
      expect(ProfileValidators.company('x'), isNotNull);
    });

    test('accept normal values', () {
      expect(ProfileValidators.fullName('Amina Uwase'), isNull);
      expect(ProfileValidators.location('Kigali'), isNull);
      expect(ProfileValidators.degree('Diploma in ICT'), isNull);
      expect(ProfileValidators.role('Sales assistant'), isNull);
    });
  });

  group('phone', () {
    test('accepts common formats', () {
      for (final good in ['+250 788 123 456', '0788123456', '078-812-3456']) {
        expect(ProfileValidators.phone(good), isNull, reason: good);
      }
    });

    test('rejects empty, short and lettered numbers', () {
      for (final bad in ['', '12345', 'abcdefghij', '+25']) {
        expect(ProfileValidators.phone(bad), isNotNull, reason: bad);
      }
    });
  });

  group('years', () {
    test('start year is required and in range', () {
      expect(ProfileValidators.startYear(''), isNotNull);
      expect(ProfileValidators.startYear('abcd'), isNotNull);
      expect(ProfileValidators.startYear('1900'), isNotNull);
      expect(ProfileValidators.startYear('3000'), isNotNull);
      expect(ProfileValidators.startYear('2020'), isNull);
    });

    test('end year may be empty but not before the start year', () {
      expect(ProfileValidators.endYear('', '2020'), isNull);
      expect(ProfileValidators.endYear('2019', '2020'), isNotNull);
      expect(ProfileValidators.endYear('2020', '2020'), isNull);
      expect(ProfileValidators.endYear('x', '2020'), isNotNull);
    });
  });

  group('optional text', () {
    test('field of study and description have length caps', () {
      expect(ProfileValidators.fieldOfStudy(''), isNull);
      expect(ProfileValidators.fieldOfStudy('a' * 81), isNotNull);
      expect(ProfileValidators.description('a' * 501), isNotNull);
      expect(ProfileValidators.description('Served customers daily'), isNull);
    });
  });
}
