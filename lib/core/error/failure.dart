/// An expected error, e.g. "You have already applied for this job".
class Failure implements Exception {
  const Failure(this.message);

  /// Safe to show to the user.
  final String message;

  @override
  String toString() => message;
}
