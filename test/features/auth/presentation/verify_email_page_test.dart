import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/auth/presentation/pages/verify_email_page.dart';

import '../test_support.dart';

void main() {
  testWidgets('shows the address the link was sent to', (tester) async {
    await pumpAuthPage(
      tester,
      const VerifyEmailPage(),
      repository: FakeAuthRepository(initialUser: unverifiedUser),
    );

    expect(find.textContaining('amina@example.com'), findsOneWidget);
  });

  testWidgets('resend and refresh call the repository', (tester) async {
    final repo = await pumpAuthPage(
      tester,
      const VerifyEmailPage(),
      repository: FakeAuthRepository(initialUser: unverifiedUser),
    );

    await tester.tap(find.text('Resend email'));
    await tester.pump();
    await tester.tap(find.text('I have verified my email'));
    await tester.pump();

    expect(repo.calls, ['verify', 'reload']);
  });

  testWidgets('different account signs the user out', (tester) async {
    final repo = await pumpAuthPage(
      tester,
      const VerifyEmailPage(),
      repository: FakeAuthRepository(initialUser: unverifiedUser),
    );

    await tester.tap(find.text('Use a different account'));
    await tester.pump();

    expect(repo.calls, ['signOut']);
  });
}
