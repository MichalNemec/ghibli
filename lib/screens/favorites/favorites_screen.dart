import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/navigation.dart';
import 'package:seznam_ghibli/providers/favorites_provider.dart';
import 'package:seznam_ghibli/providers/films_provider.dart';
import 'package:seznam_ghibli/screens/film_detail/film_detail_screen.dart';
import 'package:seznam_ghibli/widgets/failure_widget.dart';
import 'package:seznam_ghibli/widgets/favorite_filter_content.dart';
import 'package:seznam_ghibli/widgets/film_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Favorites screen
class FavoritesScreen extends ConsumerWidget {
  ///
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filterProvider = ref.watch(favoritesFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: _BuildFilms()),
            Positioned(
              right: 16,
              bottom: 16,
              child: CueModalTransition(
                alignment: .bottomRight,
                barrierColor: Colors.transparent,
                motion: const .wobbly(dampingRatio: .7),
                hideTriggerOnTransition: true,
                triggerBuilder: (context, open) => FloatingActionButton(
                  key: const ValueKey('filter_fab'),
                  onPressed: open,
                  backgroundColor: !filterProvider.isDefault
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHigh,
                  elevation: 0.5,
                  shape: const CircleBorder(),
                  child: Icon(
                    Icons.filter_list,
                    color: !filterProvider.isDefault
                        ? theme.colorScheme.onPrimaryContainer
                        : null,
                  ),
                ),
                builder: (context, rect) {
                  return FavoriteFilterContent(size: rect.size);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildFilms extends ConsumerWidget {
  const _BuildFilms();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filmsState = ref.watch(filmsProvider);
    final filters = ref.watch(favoritesFilterProvider);
    final filtered = ref.watch(filteredFavoritesProvider(filters));

    if (filtered.isEmpty) {
      return const _BuildEmpty();
    }

    return filmsState.when(
      data: (films) {
        final favoriteFilms = films
            .where((f) => filtered.any((e) => e.key == f.id))
            .toList();
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: favoriteFilms.length,
          itemBuilder: (context, index) {
            final film = favoriteFilms[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Cue.onScrollVisible(
                key: ValueKey('fav_${film.id}'),
                acts: const [
                  .scale(from: 0.95),
                  .fadeIn(),
                ],
                child: FilmCard(
                  film: film,
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
      },
      error: (error, _) => FailureWidget(
        failure: error as Failure,
        onRetry: () => ref.invalidate(filmsProvider),
      ),
      loading: () => Skeletonizer(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          itemBuilder: (context, index) {
            return const SkeletonFilmCard();
          },
        ),
      ),
    );
  }
}

class _BuildEmpty extends StatelessWidget {
  const _BuildEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: .min,
        children: [
          Icon(Icons.favorite_rounded, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'No favorite films yet',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try to add ♥️ to films and come back here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}
