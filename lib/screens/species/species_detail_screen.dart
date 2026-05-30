import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/models/info_item.dart';
import 'package:seznam_ghibli/navigation.dart';
import 'package:seznam_ghibli/providers/films_provider.dart';
import 'package:seznam_ghibli/providers/people_provider.dart';
import 'package:seznam_ghibli/screens/film_detail/film_detail_screen.dart';
import 'package:seznam_ghibli/screens/people/people_detail_screen.dart';
import 'package:seznam_ghibli/widgets/entity_section.dart';
import 'package:seznam_ghibli/widgets/info_row.dart';

/// Specie detail screen
class SpeciesDetailScreen extends ConsumerWidget {
  ///
  const SpeciesDetailScreen({required this.species, super.key});

  /// Specie
  final Species species;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final peopleState = ref.watch(peopleProvider);
    final filmsState = ref.watch(filmsProvider);

    _ensureData(ref);

    final infoEntries = <InfoItem>[
      InfoItem(label: 'Classification', value: species.classification),
      InfoItem(label: 'Eye Color', value: species.eyeColor),
      InfoItem(label: 'Hair Color', value: species.hairColor),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              species.name ?? '?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (infoEntries.any((e) => e.value != null)) ...[
              const SizedBox(height: 24),
              BuildInfoRow(theme: theme, entries: infoEntries),
            ],
            const SizedBox(height: 20),
            EntitySection<People>(
              title: 'People',
              icon: Icons.person,
              urls: species.people,
              state: _peopleToLoadState(peopleState),
              nameOf: (p) => p.name,
              urlOf: (p) => p.url ?? '',
              onTap: (p) {
                pushOrPopTo(
                  context,
                  MaterialPageRoute<void>(
                    settings: RouteSettings(name: peopleRoute(p.url ?? '')),
                    builder: (_) => PeopleDetailScreen(people: p),
                  ),
                );
              },
              onRetry: () => ref.read(peopleProvider.notifier).load(),
            ),
            EntitySection<Films>(
              title: 'Films',
              icon: Icons.movie,
              urls: species.films,
              state: _filmsToLoadState(filmsState),
              nameOf: (f) => f.title,
              urlOf: (f) => f.url ?? '',
              onTap: (f) {
                pushOrPopTo(
                  context,
                  MaterialPageRoute<void>(
                    settings: RouteSettings(name: filmsRoute(f.url ?? '')),
                    builder: (_) => FilmDetailScreen(film: f),
                  ),
                );
              },
              onRetry: () => ref.read(filmsProvider.notifier).load(),
            ),
          ],
        ),
      ),
    );
  }

  EntityLoadState<List<People>> _peopleToLoadState(PeopleState state) {
    return switch (state) {
      PeopleInitial() || PeopleLoading() => const EntityLoadInitial(),
      PeopleData(:final people) => EntityLoadData(people),
      PeopleError(:final failure) => EntityLoadError(failure),
    };
  }

  EntityLoadState<List<Films>> _filmsToLoadState(FilmsState state) {
    return switch (state) {
      FilmsInitial() || FilmsLoading() => const EntityLoadInitial(),
      FilmsData(:final films) => EntityLoadData(films),
      FilmsError(:final failure) => EntityLoadError(failure),
    };
  }
}

void _ensureData(WidgetRef ref) {
  if (ref.read(peopleProvider) is PeopleInitial) {
    unawaited(ref.read(peopleProvider.notifier).load());
  }
  if (ref.read(filmsProvider) is FilmsInitial) {
    unawaited(ref.read(filmsProvider.notifier).load());
  }
}
