import 'package:flutter/material.dart';

import 'auth_feedback_listener.dart';

/// Shared page frame: scrolls (so landscape never overflows), is centred and
/// capped in width on large screens, and shows auth snackbars.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.children,
    this.title,
    this.actions = const [],
  });

  final List<Widget> children;

  /// App bar title; when null there is no app bar (used by the login page).
  final String? title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AuthFeedbackListener(
      child: Scaffold(
        appBar: title == null
            ? null
            : AppBar(title: Text(title!), actions: actions),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
