import 'package:flutter/material.dart';

import '../error/error_messages.dart';

/// Snackbars: context.showMessage('Saved.') or context.showError(e).
extension SnackBars on BuildContext {
  /// Shows [message] in place of any current snackbar.
  void showMessage(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Shows a friendly version of [error].
  void showError(Object error) => showMessage(friendlyMessage(error));
}
