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

/// Location detail screen
class LocationsDetailScreen extends ConsumerWidget {
  ///
  const LocationsDetailScreen({required this.location, super.key});

  /// Location
  final Locations location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final peopleState = ref.watch(peopleProvider);
    final filmsState = ref.watch(filmsProvider);

    final infoEntries = <InfoItem>[
      InfoItem(label: 'Climate', value: location.climate),
      InfoItem(label: 'Terrain', value: location.terrain),
      InfoItem(
        label: 'Surface Water',
        value: location.surfaceWater != null ? '${location.surfaceWater}%' : null,
      ),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.name ?? '?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (infoEntries.any((e) => e.value != null)) ...[
              const SizedBox(height: 24),
              BuildInfoRow(entries: infoEntries),
            ],
            const SizedBox(height: 20),
            EntitySection<People>(
              title: 'Residents',
              icon: Icons.person,
              urls: location.residents,
              state: peopleState,
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
              onRetry: () => ref.invalidate(peopleProvider),
            ),
            EntitySection<Films>(
              title: 'Films',
              icon: Icons.movie,
              urls: location.films,
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
