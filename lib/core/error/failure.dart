/// Base class for errors the app expects and can explain to the user,
/// such as "You have already applied for this job".
///
/// Each feature extends it (for example `ApplicationFailure`) so the UI can
/// treat every expected error the same way: show [message] in a snackbar.
class Failure implements Exception {
  const Failure(this.message);

  /// A sentence that is safe to show to the user.
  final String message;

  @override
  String toString() => message;
}
