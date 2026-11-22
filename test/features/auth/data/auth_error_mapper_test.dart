import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/auth/data/auth_error_mapper.dart';

void main() {
  test('wrong password and unknown email share one message', () {
    final messages = {
      for (final code in [
        'invalid-credential',
        'wrong-password',
        'user-not-found',
      ])
        AuthErrorMapper.messageFor(code),
    };

    expect(messages, {'Incorrect email or password.'});
  });

  test('maps common sign-up and network errors', () {
    expect(
      AuthErrorMapper.messageFor('email-already-in-use'),
      contains('already exists'),
    );
    expect(AuthErrorMapper.messageFor('weak-password'), contains('weak'));
    expect(
      AuthErrorMapper.messageFor('network-request-failed'),
      contains('internet'),
    );
    expect(
      AuthErrorMapper.messageFor('too-many-requests'),
      contains('Too many'),
    );
  });

  test('unknown codes fall back to a generic message', () {
    expect(
      AuthErrorMapper.messageFor('something-new'),
      'Authentication failed. Please try again.',
    );
  });
}
