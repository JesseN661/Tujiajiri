/// Turns Firebase Auth error codes into messages that are safe to show.
class AuthErrorMapper {
  const AuthErrorMapper._();

  static String messageFor(String code) {
    switch (code) {
      // Newer Firebase returns invalid-credential for both a wrong password
      // and an unknown email, so we never reveal which accounts exist.
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'email-already-in-use':
        return 'An account already exists for that email. Try logging in.';
      case 'weak-password':
        return 'That password is too weak. Use at least 8 characters '
            'with a letter and a number.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled yet.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'requires-recent-login':
        return 'Please log in again to continue.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
