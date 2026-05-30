import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/constants/rating.dart';
import 'package:seznam_ghibli/navigation.dart';
import 'package:seznam_ghibli/providers/favorites_provider.dart';
import 'package:seznam_ghibli/providers/films_provider.dart';
import 'package:seznam_ghibli/screens/film_detail/film_detail_screen.dart';
import 'package:seznam_ghibli/widgets/failure_widget.dart';
import 'package:seznam_ghibli/widgets/film_card.dart';
import 'package:seznam_ghibli/widgets/star_range_slider.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Favorites screen
class FavoritesScreen extends ConsumerStatefulWidget {
  ///
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  int _minFilter = minRating;
  int _maxFilter = maxRating;
  bool _showUnrated = true;
  bool get isFilterDefault =>
      _minFilter == minRating && _maxFilter == maxRating;
  bool get resetAvailable =>
      _minFilter != minRating || _maxFilter != maxRating || !_showUnrated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filmsState = ref.watch(filmsProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: _BuildFilms(
                ref: ref,
                showUnrated: _showUnrated,
                minFilter: _minFilter,
                maxFilter: _maxFilter,
                context: context,
                filmsState: filmsState,
                favorites: favorites,
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: CueModalTransition(
                alignment: Alignment.bottomRight,
                barrierColor: Colors.transparent,
                motion: const .wobbly(dampingRatio: .7),
                hideTriggerOnTransition: true,
                triggerBuilder: (context, open) => FloatingActionButton(
                  key: const ValueKey('filter_fab'),
                  onPressed: open,
                  backgroundColor: !isFilterDefault
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHigh,
                  elevation: 0.5,
                  shape: const CircleBorder(),
                  child: Icon(
                    Icons.filter_list,
                    color: !isFilterDefault
                        ? theme.colorScheme.onPrimaryContainer
                        : null,
                  ),
                ),
                builder: (context, rect) {
                  return StatefulBuilder(
                    builder: (context, localSetState) {
                      return Actor(
                        acts: const [.translate(to: Offset(-28, -28))],
                        child: Material(
                          clipBehavior: Clip.hardEdge,
                          borderRadius: BorderRadius.circular(32),
                          color: theme.colorScheme.surfaceContainerHigh,
                          elevation: 2,
                          shadowColor: Colors.black.withValues(alpha: 0.3),
                          child: Actor(
                            acts: [
                              .sizedClip(
                                from: .size(rect.size),
                                to: const .width(280),
                                alignment: Alignment.bottomRight,
                              ),
                              const .opacity(from: 0, to: 1),
                              const .slideY(from: 0.4),
                            ],
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 48,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Filter by rating',
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        IconButton(
                                          key: const ValueKey('reset_filter'),
                                          onPressed: !resetAvailable
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _minFilter = minRating;
                                                    _maxFilter = maxRating;
                                                    _showUnrated = true;
                                                  });
                                                  localSetState(() {});
                                                },
                                          icon: Icon(
                                            Icons.filter_list_off,
                                            color: !resetAvailable
                                                ? theme
                                                      .colorScheme
                                                      .onSurfaceVariant
                                                      .withValues(alpha: 0.3)
                                                : theme.colorScheme.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Center(
                                    child: StarRangeSlider(
                                      key: const ValueKey('star_range_slider'),
                                      min: _minFilter,
                                      max: _maxFilter,
                                      onChanged: (v) {
                                        setState(() {
                                          _minFilter = v.start.round();
                                          _maxFilter = v.end.round();
                                        });
                                        localSetState(() {});
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text('Show unrated'),
                                      const Spacer(),
                                      Switch(
                                        key: const ValueKey(
                                          'show_unrated_switch',
                                        ),
                                        value: _showUnrated,
                                        onChanged: (v) {
                                          setState(() => _showUnrated = v);
                                          localSetState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildFilms extends StatelessWidget {
  const _BuildFilms({
    required this.ref,
    required this._showUnrated,
    required this._minFilter,
    required this._maxFilter,
    required this.context,
    required this.filmsState,
    required this.favorites,
  });

  final WidgetRef ref;
  final bool _showUnrated;
  final int _minFilter;
  final int _maxFilter;
  final BuildContext context;
  final FilmsState filmsState;
  final FavoritesState favorites;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (filmsState is FilmsLoading || filmsState is FilmsInitial) {
      return Skeletonizer(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          itemBuilder: (context, index) {
            return const SkeletonFilmCard();
          },
        ),
      );
    }

    if (filmsState is FilmsError) {
      return FailureWidget(
        failure: (filmsState as FilmsError).failure,
        onRetry: () => ref.read(filmsProvider.notifier).load(),
      );
    }

    final films = (filmsState as FilmsData).films;
    final ratings = favorites.ratings;

    final filtered = ratings.entries.where((e) => e.value.isFavorite);
    final ranged = filtered.where((e) {
      final r = e.value.rating;
      if (r == null) return _showUnrated;
      return r >= _minFilter && r <= _maxFilter;
    }).toList();

    if (ranged.isEmpty) {
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

    final favoriteFilms = films
        .where((f) => ranged.any((e) => e.key == f.id))
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
              filmRating: ratings[film.id ?? ''],
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
