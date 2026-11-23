/// Pure validators for the onboarding forms. Each returns an error or null.
class ProfileValidators {
  const ProfileValidators._();

  static const int minYear = 1950;

  /// Allows a few future years for courses that have not finished yet.
  static int get maxYear => DateTime.now().year + 10;

  static String? _required(String? value, String label, {int max = 80}) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Enter $label.';
    if (text.length < 2) return '${_capital(label)} is too short.';
    if (text.length > max) return '${_capital(label)} is too long.';
    return null;
  }

  static String _capital(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  static String? fullName(String? value) =>
      _required(value, 'your full name', max: 60);

  /// Accepts +250 788 123 456, 0788123456, 078-812-3456 and similar.
  static String? phone(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Enter your phone number.';
    final digits = text.replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^\+?\d{9,15}$').hasMatch(digits)) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  static String? location(String? value) =>
      _required(value, 'your town or city', max: 60);

  static String? school(String? value) => _required(value, 'the school name');

  static String? degree(String? value) => _required(value, 'the qualification');

  static String? fieldOfStudy(String? value) {
    if ((value ?? '').trim().length > 80) return 'Field of study is too long.';
    return null;
  }

  static String? company(String? value) => _required(value, 'the company name');

  static String? role(String? value) => _required(value, 'your job title');

  static String? description(String? value) {
    if ((value ?? '').trim().length > 500) {
      return 'Keep the description under 500 characters.';
    }
    return null;
  }

  /// Start year is required and must be a sensible year.
  static String? startYear(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Enter the start year.';
    final year = int.tryParse(text);
    if (year == null) return 'Use a 4-digit year.';
    if (year < minYear || year > maxYear) {
      return 'Year must be between $minYear and $maxYear.';
    }
    return null;
  }

  /// End year is optional (empty means ongoing) and must not precede start.
  static String? endYear(String? value, String? startYearText) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final year = int.tryParse(text);
    if (year == null) return 'Use a 4-digit year or leave empty.';
    if (year < minYear || year > maxYear) {
      return 'Year must be between $minYear and $maxYear.';
    }
    final start = int.tryParse((startYearText ?? '').trim());
    if (start != null && year < start) {
      return 'End year cannot be before the start year.';
    }
    return null;
  }
}
