import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/core/navigation/app_destination.dart';
import 'package:tujiajiri/core/navigation/home_shell.dart';

AppDestination page(String name, IconData icon) => AppDestination(
  label: name,
  icon: icon,
  selectedIcon: icon,
  builder: (_) => Scaffold(body: Center(child: Text('$name page'))),
);

final destinations = [
  page('Jobs', Icons.work),
  page('Tracker', Icons.assignment),
  page('Profile', Icons.person),
];

Future<void> pumpShell(
  WidgetTester tester, {
  Size size = const Size(400, 800),
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(home: HomeShell(destinations: destinations)),
  );
}

void main() {
  testWidgets('starts on the first tab with a bottom navigation bar', (
    tester,
  ) async {
    await pumpShell(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Jobs page'), findsOneWidget);
    expect(find.text('Tracker page'), findsNothing);
  });

  testWidgets('tapping a tab shows its page', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('Tracker'));
    await tester.pumpAndSettle();

    expect(find.text('Tracker page'), findsOneWidget);
    expect(find.text('Jobs page'), findsNothing);
  });

  testWidgets('back returns to the first tab instead of closing the app', (
    tester,
  ) async {
    await pumpShell(tester);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Jobs page'), findsOneWidget);
  });

  testWidgets('landscape shows a side rail with no overflow', (tester) async {
    await pumpShell(tester, size: const Size(800, 360));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Profile page'), findsOneWidget);
  });
}
