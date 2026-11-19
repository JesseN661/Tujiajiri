import '../entities/application_status.dart';
import '../entities/job_application.dart';

abstract class ApplicationRepository {
  Stream<List<JobApplication>> watchApplicantApplications(String applicantId);
  Stream<List<JobApplication>> watchEmployerApplications(String employerId);
  Future<bool> exists(String applicationId);
  Future<void> submit(JobApplication application);
  Future<void> updateStatus(String applicationId, ApplicationStatus status);
  Future<void> withdraw(String applicationId);
}
