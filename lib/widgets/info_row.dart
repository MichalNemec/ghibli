import 'package:flutter/material.dart';
import 'package:seznam_ghibli/models/info_item.dart';

/// A horizontal row of [_InfoRow] widgets filtered to non-null values
class BuildInfoRow extends StatelessWidget {
  /// Creates an info row [entries]
  const BuildInfoRow({
    required this.entries,
    super.key,
  });

  /// Info entries to display; those with null values are skipped
  final List<InfoItem> entries;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 16,
        children: [
          for (final e in entries.where((e) => e.value != null))
            _InfoRow(label: e.label, value: e.value!),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        spacing: 12,
        children: [
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
