import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/models/search_result.dart';
import 'package:seznam_ghibli/navigation.dart';
import 'package:seznam_ghibli/providers/favorites_provider.dart';
import 'package:seznam_ghibli/providers/films_provider.dart';
import 'package:seznam_ghibli/providers/locations_provider.dart';
import 'package:seznam_ghibli/providers/people_provider.dart';
import 'package:seznam_ghibli/providers/species_provider.dart';
import 'package:seznam_ghibli/providers/vehicles_provider.dart';
import 'package:seznam_ghibli/screens/film_detail/film_detail_screen.dart';
import 'package:seznam_ghibli/screens/locations/locations_detail_screen.dart';
import 'package:seznam_ghibli/screens/people/people_detail_screen.dart';
import 'package:seznam_ghibli/screens/species/species_detail_screen.dart';
import 'package:seznam_ghibli/screens/vehicles/vehicles_detail_screen.dart';

/// Current search query string.
final AutoDisposeStateProvider<String> searchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

List<Films> _filmsOrEmpty(FilmsState s) => s is FilmsData ? s.films : [];
List<People> _peopleOrEmpty(PeopleState s) => s is PeopleData ? s.people : [];
List<Species> _speciesOrEmpty(SpeciesState s) =>
    s is SpeciesData ? s.species : [];
List<Locations> _locationsOrEmpty(LocationsState s) =>
    s is LocationsData ? s.locations : [];
List<Vehicles> _vehiclesOrEmpty(VehiclesState s) =>
    s is VehiclesData ? s.vehicles : [];

/// Search results matching the current query across all entity types.
final AutoDisposeProvider<List<SearchResult>> searchResultsProvider =
    Provider.autoDispose<List<SearchResult>>((ref) {
      final query = ref.watch(searchQueryProvider);
      if (query.isEmpty) return [];

      final filmsState = ref.watch(filmsProvider);
      final peopleState = ref.watch(peopleProvider);
      final speciesState = ref.watch(speciesProvider);
      final locationsState = ref.watch(locationsProvider);
      final vehiclesState = ref.watch(vehiclesProvider);

      final films = _filmsOrEmpty(filmsState);
      final people = _peopleOrEmpty(peopleState);
      final species = _speciesOrEmpty(speciesState);
      final locations = _locationsOrEmpty(locationsState);
      final vehicles = _vehiclesOrEmpty(vehiclesState);

      final hasErrors =
          filmsState is FilmsError ||
          peopleState is PeopleError ||
          speciesState is SpeciesError ||
          locationsState is LocationsError ||
          vehiclesState is VehiclesError;

      final favorites = ref.watch(favoritesProvider).ratings;

      final q = query.toLowerCase();
      final results = <SearchResult>[];

      for (final film in films) {
        if (film.title?.toLowerCase().contains(q) == true) {
          final url = film.url ?? '';
          results.add(
            SearchResult(
              label: film.title!,
              subtitle: 'Film',
              icon: Icons.movie,
              favorited: favorites.containsKey(film.id),
              route: () => MaterialPageRoute<void>(
                settings: RouteSettings(name: filmsRoute(url)),
                builder: (_) => FilmDetailScreen(film: film),
              ),
            ),
          );
        }
      }

      for (final p in people) {
        if (p.name?.toLowerCase().contains(q) == true) {
          final url = p.url ?? '';
          results.add(
            SearchResult(
              label: p.name!,
              subtitle: 'People',
              icon: Icons.person,
              route: () => MaterialPageRoute<void>(
                settings: RouteSettings(name: peopleRoute(url)),
                builder: (_) => PeopleDetailScreen(people: p),
              ),
            ),
          );
        }
      }

      for (final s in species) {
        if (s.name?.toLowerCase().contains(q) == true) {
          final url = s.url ?? '';
          results.add(
            SearchResult(
              label: s.name!,
              subtitle: 'Species',
              icon: Icons.biotech,
              route: () => MaterialPageRoute<void>(
                settings: RouteSettings(name: speciesRoute(url)),
                builder: (_) => SpeciesDetailScreen(species: s),
              ),
            ),
          );
        }
      }

      for (final l in locations) {
        if (l.name?.toLowerCase().contains(q) == true) {
          final url = l.url ?? '';
          results.add(
            SearchResult(
              label: l.name!,
              subtitle: 'Location',
              icon: Icons.location_on,
              route: () => MaterialPageRoute<void>(
                settings: RouteSettings(name: locationsRoute(url)),
                builder: (_) => LocationsDetailScreen(location: l),
              ),
            ),
          );
        }
      }

      for (final v in vehicles) {
        if (v.name?.toLowerCase().contains(q) == true) {
          final url = v.url ?? '';
          results.add(
            SearchResult(
              label: v.name!,
              subtitle: 'Vehicle',
              icon: Icons.directions_car,
              route: () => MaterialPageRoute<void>(
                settings: RouteSettings(name: vehiclesRoute(url)),
                builder: (_) => VehiclesDetailScreen(vehicle: v),
              ),
            ),
          );
        }
      }

      if (hasErrors && results.isEmpty) {
        results.add(
          const SearchResult(
            label: 'Some data is unavailable',
            subtitle: '',
            icon: Icons.error_outline,
            route: null,
          ),
        );
      }

      return results;
    });
