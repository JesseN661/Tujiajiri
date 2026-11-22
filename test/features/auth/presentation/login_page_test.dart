import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/auth/domain/auth_failure.dart';
import 'package:tujiajiri/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:tujiajiri/features/auth/presentation/pages/login_page.dart';
import 'package:tujiajiri/features/auth/presentation/pages/register_page.dart';

import '../test_support.dart';

void main() {
  testWidgets('empty submit shows validation errors and calls nothing', (
    tester,
  ) async {
    final repo = await pumpAuthPage(tester, const LoginPage());

    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(repo.calls, isEmpty);
  });

  testWidgets('malformed email is rejected', (tester) async {
    final repo = await pumpAuthPage(tester, const LoginPage());

    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tester.enterText(find.byType(TextFormField).last, 'secret');
    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(repo.calls, isEmpty);
  });

  testWidgets('valid input signs in through the repository', (tester) async {
    final repo = await pumpAuthPage(tester, const LoginPage());

    await tester.enterText(
      find.byType(TextFormField).first,
      'amina@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'secret');
    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(repo.calls, ['signIn:amina@example.com']);
  });

  testWidgets('a failed login shows the error message', (tester) async {
    final repo = FakeAuthRepository()
      ..failure = const AuthFailure('Incorrect email or password.');
    await pumpAuthPage(tester, const LoginPage(), repository: repo);

    await tester.enterText(
      find.byType(TextFormField).first,
      'amina@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'wrong');
    await tester.tap(find.text('Log in'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });

  testWidgets('password visibility can be toggled', (tester) async {
    await pumpAuthPage(tester, const LoginPage());

    expect(find.byIcon(Icons.visibility), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  testWidgets('links open the register and reset pages', (tester) async {
    await pumpAuthPage(tester, const LoginPage());

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPage), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordPage), findsOneWidget);
  });

  testWidgets('Google button starts Google sign-in', (tester) async {
    final repo = await pumpAuthPage(tester, const LoginPage());

    await tester.tap(find.text('Continue with Google'));
    await tester.pump();

    expect(repo.calls, ['google']);
  });

  testWidgets('landscape layout scrolls without overflow', (tester) async {
    await pumpAuthPage(tester, const LoginPage(), size: const Size(800, 360));

    expect(tester.takeException(), isNull);
    expect(find.text('Log in'), findsWidgets);
  });
}
