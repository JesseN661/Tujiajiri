import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/applications/data/repositories/in_memory_application_repository.dart';
import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';
import 'package:tujiajiri/features/applications/presentation/bloc/applications_state.dart';

import 'test_support.dart';

void main() {
  group('ApplicationsCubit', () {
    test("watch loads only the signed-in user's applications", () async {
      final repository = InMemoryApplicationRepository([
        buildApplication(jobId: 'j1', applicantId: 'u1'),
        buildApplication(jobId: 'j2', applicantId: 'u2'),
      ]);
      final cubit = buildCubit(repository);
      addTearDown(cubit.close);

      cubit.watch();
      await settle();

      expect(cubit.state.status, ApplicationsStatus.loaded);
      expect(cubit.state.applications.single.jobId, 'j1');
    });

    test('submit stores the application and returns no error', () async {
      final repository = InMemoryApplicationRepository();
      final cubit = buildCubit(repository);
      addTearDown(cubit.close);
      cubit.watch();
      await settle();

      final error = await cubit.submit(
        jobId: 'j1',
        employerId: 'e1',
        jobTitle: 'Customer Support Agent',
        employerName: 'Demo Employer',
        coverLetter: 'I am a good fit.',
      );
      await settle();

      expect(error, isNull);
      expect(cubit.state.applications.single.jobId, 'j1');
      expect(
        cubit.state.applications.single.status,
        ApplicationStatus.submitted,
      );
    });

    test('submit returns a friendly message for a duplicate', () async {
      final repository = InMemoryApplicationRepository([buildApplication()]);
      final cubit = buildCubit(repository);
      addTearDown(cubit.close);

      final error = await cubit.submit(jobId: 'j1', employerId: 'e1');

      expect(error, 'You have already applied for this job.');
    });

    test('submit returns a generic message on unexpected errors', () async {
      final cubit = buildCubit(FailingApplicationRepository());
      addTearDown(cubit.close);

      final error = await cubit.submit(jobId: 'j1', employerId: 'e1');

      expect(error, 'Something went wrong. Please try again.');
    });

    test('updateStatus announces the new status', () async {
      final application = buildApplication();
      final repository = InMemoryApplicationRepository([application]);
      final cubit = buildCubit(repository);
      addTearDown(cubit.close);

      await cubit.updateStatus(application, ApplicationStatus.underReview);

      expect(cubit.state.message, 'Status changed to Under Review.');
      expect(cubit.state.feedbackId, 1);
    });

    test('withdraw removes the application and announces it', () async {
      final application = buildApplication();
      final repository = InMemoryApplicationRepository([application]);
      final cubit = buildCubit(repository);
      addTearDown(cubit.close);

      await cubit.withdraw(application);

      expect(cubit.state.message, 'Application withdrawn.');
      expect(await repository.exists(application.id), isFalse);
    });

    test("withdraw explains when it is not the user's application", () async {
      final application = buildApplication(applicantId: 'u1');
      final repository = InMemoryApplicationRepository([application]);
      final cubit = buildCubit(repository, userId: 'u2');
      addTearDown(cubit.close);

      await cubit.withdraw(application);

      expect(
        cubit.state.message,
        'You can only withdraw your own applications.',
      );
      expect(await repository.exists(application.id), isTrue);
    });

    test('watch reports a failure when loading fails', () async {
      final cubit = buildCubit(FailingApplicationRepository());
      addTearDown(cubit.close);

      cubit.watch();
      await settle();

      expect(cubit.state.status, ApplicationsStatus.failure);
      expect(cubit.state.message, 'Could not load your applications.');
    });
  });
}
