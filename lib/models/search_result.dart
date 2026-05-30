import 'package:flutter/material.dart';

/// A single search result linking a label to a navigable route.
class SearchResult {
  /// Creates a [SearchResult] with display info and a navigable route.
  const SearchResult({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.route,
    this.favorited = false,
  });

  /// Display name of the result (e.g. film title, person name).
  final String label;

  /// Category label (e.g. "Film", "People", "Species").
  final String subtitle;

  /// Icon representing the entity type.
  final IconData icon;

  /// Route to navigate to when the result is tapped.
  final MaterialPageRoute<void> Function()? route;

  /// Whether the result (film) is in the user's favorites.
  final bool favorited;
}
