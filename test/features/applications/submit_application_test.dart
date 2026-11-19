import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/applications/domain/application_failure.dart';
import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';
import 'package:tujiajiri/features/applications/domain/repositories/application_repository.dart';
import 'package:tujiajiri/features/applications/domain/usecases/submit_application.dart';

class FakeRepo implements ApplicationRepository {
  final Map<String, JobApplication> store = {};

  @override
  Future<bool> exists(String id) async => store.containsKey(id);
  @override
  Future<void> submit(JobApplication a) async => store[a.id] = a;
  @override
  Future<void> updateStatus(String id, ApplicationStatus s) async {}
  @override
  Future<void> withdraw(String id) async => store.remove(id);
  @override
  Stream<List<JobApplication>> watchApplicantApplications(String id) =>
      const Stream.empty();
  @override
  Stream<List<JobApplication>> watchEmployerApplications(String id) =>
      const Stream.empty();
}

void main() {
  test('submits once, rejects a duplicate', () async {
    final repo = FakeRepo();
    final submit = SubmitApplication(repo);

    await submit(jobId: 'j1', applicantId: 'u1', employerId: 'e1');
    expect(repo.store['j1_u1']?.status, ApplicationStatus.submitted);

    expect(
      () => submit(jobId: 'j1', applicantId: 'u1', employerId: 'e1'),
      throwsA(isA<ApplicationFailure>()),
    );
  });
}
