import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/applications/data/repositories/firestore_application_repository.dart';
import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';

void main() {
  test('create, read, update and delete an application', () async {
    final repository = FirestoreApplicationRepository(FakeFirebaseFirestore());
    final now = DateTime(2026, 11, 20);

    await repository.submit(
      JobApplication(
        id: 'j1_u1',
        jobId: 'j1',
        applicantId: 'u1',
        employerId: 'e1',
        status: ApplicationStatus.submitted,
        appliedAt: now,
        updatedAt: now,
        jobTitle: 'Customer Support Agent',
        employerName: 'Demo Employer',
      ),
    );
    expect(await repository.exists('j1_u1'), isTrue);

    final created = await repository.watchApplicantApplications('u1').first;
    expect(created.single.jobTitle, 'Customer Support Agent');
    expect(created.single.status, ApplicationStatus.submitted);

    await repository.updateStatus('j1_u1', ApplicationStatus.underReview);
    final updated = await repository.watchApplicantApplications('u1').first;
    expect(updated.single.status, ApplicationStatus.underReview);

    await repository.withdraw('j1_u1');
    expect(await repository.exists('j1_u1'), isFalse);
  });
}
