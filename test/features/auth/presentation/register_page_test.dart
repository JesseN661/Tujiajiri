import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:tujiajiri/features/auth/presentation/pages/register_page.dart';

import '../test_support.dart';

Future<void> _fill(
  WidgetTester tester, {
  String name = 'Amina Uwase',
  String email = 'amina@example.com',
  String password = 'abcdefg1',
  String confirmation = 'abcdefg1',
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), name);
  await tester.enterText(fields.at(1), email);
  await tester.enterText(fields.at(2), password);
  await tester.enterText(fields.at(3), confirmation);
}

void main() {
  testWidgets('empty form shows an error for every field', (tester) async {
    final repo = await pumpAuthPage(tester, const RegisterPage());

    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();

    expect(find.text('Enter your full name.'), findsOneWidget);
    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter a password.'), findsOneWidget);
    expect(find.text('Confirm your password.'), findsOneWidget);
    expect(repo.calls, isEmpty);
  });

  testWidgets('weak password is rejected', (tester) async {
    final repo = await pumpAuthPage(tester, const RegisterPage());

    await _fill(tester, password: 'abc', confirmation: 'abc');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();

    expect(
      find.text('Password must be at least 8 characters.'),
      findsOneWidget,
    );
    expect(repo.calls, isEmpty);
  });

  testWidgets('mismatched confirmation is rejected', (tester) async {
    final repo = await pumpAuthPage(tester, const RegisterPage());

    await _fill(tester, confirmation: 'different1');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();

    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(repo.calls, isEmpty);
  });

  testWidgets('valid form registers the account', (tester) async {
    final repo = await pumpAuthPage(tester, const RegisterPage());

    await _fill(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();

    expect(repo.calls, ['register:amina@example.com']);
  });
}
