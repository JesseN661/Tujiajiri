// End-to-end: apply, employer updates the status, tracker updates live.
// Real app layers with an in-memory Firestore. Run: flutter test integration_test
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tujiajiri/core/navigation/app_destination.dart';
import 'package:tujiajiri/core/navigation/home_shell.dart';
import 'package:tujiajiri/features/applications/data/repositories/firestore_application_repository.dart';
import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';
import 'package:tujiajiri/features/applications/domain/usecases/submit_application.dart';
import 'package:tujiajiri/features/applications/domain/usecases/update_application_status.dart';
import 'package:tujiajiri/features/applications/domain/usecases/withdraw_application.dart';
import 'package:tujiajiri/features/applications/presentation/bloc/applications_cubit.dart';
import 'package:tujiajiri/features/applications/presentation/bloc/applications_state.dart';
import 'package:tujiajiri/features/applications/presentation/bloc/employer_applications_cubit.dart';
import 'package:tujiajiri/features/applications/presentation/pages/applications_page.dart';
import 'package:tujiajiri/features/applications/presentation/pages/apply_page.dart';
import 'package:tujiajiri/features/applications/presentation/pages/employer_applications_page.dart';

const seekerId = 'seeker1';
const employerId = 'employer1';
const jobId = 'job1';
const jobTitle = 'Customer Support Agent';
const applicationId = '${jobId}_$seekerId';

ApplicationsCubit seekerCubit(FirestoreApplicationRepository repository) =>
    ApplicationsCubit(
      repository: repository,
      submitApplication: SubmitApplication(repository),
      updateApplicationStatus: UpdateApplicationStatus(repository),
      withdrawApplication: WithdrawApplication(repository),
      currentUserId: () => seekerId,
    );

EmployerApplicationsCubit employerCubit(
  FirestoreApplicationRepository repository,
) => EmployerApplicationsCubit(
  repository: repository,
  updateApplicationStatus: UpdateApplicationStatus(repository),
  currentUserId: () => employerId,
);

/// The seeker's app: a Jobs tab with an Apply button, and the Tracker tab.
Widget seekerApp(ApplicationsCubit cubit) => BlocProvider.value(
  value: cubit,
  child: MaterialApp(
    home: HomeShell(
      destinations: [
        AppDestination(
          label: 'Jobs',
          icon: Icons.work_outline,
          selectedIcon: Icons.work,
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Find Jobs')),
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ApplyPage(
                      jobId: jobId,
                      jobTitle: jobTitle,
                      employerId: employerId,
                      employerName: 'Kigali Tech',
                    ),
                  ),
                ),
                child: const Text('Apply now'),
              ),
            ),
          ),
        ),
        AppDestination(
          label: 'Tracker',
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment,
          builder: (_) => const Scaffold(body: ApplicationsPage()),
        ),
      ],
    ),
  ),
);

/// The employer's app: the Applicants tab.
Widget employerApp(EmployerApplicationsCubit cubit) => BlocProvider.value(
  value: cubit,
  child: MaterialApp(
    home: HomeShell(
      destinations: [
        AppDestination(
          label: 'Applicants',
          icon: Icons.groups_outlined,
          selectedIcon: Icons.groups,
          builder: (_) => const Scaffold(body: EmployerApplicationsPage()),
        ),
        AppDestination(
          label: 'Profile',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          builder: (_) => const Scaffold(body: Text('Profile')),
        ),
      ],
    ),
  ),
);

Future<Map<String, dynamic>?> storedApplication(
  FakeFirebaseFirestore db,
) async =>
    (await db.collection('applications').doc(applicationId).get()).data();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore db;
  late FirestoreApplicationRepository repository;

  setUp(() {
    db = FakeFirebaseFirestore();
    repository = FirestoreApplicationRepository(db);
  });

  testWidgets(
    'seeker applies, employer accepts, and the tracker updates live',
    (tester) async {
      final seeker = seekerCubit(repository);
      addTearDown(seeker.close);
      await tester.pumpWidget(seekerApp(seeker));

      // 1. Apply from the Jobs tab.
      await tester.tap(find.text('Apply now'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'I have two years of call-centre experience.',
      );
      await tester.tap(find.text('Submit application'));
      await tester.pumpAndSettle();
      expect(find.text('Application submitted.'), findsOneWidget);

      // 2. The application is stored in Firestore as "submitted".
      final stored = await storedApplication(db);
      expect(stored?['status'], 'submitted');
      expect(stored?['applicantId'], seekerId);
      expect(stored?['employerId'], employerId);

      // 3. It appears in the Tracker tab.
      await tester.tap(find.text('Tracker'));
      await tester.pumpAndSettle();
      expect(find.text(jobTitle), findsOneWidget);
      expect(find.text(ApplicationStatus.submitted.label), findsOneWidget);

      // 4. The employer accepts it (another user, same database).
      final employer = employerCubit(repository)..watch();
      addTearDown(employer.close);
      await tester.runAsync(() async {
        await employer.stream.firstWhere(
          (s) => s.status == ApplicationsStatus.loaded,
        );
        await employer.updateStatus(
          employer.state.applications.single,
          ApplicationStatus.accepted,
        );
      });
      await tester.pumpAndSettle();

      // 5. The seeker's tracker shows the new status without a refresh.
      expect(find.text(ApplicationStatus.accepted.label), findsOneWidget);
      expect((await storedApplication(db))?['status'], 'accepted');
    },
  );

  testWidgets('applying twice to the same job shows a polite error', (
    tester,
  ) async {
    final seeker = seekerCubit(repository);
    addTearDown(seeker.close);
    await tester.pumpWidget(seekerApp(seeker));

    for (var attempt = 0; attempt < 2; attempt++) {
      await tester.tap(find.text('Apply now'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit application'));
      await tester.pumpAndSettle();
    }

    expect(find.text('You have already applied for this job.'), findsOneWidget);
    // The form stays open so the user is not sent away silently.
    expect(find.text('Submit application'), findsOneWidget);
  });

  testWidgets('employer changes a status from the Applicants tab', (
    tester,
  ) async {
    await SubmitApplication(repository)(
      jobId: jobId,
      applicantId: seekerId,
      employerId: employerId,
      jobTitle: jobTitle,
      employerName: 'Kigali Tech',
    );

    final employer = employerCubit(repository);
    addTearDown(employer.close);
    await tester.pumpWidget(employerApp(employer));
    await tester.pumpAndSettle();
    expect(find.text(jobTitle), findsOneWidget);

    await tester.tap(find.byTooltip('Change status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ApplicationStatus.underReview.label).last);
    await tester.pumpAndSettle();

    expect((await storedApplication(db))?['status'], 'underReview');
    expect(find.text(ApplicationStatus.underReview.label), findsOneWidget);
  });

  testWidgets('seeker withdraws an open application', (tester) async {
    await SubmitApplication(repository)(
      jobId: jobId,
      applicantId: seekerId,
      employerId: employerId,
      jobTitle: jobTitle,
    );

    final seeker = seekerCubit(repository);
    addTearDown(seeker.close);
    await tester.pumpWidget(seekerApp(seeker));
    await tester.tap(find.text('Tracker'));
    await tester.pumpAndSettle();
    expect(find.text(jobTitle), findsOneWidget);

    await tester.tap(find.byTooltip('Withdraw application'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle();

    expect(await storedApplication(db), isNull);
    expect(find.text(jobTitle), findsNothing);
    expect(
      find.text('No applications yet. Apply for a job and track it here.'),
      findsOneWidget,
    );
  });
}
