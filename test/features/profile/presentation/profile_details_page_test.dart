import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tujiajiri/features/profile/domain/entities/user_profile.dart';
import 'package:tujiajiri/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:tujiajiri/features/profile/presentation/pages/profile_details_page.dart';
import 'package:tujiajiri/features/profile/presentation/profile_screen.dart';

import '../../auth/test_support.dart';
import '../test_support.dart';

const _profile = UserProfile(
  uid: 'u1',
  fullName: 'Amina Uwase',
  email: 'amina@example.com',
  phone: '0788123456',
  location: 'Kigali',
  onboardingComplete: true,
);

Future<FakeProfileRepository> _pump(
  WidgetTester tester,
  Widget page, {
  FakeProfileRepository? repository,
  Size size = const Size(400, 900),
}) async {
  final repo = repository ?? FakeProfileRepository(existing: _profile);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    RepositoryProvider<UserProfileRepository>.value(
      value: repo,
      child: BlocProvider<AuthCubit>(
        create: (_) => AuthCubit(
          repository: FakeAuthRepository(initialUser: verifiedUser),
        ),
        child: MaterialApp(home: page),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('shows the saved details, education and experience', (
    tester,
  ) async {
    final repo = FakeProfileRepository(existing: _profile)
      ..savedEducation = [sampleEducation]
      ..savedExperience = [sampleExperience];
    await _pump(tester, const ProfileDetailsPage(), repository: repo);

    expect(find.text('Amina Uwase'), findsOneWidget);
    expect(find.text('0788123456'), findsOneWidget);
    expect(find.text('Kigali'), findsOneWidget);
    expect(find.textContaining('IPRC Kigali'), findsOneWidget);
    expect(find.text('Sales assistant'), findsOneWidget);
  });

  testWidgets('editing personal details saves and updates the card', (
    tester,
  ) async {
    final repo = await _pump(tester, const ProfileDetailsPage());

    await tester.tap(find.byTooltip('Edit personal details'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Town or city'),
      'Huye',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.savedProfile?.location, 'Huye');
    expect(find.text('Huye'), findsOneWidget);
    expect(find.text('Personal details updated.'), findsOneWidget);
  });

  testWidgets('invalid personal details are rejected in the form', (
    tester,
  ) async {
    final repo = await _pump(tester, const ProfileDetailsPage());

    await tester.tap(find.byTooltip('Edit personal details'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number'),
      '12',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid phone number.'), findsOneWidget);
    expect(repo.savedProfile, isNull);
  });

  testWidgets('adding education saves it and shows it at once', (tester) async {
    final repo = await _pump(tester, const ProfileDetailsPage());
    expect(find.text('No education added yet.'), findsOneWidget);

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

    expect(repo.savedEducation.single.school, 'IPRC Kigali');
    expect(find.textContaining('IPRC Kigali'), findsOneWidget);
    expect(find.text('No education added yet.'), findsNothing);
  });

  testWidgets('editing an experience entry updates it', (tester) async {
    final repo = FakeProfileRepository(existing: _profile)
      ..savedExperience = [sampleExperience];
    await _pump(tester, const ProfileDetailsPage(), repository: repo);

    await tester.tap(find.text('Sales assistant'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Job title'),
      'Shop manager',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.savedExperience.single.role, 'Shop manager');
    expect(find.text('Shop manager'), findsOneWidget);
  });

  testWidgets('removing an entry asks first, then deletes it', (tester) async {
    final repo = FakeProfileRepository(existing: _profile)
      ..savedEducation = [sampleEducation];
    await _pump(tester, const ProfileDetailsPage(), repository: repo);

    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repo.savedEducation, isNotEmpty);

    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();

    expect(repo.savedEducation, isEmpty);
    expect(find.text('No education added yet.'), findsOneWidget);
  });

  testWidgets('a load error shows a retry button', (tester) async {
    await _pump(
      tester,
      const ProfileDetailsPage(),
      repository: FakeProfileRepository()..failing = true,
    );

    expect(find.text('We could not load your profile.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('landscape layout does not overflow', (tester) async {
    await _pump(tester, const ProfileDetailsPage(), size: const Size(800, 360));

    expect(tester.takeException(), isNull);
  });

  testWidgets('profile menu shows the account and opens the details page', (
    tester,
  ) async {
    await _pump(tester, const ProfileScreen());

    expect(find.text('Amina'), findsOneWidget);
    expect(find.text('amina@example.com'), findsOneWidget);
    expect(find.text('Skills & Interests'), findsOneWidget);
    expect(find.text('Preferences'), findsOneWidget);

    await tester.tap(find.text('Profile details'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileDetailsPage), findsOneWidget);
    expect(find.text('Amina Uwase'), findsOneWidget);
  });
}
