import 'package:flutter/material.dart';
import 'package:seznam_ghibli/core/failure.dart';

/// Displays an error with an optional retry button.
///
/// Renders in a compact inline form or a centered full-width form
/// depending on the `compact` flag.
class FailureWidget extends StatelessWidget {
  /// Creates a failure display for the given [failure]
  const FailureWidget({
    required this.failure,
    super.key,
    this.onRetry,
    this.compact = false,
  });

  /// The error details to display (message and icon)
  final Failure failure;

  /// Called when the user taps the retry button
  final VoidCallback? onRetry;

  /// Whether to render compact inline (`true`) or centered (`false`)
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(left: 36),
        child: Row(
          children: [
            Icon(failure.icon, size: 18, color: Colors.red[300]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                failure.message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.red[300],
                ),
              ),
            ),
            if (onRetry != null)
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(failure.icon, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
