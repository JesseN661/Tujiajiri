import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tujiajiri/features/profile/presentation/bloc/onboarding_cubit.dart';
import 'package:tujiajiri/features/profile/presentation/bloc/onboarding_state.dart';
import 'package:tujiajiri/features/profile/presentation/pages/onboarding_page.dart';

import '../../auth/test_support.dart';
import '../test_support.dart';

/// Pumps the onboarding page with fakes and returns the cubit and repo.
Future<(OnboardingCubit, FakeProfileRepository)> _pump(
  WidgetTester tester, {
  Size size = const Size(400, 900),
}) async {
  final repository = FakeProfileRepository();
  final cubit = OnboardingCubit(repository: repository, user: testUser);
  addTearDown(cubit.close);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  // The real gate only shows this page after the profile has loaded.
  await cubit.load();
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingCubit>.value(value: cubit),
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(repository: FakeAuthRepository()),
        ),
      ],
      child: const MaterialApp(home: OnboardingPage()),
    ),
  );
  await tester.pump();
  return (cubit, repository);
}

Future<void> _fillPersonal(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'Amina Uwase');
  await tester.enterText(fields.at(1), '0788123456');
  await tester.enterText(fields.at(2), 'Kigali');
}

Future<void> _addEducation(WidgetTester tester) async {
  await tester.tap(find.text('Add education'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.widgetWithText(TextFormField, 'School or institution'),
    'IPRC Kigali',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Qualification'),
    'Diploma',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Start year'),
    '2019',
  );
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('step 1 starts prefilled with the account name', (tester) async {
    await _pump(tester);

    expect(find.text('Step 1 of 3: Personal details'), findsOneWidget);
    expect(find.text('Amina Uwase'), findsOneWidget);
  });

  testWidgets('empty personal details block the Next button', (tester) async {
    final (cubit, _) = await _pump(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '');
    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Enter your full name.'), findsOneWidget);
    expect(find.text('Enter your phone number.'), findsOneWidget);
    expect(find.text('Enter your town or city.'), findsOneWidget);
    expect(cubit.state.step, OnboardingStep.personal);
  });

  testWidgets('valid personal details move to the education step', (
    tester,
  ) async {
    await _pump(tester);

    await _fillPersonal(tester);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2 of 3: Education'), findsOneWidget);
  });

  testWidgets('Back keeps what was typed on step 1', (tester) async {
    await _pump(tester);
    await _fillPersonal(tester);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('0788123456'), findsOneWidget);
    expect(find.text('Kigali'), findsOneWidget);
  });

  testWidgets('education can be added and removed', (tester) async {
    final (cubit, _) = await _pump(tester);
    await _fillPersonal(tester);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await _addEducation(tester);
    expect(find.textContaining('IPRC Kigali'), findsOneWidget);
    expect(cubit.state.education, hasLength(1));

    await tester.tap(find.byTooltip('Remove'));
    await tester.pump();
    expect(cubit.state.education, isEmpty);
    expect(find.text('No education added yet.'), findsOneWidget);
  });

  testWidgets('education form rejects an end year before the start year', (
    tester,
  ) async {
    final (cubit, _) = await _pump(tester);
    await _fillPersonal(tester);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add education'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'School or institution'),
      'IPRC Kigali',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Qualification'),
      'Diploma',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Start year'),
      '2020',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'End year (optional)'),
      '2018',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('End year cannot be before the start year.'),
      findsOneWidget,
    );
    expect(cubit.state.education, isEmpty);
  });

  testWidgets('Finish saves the profile and completes onboarding', (
    tester,
  ) async {
    final (cubit, repository) = await _pump(tester);
    await _fillPersonal(tester);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await _addEducation(tester);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Step 3 of 3: Experience'), findsOneWidget);

    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(cubit.state.status, OnboardingStatus.ready);
    expect(repository.savedProfile?.fullName, 'Amina Uwase');
    expect(repository.savedEducation.single.school, 'IPRC Kigali');
  });

  testWidgets('landscape layout does not overflow', (tester) async {
    await _pump(tester, size: const Size(800, 360));

    expect(tester.takeException(), isNull);
  });
}
