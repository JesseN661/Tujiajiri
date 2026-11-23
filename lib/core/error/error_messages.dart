import 'package:firebase_core/firebase_core.dart';

import 'failure.dart';

/// Turns any error into a short message a user can act on.
///
/// - A [Failure] already carries a user-facing message.
/// - Firebase errors (Auth and Firestore) are mapped by their `code`, so users
///   never see raw text such as `[firebase_auth/invalid-credential]`.
/// - Anything else gets a generic message.
String friendlyMessage(Object error) {
  if (error is Failure) return error.message;
  if (error is FirebaseException) {
    return _firebaseMessages[error.code] ?? _generic;
  }
  return _generic;
}

const _generic = 'Something went wrong. Please try again.';

const _firebaseMessages = <String, String>{
  // Authentication
  'invalid-email': 'That email address is not valid.',
  'user-disabled': 'This account has been disabled.',
  'user-not-found': 'Incorrect email or password.',
  'wrong-password': 'Incorrect email or password.',
  'invalid-credential': 'Incorrect email or password.',
  'email-already-in-use': 'An account already exists for that email.',
  'weak-password': 'Choose a stronger password (at least 6 characters).',
  'too-many-requests': 'Too many attempts. Wait a moment and try again.',
  'network-request-failed':
      'No internet connection. Check your connection and try again.',
  // Firestore
  'unavailable': 'No internet connection. Check your connection and try again.',
  'permission-denied': "You don't have permission to do that.",
  'not-found': 'That item no longer exists.',
  'deadline-exceeded': 'The request took too long. Please try again.',
};
