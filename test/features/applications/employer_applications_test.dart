import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/applications/data/repositories/in_memory_application_repository.dart';
import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';
import 'package:tujiajiri/features/applications/domain/usecases/update_application_status.dart';
import 'package:tujiajiri/features/applications/presentation/bloc/applications_state.dart';
import 'package:tujiajiri/features/applications/presentation/bloc/employer_applications_cubit.dart';
import 'package:tujiajiri/features/applications/presentation/pages/employer_applications_page.dart';

JobApplication _build({
  required String jobId,
  required String applicantId,
  required String employerId,
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

EmployerApplicationsCubit _cubit(
  InMemoryApplicationRepository repository,
  String employerId,
) => EmployerApplicationsCubit(
  repository: repository,
  updateApplicationStatus: UpdateApplicationStatus(repository),
  currentUserId: () => employerId,
);

void main() {
  test('lists only applications for the signed-in employer', () async {
    final repository = InMemoryApplicationRepository([
      _build(jobId: 'j1', applicantId: 'u1', employerId: 'e1'),
      _build(jobId: 'j2', applicantId: 'u2', employerId: 'e2'),
    ]);
    final cubit = _cubit(repository, 'e1')..watch();

    await cubit.stream.firstWhere((s) => s.status == ApplicationsStatus.loaded);

    expect(cubit.state.applications.single.jobId, 'j1');
    await cubit.close();
  });

  test('reports an error when a decided application is changed', () async {
    final decided = _build(
      jobId: 'j1',
      applicantId: 'u1',
      employerId: 'e1',
      status: ApplicationStatus.accepted,
    );
    final cubit = _cubit(InMemoryApplicationRepository([decided]), 'e1');

    await cubit.updateStatus(decided, ApplicationStatus.rejected);

    expect(cubit.state.message, contains('already'));
    await cubit.close();
  });

  testWidgets('employer can accept a submitted application', (tester) async {
    final repository = InMemoryApplicationRepository([
      _build(jobId: 'j1', applicantId: 'applicant-1', employerId: 'e1'),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => _cubit(repository, 'e1'),
          child: const Scaffold(body: EmployerApplicationsPage()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Customer Support Agent'), findsOneWidget);
    expect(find.text('Submitted'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<ApplicationStatus>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accepted'));
    await tester.pumpAndSettle();
    await tester.pump();

    expect(find.text('Accepted'), findsOneWidget);
    expect(find.text('Status changed to Accepted.'), findsOneWidget);
  });
}
