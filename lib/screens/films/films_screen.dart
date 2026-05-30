import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/models/film_rating.dart';
import 'package:seznam_ghibli/navigation.dart';
import 'package:seznam_ghibli/providers/favorites_provider.dart';
import 'package:seznam_ghibli/providers/films_provider.dart';
import 'package:seznam_ghibli/screens/film_detail/film_detail_screen.dart';
import 'package:seznam_ghibli/widgets/failure_widget.dart';
import 'package:seznam_ghibli/widgets/film_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

///Films screen acting as homepge
class FilmsScreen extends ConsumerWidget {
  ///
  const FilmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filmsState = ref.watch(filmsProvider);
    final favorites = ref.watch(favoritesProvider);

    return switch (filmsState) {
      FilmsInitial() || FilmsLoading() => const _BuildFilmsSkeleton(),
      FilmsData(:final films) => _BuildFilms(
        films: films,
        favorites: favorites.ratings,
      ),
      FilmsError(:final failure) => FailureWidget(
        failure: failure,
        onRetry: () => ref.read(filmsProvider.notifier).load(),
      ),
    };
  }
}

class _BuildFilmsSkeleton extends StatelessWidget {
  const _BuildFilmsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: 5,
        itemBuilder: (context, index) {
          return const SkeletonFilmCard();
        },
      ),
    );
  }
}

class _BuildFilms extends StatelessWidget {
  const _BuildFilms({
    required this.films,
    required this.favorites,
  });

  final List<Films> films;
  final Map<String, FilmRating> favorites;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: films.length,
      itemBuilder: (context, index) {
        final film = films[index];
        final filmId = film.id ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Cue.onScrollVisible(
            key: ValueKey('fs_$filmId'),
            acts: const [
              .scale(from: 0.95),
              .fadeIn(),
            ],
            child: FilmCard(
              film: film,
              filmRating: favorites[filmId],
              onTap: () {
                final routeName = filmsRoute(film.url ?? '');
                pushOrPopTo(
                  context,
                  MaterialPageRoute<void>(
                    settings: RouteSettings(name: routeName),
                    builder: (_) => FilmDetailScreen(film: film),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
