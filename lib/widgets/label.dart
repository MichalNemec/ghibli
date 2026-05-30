import 'package:flutter/material.dart';

/// A small tag with an optional icon and translucent background
class Label extends StatelessWidget {
  /// Creates a label with [text], optional [icon], and [color]
  const Label({
    required this.text,
    super.key,
    this.icon,
    this.color = Colors.black,
  });

  /// The text shown inside the label
  final String text;

  /// Optional icon displayed before the text
  final IconData? icon;

  /// The accent color used for the background tint and text
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: .circular(6),
        color: color.withValues(alpha: 0.15),
      ),
      child: Padding(
        padding: const .symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: .min,
          children: [
            Icon(icon, size: 12, color: color.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text(
              text,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
