import '../application_failure.dart';
import '../entities/application_status.dart';
import '../entities/job_application.dart';
import '../repositories/application_repository.dart';

class SubmitApplication {
  SubmitApplication(this._repository);
  final ApplicationRepository _repository;

  Future<void> call({
    required String jobId,
    required String applicantId,
    required String employerId,
    String coverLetter = '',
  }) async {
    if (jobId.isEmpty || applicantId.isEmpty || employerId.isEmpty) {
      throw const ApplicationFailure('Missing job or user information.');
    }
    if (coverLetter.length > 1000) {
      throw const ApplicationFailure(
        'Cover letter is too long (max 1000 characters).',
      );
    }
    final id = '${jobId}_$applicantId';
    if (await _repository.exists(id)) {
      throw const ApplicationFailure('You have already applied for this job.');
    }
    final now = DateTime.now();
    await _repository.submit(
      JobApplication(
        id: id,
        jobId: jobId,
        applicantId: applicantId,
        employerId: employerId,
        status: ApplicationStatus.submitted,
        appliedAt: now,
        updatedAt: now,
        coverLetter: coverLetter.trim(),
      ),
    );
  }
}
