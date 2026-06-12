import 'package:flutter/material.dart';

/// Entity Type for search usage.
// ignore: public_member_api_docs
enum EntityType { film, people, species, location, vehicle }

/// A single search result linking a label to a navigable route.
class SearchResult {
  /// Creates a [SearchResult] with display info and a navigable route.
  const SearchResult({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.url,
    required this.type,
    this.favorited = false,
  });

  /// Display name of the result (e.g. film title, person name).
  final String label;

  /// Category label (e.g. "Film", "People", "Species").
  final String subtitle;

  /// Icon representing the entity type.
  final IconData icon;

  /// URL
  final String url;

  /// Type representing the entity.
  final EntityType type;

  /// Whether the result (film) is in the user's favorites.
  final bool favorited;
}
