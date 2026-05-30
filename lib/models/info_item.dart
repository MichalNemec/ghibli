/// A key-value pair for displaying entity metadata.
class InfoItem {
  /// Creates an info item with a [label] and optional [value].
  const InfoItem({required this.label, required this.value});

  /// Label of the info
  final String label;

  /// Value of the info
  final String? value;
}
