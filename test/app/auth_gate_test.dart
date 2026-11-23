import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/app/auth_gate.dart';
import 'package:tujiajiri/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tujiajiri/features/auth/presentation/pages/login_page.dart';
import 'package:tujiajiri/features/auth/presentation/pages/register_page.dart';
import 'package:tujiajiri/features/auth/presentation/pages/verify_email_page.dart';
import 'package:tujiajiri/features/profile/domain/entities/user_profile.dart';
import 'package:tujiajiri/features/profile/domain/repositories/user_profile_repository.dart';

import '../features/auth/test_support.dart';
import '../features/profile/test_support.dart';

const _finishedProfile = UserProfile(
  uid: 'u1',
  fullName: 'Amina',
  email: 'amina@example.com',
  onboardingComplete: true,
);

Future<void> _pumpGate(
  WidgetTester tester, {
  required FakeAuthRepository auth,
  FakeProfileRepository? profiles,
}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    RepositoryProvider<UserProfileRepository>.value(
      value: profiles ?? FakeProfileRepository(),
      child: BlocProvider(
        create: (_) => AuthCubit(repository: auth),
        child: MaterialApp(
          home: AuthGate(homeBuilder: (_) => const Text('HOME SCREEN')),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('no saved session shows the login page', (tester) async {
    await _pumpGate(tester, auth: FakeAuthRepository());

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('saved unverified session asks to verify the email', (
    tester,
  ) async {
    await _pumpGate(
      tester,
      auth: FakeAuthRepository(initialUser: unverifiedUser),
    );

    expect(find.byType(VerifyEmailPage), findsOneWidget);
  });

  testWidgets('saved session without a profile shows onboarding', (
    tester,
  ) async {
    await _pumpGate(
      tester,
      auth: FakeAuthRepository(initialUser: verifiedUser),
    );

    expect(find.text('Step 1 of 3: Personal details'), findsOneWidget);
  });

  testWidgets('saved session with a finished profile skips to home', (
    tester,
  ) async {
    await _pumpGate(
      tester,
      auth: FakeAuthRepository(initialUser: verifiedUser),
      profiles: FakeProfileRepository(existing: _finishedProfile),
    );

    expect(find.text('HOME SCREEN'), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
  });

  testWidgets('a profile load error offers retry', (tester) async {
    await _pumpGate(
      tester,
      auth: FakeAuthRepository(initialUser: verifiedUser),
      profiles: FakeProfileRepository()..failing = true,
    );

    expect(find.text('We could not load your profile.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('registering moves from register page to verify email', (
    tester,
  ) async {
    await _pumpGate(tester, auth: FakeAuthRepository());
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPage), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Amina Uwase');
    await tester.enterText(fields.at(1), 'amina@example.com');
    await tester.enterText(fields.at(2), 'abcdefg1');
    await tester.enterText(fields.at(3), 'abcdefg1');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.byType(VerifyEmailPage), findsOneWidget);
    expect(find.byType(RegisterPage), findsNothing);
  });

  testWidgets('verifying the email moves on to onboarding', (tester) async {
    final auth = FakeAuthRepository(initialUser: unverifiedUser)
      ..reloadResult = verifiedUser;
    await _pumpGate(tester, auth: auth);

    await tester.tap(find.text('I have verified my email'));
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 3: Personal details'), findsOneWidget);
  });

  testWidgets('logging out returns to the login page', (tester) async {
    final auth = FakeAuthRepository(initialUser: verifiedUser);
    await _pumpGate(
      tester,
      auth: auth,
      profiles: FakeProfileRepository(existing: _finishedProfile),
    );
    expect(find.text('HOME SCREEN'), findsOneWidget);

    auth.emitUser(null);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('HOME SCREEN'), findsNothing);
  });
}
