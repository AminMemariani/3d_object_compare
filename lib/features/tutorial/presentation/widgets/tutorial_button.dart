import 'package:flutter/material.dart';

/// A button widget for starting the tutorial
class TutorialButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TutorialButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
        onPressed: onPressed,
        style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
        tooltip: 'Start Tutorial',
      ),
    );
  }
}
