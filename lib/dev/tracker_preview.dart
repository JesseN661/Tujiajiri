import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tujiajiri/features/applications/data/repositories/in_memory_application_repository.dart';
import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';
import 'package:tujiajiri/features/applications/domain/usecases/submit_application.dart';
import 'package:tujiajiri/features/applications/domain/usecases/update_application_status.dart';
import 'package:tujiajiri/features/applications/domain/usecases/withdraw_application.dart';
import 'package:tujiajiri/features/applications/presentation/bloc/applications_cubit.dart';
import 'package:tujiajiri/features/applications/presentation/bloc/employer_applications_cubit.dart';
import 'package:tujiajiri/features/applications/presentation/pages/applications_page.dart';
import 'package:tujiajiri/features/applications/presentation/pages/apply_page.dart';
import 'package:tujiajiri/features/applications/presentation/pages/employer_applications_page.dart';

const _userId = 'demo-user';
const _employerId = 'employer-1';

const _titles = {
  'j1': 'Customer Support Agent',
  'j2': 'Sales Assistant',
  'j3': 'Data Entry Clerk',
  'j4': 'Software Development Intern',
};

JobApplication _seed(String jobId, ApplicationStatus status, int daysAgo) {
  final applied = DateTime.now().subtract(Duration(days: daysAgo));
  return JobApplication(
    id: '${jobId}_$_userId',
    jobId: jobId,
    applicantId: _userId,
    employerId: _employerId,
    status: status,
    appliedAt: applied,
    updatedAt: applied,
    jobTitle: _titles[jobId] ?? jobId,
    employerName: 'Demo Employer',
  );
}

void main() {
  final repository = InMemoryApplicationRepository([
    _seed('j1', ApplicationStatus.submitted, 1),
    _seed('j2', ApplicationStatus.underReview, 3),
    _seed('j3', ApplicationStatus.rejected, 6),
    _seed('j4', ApplicationStatus.accepted, 8),
  ]);
  runApp(TrackerPreview(repository: repository));
}

class TrackerPreview extends StatelessWidget {
  const TrackerPreview({super.key, required this.repository});

  final InMemoryApplicationRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracker preview',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ApplicationsCubit(
              repository: repository,
              submitApplication: SubmitApplication(repository),
              updateApplicationStatus: UpdateApplicationStatus(repository),
              withdrawApplication: WithdrawApplication(repository),
              currentUserId: () => _userId,
            ),
          ),
          BlocProvider(
            create: (_) => EmployerApplicationsCubit(
              repository: repository,
              updateApplicationStatus: UpdateApplicationStatus(repository),
              currentUserId: () => _employerId,
            ),
          ),
        ],
        child: child!,
      ),
      home: const _PreviewHome(),
    );
  }
}

class _PreviewHome extends StatelessWidget {
  const _PreviewHome();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tracker preview'),
          actions: [
            IconButton(
              tooltip: 'Apply for a job',
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ApplyPage(
                    jobId: 'j5',
                    jobTitle: 'Marketing Intern',
                    employerId: _employerId,
                    employerName: 'Demo Employer',
                  ),
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My applications'),
              Tab(text: 'Employer view'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [ApplicationsPage(), EmployerApplicationsPage()],
        ),
      ),
    );
  }
}
