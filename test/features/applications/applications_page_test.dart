import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/applications/data/repositories/in_memory_application_repository.dart';
import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';
import 'package:tujiajiri/features/applications/domain/usecases/submit_application.dart';
import 'package:tujiajiri/features/applications/domain/usecases/update_application_status.dart';
import 'package:tujiajiri/features/applications/domain/usecases/withdraw_application.dart';
import 'package:tujiajiri/features/applications/presentation/bloc/applications_cubit.dart';
import 'package:tujiajiri/features/applications/presentation/pages/applications_page.dart';

void main() {
  testWidgets('tracker lists applications and reacts to a status change', (
    tester,
  ) async {
    final now = DateTime(2026, 11, 20);
    final repository = InMemoryApplicationRepository([
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
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => ApplicationsCubit(
            repository: repository,
            submitApplication: SubmitApplication(repository),
            updateApplicationStatus: UpdateApplicationStatus(repository),
            withdrawApplication: WithdrawApplication(repository),
            currentUserId: () => 'u1',
          ),
          child: const Scaffold(body: ApplicationsPage()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Customer Support Agent'), findsOneWidget);
    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('In progress: 1'), findsOneWidget);

    await repository.updateStatus('j1_u1', ApplicationStatus.accepted);
    await tester.pump();
    await tester.pump();

    expect(find.text('Accepted'), findsOneWidget);
    expect(find.text('Decided: 1'), findsOneWidget);
  });
}
