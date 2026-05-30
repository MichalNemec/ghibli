import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/extensions/e_color.dart';
import 'package:seznam_ghibli/models/film_rating.dart';
import 'package:seznam_ghibli/widgets/label.dart';
import 'package:seznam_ghibli/widgets/rating_widget.dart';

/// A tappable card displaying film metadata and a rating tile
class FilmCard extends ConsumerWidget {
  /// Creates a card for the given [film] with optional [filmRating] and [onTap]
  const FilmCard({
    required this.film,
    super.key,
    this.filmRating,
    this.onTap,
  });

  /// The film to display
  final Films film;

  /// The user's rating and favorite status for this film
  final FilmRating? filmRating;

  /// Called when the card is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = EColor.hashColor(film.id ?? '');
    final showOriginal =
        film.originalTitle != null && film.originalTitle != film.title;
    final tc = color.contrastColor;

    return InkWell(
      borderRadius: .circular(24),
      onTap: onTap,
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const .all(.circular(24)),
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.8),
                  color.withValues(alpha: 0.4),
                ],
                begin: .topLeft,
                end: .bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    film.title ?? '?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: tc,
                      fontWeight: .bold,
                    ),
                  ),
                  if (showOriginal)
                    Padding(
                      padding: const .only(top: 2),
                      child: Text(
                        film.originalTitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tc.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
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
                  if (film.description != null &&
                      film.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      film.description!,
                      maxLines: 3,
                      overflow: .ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tc.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: .circular(24),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.surfaceContainerHigh
                              .withValues(alpha: 0.20),
                          Theme.of(context).colorScheme.surfaceContainerHigh
                              .withValues(alpha: 0.35),
                        ],
                        begin: .topLeft,
                        end: .bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const .symmetric(horizontal: 16, vertical: 10),
                      child: FilmRatingTile(
                        filmId: film.id ?? '',
                        filmRating: filmRating,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A placeholder card shown while films are loading
class SkeletonFilmCard extends StatelessWidget {
  /// Creates a loading placeholder with dummy content
  const SkeletonFilmCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const .all(16),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  'Dummy title',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: .bold,
                  ),
                ),
                Padding(
                  padding: const .only(top: 2),
                  child: Text(
                    'Dummy Title',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  spacing: 6,
                  children: [
                    Label(
                      text: '2026',
                      icon: Icons.calendar_today,
                    ),
                    Label(
                      text: '120m',
                      icon: Icons.timer_outlined,
                    ),
                    Label(
                      text: '99%',
                      icon: Icons.star_rate_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet',
                  maxLines: 3,
                  overflow: .ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const Padding(
            padding: .symmetric(vertical: 4, horizontal: 8),
            child: FilmRatingTile(
              filmId: '',
              filmRating: FilmRating(),
            ),
          ),
        ],
      ),
    );
  }
}
