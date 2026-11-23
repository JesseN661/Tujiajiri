import 'package:flutter/material.dart';

import '../error/error_messages.dart';

/// One way to give feedback everywhere in the app.
///
/// ```dart
/// context.showMessage('Profile saved.');
/// context.showError(error); // any exception -> friendly text
/// ```
extension SnackBars on BuildContext {
  /// Shows [message], replacing any snackbar that is already visible.
  void showMessage(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Shows a user-friendly version of [error].
  void showError(Object error) => showMessage(friendlyMessage(error));
}
