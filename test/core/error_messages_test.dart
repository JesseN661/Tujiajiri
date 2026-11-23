import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/core/error/error_messages.dart';
import 'package:tujiajiri/core/error/failure.dart';
import 'package:tujiajiri/features/applications/domain/application_failure.dart';

FirebaseException firebaseError(String code) =>
    FirebaseException(plugin: 'test', code: code);

void main() {
  group('friendlyMessage', () {
    test('returns the message of a Failure unchanged', () {
      expect(
        friendlyMessage(const Failure('Profile saved.')),
        'Profile saved.',
      );
    });

    test('feature failures are Failures too', () {
      const failure = ApplicationFailure('You have already applied.');
      expect(failure, isA<Failure>());
      expect(friendlyMessage(failure), 'You have already applied.');
    });

    test('hides which part of a login was wrong', () {
      for (final code in [
        'user-not-found',
        'wrong-password',
        'invalid-credential',
      ]) {
        expect(
          friendlyMessage(firebaseError(code)),
          'Incorrect email or password.',
          reason: code,
        );
      }
    });

    test('explains registration errors', () {
      expect(
        friendlyMessage(firebaseError('email-already-in-use')),
        'An account already exists for that email.',
      );
      expect(
        friendlyMessage(firebaseError('weak-password')),
        contains('stronger password'),
      );
    });

    test('explains Firestore permission and network errors', () {
      expect(
        friendlyMessage(firebaseError('permission-denied')),
        "You don't have permission to do that.",
      );
      expect(
        friendlyMessage(firebaseError('unavailable')),
        contains('No internet connection'),
      );
    });

    test('falls back to a generic message', () {
      expect(
        friendlyMessage(firebaseError('some-new-code')),
        'Something went wrong. Please try again.',
      );
      expect(
        friendlyMessage(StateError('boom')),
        'Something went wrong. Please try again.',
      );
    });
  });
}
