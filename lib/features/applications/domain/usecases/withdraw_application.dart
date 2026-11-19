import '../application_failure.dart';
import '../entities/job_application.dart';
import '../repositories/application_repository.dart';

class WithdrawApplication {
  WithdrawApplication(this._repository);
  final ApplicationRepository _repository;

  Future<void> call(JobApplication current, String requesterId) async {
    if (current.applicantId != requesterId) {
      throw const ApplicationFailure(
        'You can only withdraw your own applications.',
      );
    }
    if (current.status.isFinal) {
      throw const ApplicationFailure(
        'A decided application cannot be withdrawn.',
      );
    }
    await _repository.withdraw(current.id);
  }
}
