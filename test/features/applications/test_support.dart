import 'package:tujiajiri/features/applications/data/repositories/in_memory_application_repository.dart';
import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';
import 'package:tujiajiri/features/applications/domain/usecases/submit_application.dart';
import 'package:tujiajiri/features/applications/domain/usecases/update_application_status.dart';
import 'package:tujiajiri/features/applications/domain/usecases/withdraw_application.dart';
import 'package:tujiajiri/features/applications/presentation/bloc/applications_cubit.dart';

JobApplication buildApplication({
  String jobId = 'j1',
  String applicantId = 'u1',
  String employerId = 'e1',
  ApplicationStatus status = ApplicationStatus.submitted,
}) {
  final now = DateTime(2026, 11, 20);
  return JobApplication(
    id: '${jobId}_$applicantId',
    jobId: jobId,
    applicantId: applicantId,
    employerId: employerId,
    status: status,
    appliedAt: now,
    updatedAt: now,
    jobTitle: 'Customer Support Agent',
    employerName: 'Demo Employer',
  );
}

ApplicationsCubit buildCubit(
  InMemoryApplicationRepository repository, {
  String userId = 'u1',
}) => ApplicationsCubit(
  repository: repository,
  submitApplication: SubmitApplication(repository),
  updateApplicationStatus: UpdateApplicationStatus(repository),
  withdrawApplication: WithdrawApplication(repository),
  currentUserId: () => userId,
);

/// A repository whose operations fail, to test error handling.
class FailingApplicationRepository extends InMemoryApplicationRepository {
  @override
  Stream<List<JobApplication>> watchApplicantApplications(String applicantId) =>
      Stream.error(Exception('boom'));

  @override
  Future<bool> exists(String applicationId) async => throw StateError('boom');
}

/// Lets queued stream events run. Use only in plain `test`, not `testWidgets`.
Future<void> settle() => Future<void>.delayed(Duration.zero);
