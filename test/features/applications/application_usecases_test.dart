import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/applications/data/repositories/in_memory_application_repository.dart';
import 'package:tujiajiri/features/applications/domain/application_failure.dart';
import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';
import 'package:tujiajiri/features/applications/domain/usecases/update_application_status.dart';
import 'package:tujiajiri/features/applications/domain/usecases/withdraw_application.dart';

void main() {
  final now = DateTime(2026, 11, 20);

  JobApplication build(ApplicationStatus status) => JobApplication(
    id: 'j1_u1',
    jobId: 'j1',
    applicantId: 'u1',
    employerId: 'e1',
    status: status,
    appliedAt: now,
    updatedAt: now,
  );

  group('UpdateApplicationStatus', () {
    test('moves an open application to a new status', () async {
      final app = build(ApplicationStatus.submitted);
      final repository = InMemoryApplicationRepository([app]);

      await UpdateApplicationStatus(repository)(
        app,
        ApplicationStatus.underReview,
      );

      final list = await repository.watchApplicantApplications('u1').first;
      expect(list.single.status, ApplicationStatus.underReview);
    });

    test('rejects changes to an already decided application', () async {
      final app = build(ApplicationStatus.accepted);
      final repository = InMemoryApplicationRepository([app]);

      await expectLater(
        UpdateApplicationStatus(repository)(app, ApplicationStatus.rejected),
        throwsA(isA<ApplicationFailure>()),
      );
    });

    test('rejects moving back to submitted', () async {
      final app = build(ApplicationStatus.underReview);
      final repository = InMemoryApplicationRepository([app]);

      await expectLater(
        UpdateApplicationStatus(repository)(app, ApplicationStatus.submitted),
        throwsA(isA<ApplicationFailure>()),
      );
    });
  });

  group('WithdrawApplication', () {
    test('lets the applicant withdraw an open application', () async {
      final app = build(ApplicationStatus.submitted);
      final repository = InMemoryApplicationRepository([app]);

      await WithdrawApplication(repository)(app, 'u1');

      expect(await repository.exists('j1_u1'), isFalse);
    });

    test("blocks withdrawing someone else's application", () async {
      final app = build(ApplicationStatus.submitted);
      final repository = InMemoryApplicationRepository([app]);

      await expectLater(
        WithdrawApplication(repository)(app, 'someone-else'),
        throwsA(isA<ApplicationFailure>()),
      );
      expect(await repository.exists('j1_u1'), isTrue);
    });
  });
}
