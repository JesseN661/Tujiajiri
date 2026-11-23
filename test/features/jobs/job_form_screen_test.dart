import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/jobs/data/job_repository.dart';
import 'package:tujiajiri/features/jobs/domain/entities/job.dart';
import 'package:tujiajiri/features/jobs/presentation/job_form_screen.dart';

void main() {
  late FakeFirebaseFirestore db;
  late JobRepository repository;

  setUp(() {
    db = FakeFirebaseFirestore();
    repository = JobRepository(firestore: db);
  });

  Future<void> pumpForm(WidgetTester tester, {Job? job}) {
    return tester.pumpWidget(
      MaterialApp(
        home: JobFormScreen(
          job: job,
          employerId: 'employer1',
          employerName: 'Kigali Tech',
          repository: repository,
        ),
      ),
    );
  }

  testWidgets('posting a job saves it as published', (tester) async {
    await pumpForm(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Job title'),
      'Sales Assistant',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Help customers in the shop.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Location'),
      'Kigali',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Experience level'),
      'Entry level',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Required skills'),
      'English, Sales, ',
    );
    await tester.ensureVisible(find.text('Post job'));
    await tester.tap(find.text('Post job'));
    await tester.pumpAndSettle();

    final jobs = await db.collection('jobs').get();
    expect(jobs.docs, hasLength(1));
    final data = jobs.docs.single.data();
    expect(data['title'], 'Sales Assistant');
    expect(data['employerId'], 'employer1');
    expect(data['status'], 'published');
    expect(data['isVerified'], isFalse);
    expect(data['requiredSkills'], ['English', 'Sales']);
    expect(find.text('Job posted.'), findsOneWidget);
  });

  testWidgets('empty fields are not saved', (tester) async {
    await pumpForm(tester);

    await tester.ensureVisible(find.text('Post job'));
    await tester.tap(find.text('Post job'));
    await tester.pump();

    expect(find.text('Required'), findsNWidgets(4));
    expect((await db.collection('jobs').get()).docs, isEmpty);
  });

  testWidgets('editing a job updates it', (tester) async {
    final id = await repository.createJob({
      'title': 'Cashier',
      'employerId': 'employer1',
      'status': 'published',
    });
    final job = (await repository.getJobById(id))!;

    await pumpForm(tester, job: job);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Handle payments.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Location'),
      'Musanze',
    );
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final saved = (await db.collection('jobs').doc(id).get()).data();
    expect(saved?['location'], 'Musanze');
    expect(saved?['employerId'], 'employer1');
    expect(find.text('Job updated.'), findsOneWidget);
  });
}
