import 'package:flutter/material.dart';

/// Back and Next buttons at the bottom of an onboarding step.
class StepNavigation extends StatelessWidget {
  const StepNavigation({
    super.key,
    required this.nextLabel,
    required this.onNext,
    this.onBack,
    this.isBusy = false,
  });

  final String nextLabel;
  final VoidCallback onNext;

  /// Null on the first step, where there is nothing to go back to.
  final VoidCallback? onBack;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    const size = Size.fromHeight(52);
    return Row(
      children: [
        if (onBack != null) ...[
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: size),
              onPressed: isBusy ? null : onBack,
              child: const Text('Back'),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(minimumSize: size),
            onPressed: isBusy ? null : onNext,
            child: isBusy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(nextLabel),
          ),
        ),
      ],
    );
  }
}
