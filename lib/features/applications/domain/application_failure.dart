import 'package:tujiajiri/core/error/failure.dart';

/// An expected error in the applications feature, such as a duplicate
/// application or an invalid status change.
class ApplicationFailure extends Failure {
  const ApplicationFailure(super.message);
}
