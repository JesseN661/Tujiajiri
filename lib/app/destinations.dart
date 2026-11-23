import 'package:flutter/material.dart';

import '../core/navigation/app_destination.dart';
import '../core/session/user_role.dart';
import '../features/applications/presentation/pages/applications_page.dart';
import '../features/applications/presentation/pages/employer_applications_page.dart';
import '../features/jobs/presentation/jobs_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/skills_screen.dart';

/// The tabs each role sees after signing in.
List<AppDestination> destinationsFor(UserRole role) =>
    role.reviewsApplications ? employerDestinations() : seekerDestinations();

/// Job seekers: find jobs, track applications, manage skills and profile.
List<AppDestination> seekerDestinations() => [
  AppDestination(
    label: 'Jobs',
    icon: Icons.work_outline,
    selectedIcon: Icons.work,
    builder: (_) => const JobsScreen(),
  ),
  AppDestination(
    label: 'Tracker',
    icon: Icons.assignment_outlined,
    selectedIcon: Icons.assignment,
    builder: (_) =>
        const _TitledPage(title: 'My Applications', child: ApplicationsPage()),
  ),
  AppDestination(
    label: 'Skills',
    icon: Icons.psychology_outlined,
    selectedIcon: Icons.psychology,
    builder: (_) => const SkillsScreen(),
  ),
  AppDestination(
    label: 'Profile',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    builder: (_) => const ProfileScreen(),
  ),
];

/// Employers and admins: browse jobs, review applicants, manage profile.
List<AppDestination> employerDestinations() => [
  AppDestination(
    label: 'Jobs',
    icon: Icons.work_outline,
    selectedIcon: Icons.work,
    builder: (_) => const JobsScreen(),
  ),
  AppDestination(
    label: 'Applicants',
    icon: Icons.groups_outlined,
    selectedIcon: Icons.groups,
    builder: (_) => const _TitledPage(
      title: 'Applicants',
      child: EmployerApplicationsPage(),
    ),
  ),
  AppDestination(
    label: 'Profile',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    builder: (_) => const ProfileScreen(),
  ),
];

/// Gives pages that have no Scaffold of their own an app bar.
class _TitledPage extends StatelessWidget {
  const _TitledPage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: child,
    );
  }
}
