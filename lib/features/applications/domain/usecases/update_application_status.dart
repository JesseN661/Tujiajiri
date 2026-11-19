import '../application_failure.dart';
import '../entities/application_status.dart';
import '../entities/job_application.dart';
import '../repositories/application_repository.dart';

class UpdateApplicationStatus {
  UpdateApplicationStatus(this._repository);
  final ApplicationRepository _repository;

  Future<void> call(JobApplication current, ApplicationStatus next) async {
    if (current.status.isFinal) {
      throw ApplicationFailure(
        'This application was already ${current.status.label.toLowerCase()}.',
      );
    }
    if (next == ApplicationStatus.submitted || next == current.status) {
      throw const ApplicationFailure('Choose a different status.');
    }
    await _repository.updateStatus(current.id, next);
  }
}
