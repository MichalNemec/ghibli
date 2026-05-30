import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/extensions/e_color.dart';
import 'package:seznam_ghibli/models/film_rating.dart';
import 'package:seznam_ghibli/navigation.dart';
import 'package:seznam_ghibli/providers/favorites_provider.dart';
import 'package:seznam_ghibli/providers/locations_provider.dart';
import 'package:seznam_ghibli/providers/people_provider.dart';
import 'package:seznam_ghibli/providers/species_provider.dart';
import 'package:seznam_ghibli/providers/vehicles_provider.dart';
import 'package:seznam_ghibli/screens/locations/locations_detail_screen.dart';
import 'package:seznam_ghibli/screens/people/people_detail_screen.dart';
import 'package:seznam_ghibli/screens/species/species_detail_screen.dart';
import 'package:seznam_ghibli/screens/vehicles/vehicles_detail_screen.dart';
import 'package:seznam_ghibli/widgets/entity_section.dart';
import 'package:seznam_ghibli/widgets/label.dart';
import 'package:seznam_ghibli/widgets/rating_widget.dart';

/// Film detail screen
class FilmDetailScreen extends ConsumerStatefulWidget {
  ///
  const FilmDetailScreen({required this.film, super.key});

  /// Film
  final Films film;

  @override
  ConsumerState<FilmDetailScreen> createState() => _FilmDetailScreenState();
}

class _FilmDetailScreenState extends ConsumerState<FilmDetailScreen> {
  bool _entitiesLoadingTriggered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final film = widget.film;
    final filmRating = ref.watch(favoritesProvider).ratings[film.id ?? ''];
    final peopleState = ref.watch(peopleProvider);
    final speciesState = ref.watch(speciesProvider);
    final locationsState = ref.watch(locationsProvider);
    final vehiclesState = ref.watch(vehiclesProvider);

    _triggerEntityLoads();

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCard(film: film),
                    const SizedBox(height: 24),
                    _FilmMetadata(film: film),
                    const SizedBox(height: 20),
                    const SectionHeader(title: 'Synopsis'),
                    const SizedBox(height: 8),
                    Text(
                      film.description ?? '',
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    EntitySection<People>(
                      title: 'People',
                      icon: Icons.person,
                      urls: film.people,
                      state: _peopleToLoadState(peopleState),
                      nameOf: (p) => p.name,
                      urlOf: (p) => p.url ?? '',
                      onTap: (p) {
                        final pUrl = p.url ?? '';
                        pushOrPopTo(
                          context,
                          MaterialPageRoute<void>(
                            settings: RouteSettings(name: peopleRoute(pUrl)),
                            builder: (_) => PeopleDetailScreen(people: p),
                          ),
                        );
                      },
                      onRetry: () => ref.read(peopleProvider.notifier).load(),
                    ),
                    EntitySection<Species>(
                      title: 'Species',
                      icon: Icons.biotech,
                      urls: film.species,
                      state: _speciesToLoadState(speciesState),
                      nameOf: (s) => s.name,
                      urlOf: (s) => s.url ?? '',
                      onTap: (s) {
                        final sUrl = s.url ?? '';
                        pushOrPopTo(
                          context,
                          MaterialPageRoute<void>(
                            settings: RouteSettings(name: speciesRoute(sUrl)),
                            builder: (_) => SpeciesDetailScreen(species: s),
                          ),
                        );
                      },
                      onRetry: () => ref.read(speciesProvider.notifier).load(),
                    ),
                    EntitySection<Locations>(
                      title: 'Locations',
                      icon: Icons.location_on,
                      urls: film.locations,
                      state: _locationsToLoadState(locationsState),
                      nameOf: (l) => l.name,
                      urlOf: (l) => l.url ?? '',
                      match: (l) =>
                          film.url != null &&
                          (l.films ?? []).contains(film.url),
                      onTap: (l) {
                        final lUrl = l.url ?? '';
                        pushOrPopTo(
                          context,
                          MaterialPageRoute<void>(
                            settings: RouteSettings(name: locationsRoute(lUrl)),
                            builder: (_) => LocationsDetailScreen(location: l),
                          ),
                        );
                      },
                      onRetry: () =>
                          ref.read(locationsProvider.notifier).load(),
                    ),
                    EntitySection<Vehicles>(
                      title: 'Vehicles',
                      icon: Icons.directions_car,
                      urls: film.vehicles,
                      state: _vehiclesToLoadState(vehiclesState),
                      nameOf: (v) => v.name,
                      urlOf: (v) => v.url ?? '',
                      onTap: (v) {
                        final vUrl = v.url ?? '';
                        pushOrPopTo(
                          context,
                          MaterialPageRoute<void>(
                            settings: RouteSettings(name: vehiclesRoute(vUrl)),
                            builder: (_) => VehiclesDetailScreen(vehicle: v),
                          ),
                        );
                      },
                      onRetry: () => ref.read(vehiclesProvider.notifier).load(),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _RatingBar(filmId: film.id ?? '', filmRating: filmRating),
            ),
          ],
        ),
      ),
    );
  }

  void _triggerEntityLoads() {
    if (_entitiesLoadingTriggered) return;
    _entitiesLoadingTriggered = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(peopleProvider) is PeopleInitial) {
        unawaited(ref.read(peopleProvider.notifier).load());
      }
      if (ref.read(speciesProvider) is SpeciesInitial) {
        unawaited(ref.read(speciesProvider.notifier).load());
      }
      if (ref.read(locationsProvider) is LocationsInitial) {
        unawaited(ref.read(locationsProvider.notifier).load());
      }
      if (ref.read(vehiclesProvider) is VehiclesInitial) {
        unawaited(ref.read(vehiclesProvider.notifier).load());
      }
    });
  }

  EntityLoadState<List<People>> _peopleToLoadState(PeopleState state) {
    return switch (state) {
      PeopleInitial() || PeopleLoading() => const EntityLoadInitial(),
      PeopleData(:final people) => EntityLoadData(people),
      PeopleError(:final failure) => EntityLoadError(failure),
    };
  }

  EntityLoadState<List<Species>> _speciesToLoadState(SpeciesState state) {
    return switch (state) {
      SpeciesInitial() || SpeciesLoading() => const EntityLoadInitial(),
      SpeciesData(:final species) => EntityLoadData(species),
      SpeciesError(:final failure) => EntityLoadError(failure),
    };
  }

  EntityLoadState<List<Locations>> _locationsToLoadState(LocationsState state) {
    return switch (state) {
      LocationsInitial() || LocationsLoading() => const EntityLoadInitial(),
      LocationsData(:final locations) => EntityLoadData(locations),
      LocationsError(:final failure) => EntityLoadError(failure),
    };
  }

  EntityLoadState<List<Vehicles>> _vehiclesToLoadState(VehiclesState state) {
    return switch (state) {
      VehiclesInitial() || VehiclesLoading() => const EntityLoadInitial(),
      VehiclesData(:final vehicles) => EntityLoadData(vehicles),
      VehiclesError(:final failure) => EntityLoadError(failure),
    };
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.film});

  final Films film;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = EColor.hashColor(film.id ?? '');
    final tc = color.contrastColor;
    final showOriginal =
        film.originalTitle != null && film.originalTitle != film.title;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              film.title ?? '?',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: tc,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showOriginal)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  film.originalTitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tc.withValues(alpha: 0.7),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              spacing: 6,
              children: [
                if (film.releaseDate != null)
                  Label(
                    text: film.releaseDate!,
                    icon: Icons.calendar_today,
                    color: tc,
                  ),
                if (film.runningTime != null)
                  Label(
                    text: '${film.runningTime}m',
                    icon: Icons.timer_outlined,
                    color: tc,
                  ),
                if (film.rtScore != null)
                  Label(
                    text: '${film.rtScore}%',
                    icon: Icons.star_rate_rounded,
                    color: tc,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilmMetadata extends StatelessWidget {
  const _FilmMetadata({required this.film});

  final Films film;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = <_MetaEntry>[
      if (film.director != null)
        _MetaEntry(
          icon: Icons.missed_video_call_outlined,
          label: 'Director',
          value: film.director!,
        ),
      if (film.producer != null)
        _MetaEntry(
          icon: Icons.business,
          label: 'Producer',
          value: film.producer!,
        ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 16,
        children: [
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                spacing: 12,
                children: [
                  Text(
                    e.value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      Icon(
                        e.icon,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      Text(
                        e.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MetaEntry {
  const _MetaEntry({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({required this.filmId, required this.filmRating});

  final String filmId;
  final FilmRating? filmRating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.surfaceContainerHigh,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: FilmRatingTile(filmId: filmId, filmRating: filmRating),
      ),
    );
  }
}
