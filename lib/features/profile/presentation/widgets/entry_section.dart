import 'package:flutter/material.dart';

/// A titled list (education or experience) with an add button.
class EntrySection extends StatelessWidget {
  const EntrySection({
    super.key,
    required this.title,
    required this.addLabel,
    required this.emptyText,
    required this.onAdd,
    required this.children,
  });

  final String title;
  final String addLabel;
  final String emptyText;
  final VoidCallback onAdd;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(addLabel),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (children.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(emptyText, textAlign: TextAlign.center),
          ),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }
}
