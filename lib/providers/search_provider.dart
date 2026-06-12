import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/models/search_result.dart';
import 'package:seznam_ghibli/providers/favorites_provider.dart';
import 'package:seznam_ghibli/providers/films_provider.dart';
import 'package:seznam_ghibli/providers/locations_provider.dart';
import 'package:seznam_ghibli/providers/people_provider.dart';
import 'package:seznam_ghibli/providers/species_provider.dart';
import 'package:seznam_ghibli/providers/vehicles_provider.dart';

/// Current search query string.
final AutoDisposeStateProvider<String> searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Keys of favorite films
final AutoDisposeProvider<Set<String>> favoriteIdSetProvider = Provider.autoDispose<Set<String>>(
  (ref) => ref.watch(favoritesProvider).keys.toSet(),
);

/// Search results matching the current query across all entity types.
final AutoDisposeProvider<List<SearchResult>> searchResultsProvider = Provider.autoDispose<List<SearchResult>>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final films = ref.watch(filmsProvider.select((s) => s.valueOrNull ?? []));
  final people = ref.watch(peopleProvider.select((s) => s.valueOrNull ?? []));
  final species = ref.watch(speciesProvider.select((s) => s.valueOrNull ?? []));
  final locations = ref.watch(locationsProvider.select((s) => s.valueOrNull ?? []));
  final vehicles = ref.watch(vehiclesProvider.select((s) => s.valueOrNull ?? []));
  final favorites = ref.watch(favoriteIdSetProvider);

  final q = query.toLowerCase();
  final results = <SearchResult>[];

  for (final film in films) {
    if (film.title?.toLowerCase().contains(q) == true) {
      results.add(
        SearchResult(
          label: film.title!,
          subtitle: 'Film',
          icon: Icons.movie,
          favorited: favorites.contains(film.id),
          url: film.url ?? '',
          type: .film,
        ),
      );
    }
  }

  for (final p in people) {
    if (p.name?.toLowerCase().contains(q) == true) {
      results.add(
        SearchResult(
          label: p.name!,
          subtitle: 'People',
          icon: Icons.person,
          url: p.url ?? '',
          type: .people,
        ),
      );
    }
  }

  for (final s in species) {
    if (s.name?.toLowerCase().contains(q) == true) {
      results.add(
        SearchResult(
          label: s.name!,
          subtitle: 'Species',
          icon: Icons.biotech,
          url: s.url ?? '',
          type: .species,
        ),
      );
    }
  }

  for (final l in locations) {
    if (l.name?.toLowerCase().contains(q) == true) {
      results.add(
        SearchResult(
          label: l.name!,
          subtitle: 'Location',
          icon: Icons.location_on,
          url: l.url ?? '',
          type: .location,
        ),
      );
    }
  }

  for (final v in vehicles) {
    if (v.name?.toLowerCase().contains(q) == true) {
      results.add(
        SearchResult(
          label: v.name!,
          subtitle: 'Vehicle',
          icon: Icons.directions_car,
          url: v.url ?? '',
          type: .vehicle,
        ),
      );
    }
  }

  return results;
});
