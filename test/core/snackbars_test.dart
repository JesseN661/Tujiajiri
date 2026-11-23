import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tujiajiri/core/presentation/snackbars.dart';

Widget host(void Function(BuildContext context) onPressed) => MaterialApp(
  home: Scaffold(
    body: Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => onPressed(context),
        child: const Text('Go'),
      ),
    ),
  ),
);

void main() {
  testWidgets('showMessage displays the text', (tester) async {
    await tester.pumpWidget(host((context) => context.showMessage('Saved.')));
    await tester.tap(find.text('Go'));
    await tester.pump();

    expect(find.text('Saved.'), findsOneWidget);
  });

  testWidgets('showError displays a friendly message, not the raw error', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        (context) => context.showError(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
      ),
    );
    await tester.tap(find.text('Go'));
    await tester.pump();

    expect(find.text("You don't have permission to do that."), findsOneWidget);
    expect(find.textContaining('cloud_firestore'), findsNothing);
  });

  testWidgets('a new message replaces the current one', (tester) async {
    var count = 0;
    await tester.pumpWidget(
      host((context) => context.showMessage('Message ${++count}')),
    );
    await tester.tap(find.text('Go'));
    await tester.pump();
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    expect(find.text('Message 2'), findsOneWidget);
    expect(find.text('Message 1'), findsNothing);
  });
}
