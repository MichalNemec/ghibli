import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/models/info_item.dart';
import 'package:seznam_ghibli/navigation.dart';
import 'package:seznam_ghibli/providers/films_provider.dart';
import 'package:seznam_ghibli/providers/species_provider.dart';
import 'package:seznam_ghibli/screens/film_detail/film_detail_screen.dart';
import 'package:seznam_ghibli/screens/species/species_detail_screen.dart';
import 'package:seznam_ghibli/widgets/entity_section.dart';
import 'package:seznam_ghibli/widgets/info_row.dart';

/// Person detail screen
class PeopleDetailScreen extends ConsumerWidget {
  ///
  const PeopleDetailScreen({required this.people, super.key});

  /// Person
  final People people;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filmsState = ref.watch(filmsProvider);
    final speciesState = ref.watch(speciesProvider);

    final infoEntries = <InfoItem>[
      InfoItem(label: 'Gender', value: people.gender),
      InfoItem(label: 'Age', value: people.age),
      InfoItem(label: 'Eye Color', value: people.eyeColor),
      InfoItem(label: 'Hair Color', value: people.hairColor),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              people.name ?? '?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (infoEntries.any((e) => e.value != null)) ...[
              const SizedBox(height: 24),
              BuildInfoRow(entries: infoEntries),
            ],
            const SizedBox(height: 20),
            if (people.species != null)
              EntitySection<Species>(
                title: 'Species',
                icon: Icons.biotech,
                urls: [people.species!],
                state: speciesState,
                nameOf: (s) => s.name,
                urlOf: (s) => s.url ?? '',
                onTap: (s) {
                  pushOrPopTo(
                    context,
                    MaterialPageRoute<void>(
                      settings: RouteSettings(name: speciesRoute(s.url ?? '')),
                      builder: (_) => SpeciesDetailScreen(species: s),
                    ),
                  );
                },
                onRetry: () => ref.invalidate(speciesProvider),
              ),
            EntitySection<Films>(
              title: 'Films',
              icon: Icons.movie,
              urls: people.films,
              state: filmsState,
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
              onRetry: () => ref.invalidate(filmsProvider),
            ),
          ],
        ),
      ),
    );
  }
}
