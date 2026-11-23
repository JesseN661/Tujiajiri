import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/features/applications/data/repositories/in_memory_application_repository.dart';
import 'package:tujiajiri/features/auth/presentation/pages/login_page.dart';
import 'package:tujiajiri/main.dart';

import '../features/auth/test_support.dart';
import '../features/profile/test_support.dart';

void main() {
  testWidgets('app starts on the login page when signed out', (tester) async {
    await tester.pumpWidget(
      TujiajiriApp(
        authRepository: FakeAuthRepository(),
        profileRepository: FakeProfileRepository(),
        applicationRepository: InMemoryApplicationRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Log in to continue'), findsOneWidget);
  });
}
