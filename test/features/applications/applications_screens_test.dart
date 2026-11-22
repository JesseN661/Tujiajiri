import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/applications/data/repositories/in_memory_application_repository.dart';
import 'package:tujiajiri/features/applications/presentation/pages/applications_page.dart';
import 'package:tujiajiri/features/applications/presentation/pages/apply_page.dart';

import 'test_support.dart';

/// Provides the cubit above the Navigator, like the real app will.
Widget _app(InMemoryApplicationRepository repository, Widget home) {
  return MaterialApp(
    builder: (context, child) =>
        BlocProvider(create: (_) => buildCubit(repository), child: child!),
    home: home,
  );
}

Widget _trackerHome() => const Scaffold(body: ApplicationsPage());

Widget _applyHome() => Builder(
  builder: (context) => Scaffold(
    body: Center(
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ApplyPage(
              jobId: 'j1',
              jobTitle: 'Customer Support Agent',
              employerId: 'e1',
              employerName: 'Demo Employer',
            ),
          ),
        ),
        child: const Text('Open'),
      ),
    ),
  ),
);

Future<void> _openApplyPage(
  WidgetTester tester,
  InMemoryApplicationRepository repository,
) async {
  await tester.pumpWidget(_app(repository, _applyHome()));
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  group('ApplyPage', () {
    testWidgets('submitting stores the application and goes back', (
      tester,
    ) async {
      final repository = InMemoryApplicationRepository();
      await _openApplyPage(tester, repository);

      expect(find.text('Customer Support Agent'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'I am a good fit.');
      await tester.tap(find.text('Submit application'));
      await tester.pumpAndSettle();

      expect(await repository.exists('j1_u1'), isTrue);
      expect(find.text('Submit application'), findsNothing);
    });

    testWidgets('applying twice shows a polite message and stays', (
      tester,
    ) async {
      final repository = InMemoryApplicationRepository([buildApplication()]);
      await _openApplyPage(tester, repository);

      await tester.tap(find.text('Submit application'));
      await tester.pumpAndSettle();

      expect(
        find.text('You have already applied for this job.'),
        findsOneWidget,
      );
      expect(find.text('Submit application'), findsOneWidget);
    });
  });

  group('ApplicationsPage', () {
    testWidgets('shows an empty state when there are no applications', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(InMemoryApplicationRepository(), _trackerHome()),
      );
      await tester.pump();
      await tester.pump();

      expect(
        find.text('No applications yet. Apply for a job and track it here.'),
        findsOneWidget,
      );
    });

    testWidgets('shows an error with a retry button when loading fails', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(FailingApplicationRepository(), _trackerHome()),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Could not load your applications.'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Could not load your applications.'), findsOneWidget);
    });

    testWidgets('withdrawing asks for confirmation, then removes the card', (
      tester,
    ) async {
      final repository = InMemoryApplicationRepository([buildApplication()]);
      await tester.pumpWidget(_app(repository, _trackerHome()));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byTooltip('Withdraw application'));
      await tester.pumpAndSettle();
      expect(find.text('Withdraw application?'), findsOneWidget);

      await tester.tap(find.text('Withdraw'));
      await tester.pumpAndSettle();
      await tester.pump();

      expect(find.text('Customer Support Agent'), findsNothing);
      expect(await repository.exists('j1_u1'), isFalse);
    });

    testWidgets('cancelling the dialog keeps the application', (tester) async {
      final repository = InMemoryApplicationRepository([buildApplication()]);
      await tester.pumpWidget(_app(repository, _trackerHome()));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byTooltip('Withdraw application'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Customer Support Agent'), findsOneWidget);
      expect(await repository.exists('j1_u1'), isTrue);
    });
  });
}
