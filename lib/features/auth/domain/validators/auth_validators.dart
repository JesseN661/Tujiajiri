/// Pure form validators. Each returns an error message, or null when valid.
class AuthValidators {
  const AuthValidators._();

  // Simple shape check: something@domain.tld with no spaces.
  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? name(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Enter your full name.';
    if (text.length < 2) return 'Name must be at least 2 characters.';
    if (text.length > 60) return 'Name must be 60 characters or fewer.';
    return null;
  }

  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Enter your email address.';
    if (!_emailPattern.hasMatch(text)) return 'Enter a valid email address.';
    return null;
  }

  /// Rules for choosing a new password (registration).
  static String? newPassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Enter a password.';
    if (text.length < 8) return 'Password must be at least 8 characters.';
    if (!RegExp(r'[A-Za-z]').hasMatch(text)) {
      return 'Password must contain a letter.';
    }
    if (!RegExp(r'\d').hasMatch(text)) {
      return 'Password must contain a number.';
    }
    return null;
  }

  /// Login only checks presence; the server decides if it is correct.
  static String? loginPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Enter your password.';
    return null;
  }

  static String? confirmPassword(String? password, String? confirmation) {
    if ((confirmation ?? '').isEmpty) return 'Confirm your password.';
    if (password != confirmation) return 'Passwords do not match.';
    return null;
  }
}
