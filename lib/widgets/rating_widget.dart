import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/constants/rating.dart';
import 'package:seznam_ghibli/models/film_rating.dart';
import 'package:seznam_ghibli/providers/favorites_provider.dart';

/// A row of tappable stars for rating a film.
///
/// Supports tap to set a rating and long-press to clear it, with a
/// subtle color animation on hold.
class RatingWidget extends StatefulWidget {
  /// Creates a rating widget for the film with [filmId]
  const RatingWidget({
    required this.filmId,
    super.key,
    this.size = 24,
    this.rating,
    this.onChanged,
  });

  /// The film identifier used for the star keys
  final String filmId;

  /// The icon size for each star
  final double size;

  /// The current rating value (1–[maxRating]), or null if unrated
  final int? rating;

  /// Called with the new rating when a star is tapped, or 0 on clear
  final ValueChanged<int>? onChanged;

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();

    // 500ms matches Flutter's default internal long-press timeout
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: ratingColor,
      end: Colors.red,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper to check if a valid rating is actually set
  bool get _hasRating => widget.rating != null && widget.rating! > 0;

  void _startHolding() {
    if (_hasRating) {
      setState(() => _isHolding = true);
      unawaited(_controller.forward());
    }
  }

  void _stopHolding() {
    if (_isHolding) {
      setState(() => _isHolding = false);
      unawaited(_controller.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: List.generate(maxRating, (i) {
        final starIndex = i + 1;
        final filled = widget.rating != null && starIndex <= widget.rating!;

        return AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            final starColor = filled ? (_isHolding ? _colorAnimation.value! : ratingColor) : Colors.grey;

            return GestureDetector(
              key: ValueKey('star_${widget.filmId}_$starIndex'),
              onTapDown: (_) => _startHolding(),
              onTapUp: (_) => _stopHolding(),
              onTapCancel: _stopHolding,

              // Normal tap selection
              onTap: widget.onChanged != null ? () => widget.onChanged!(starIndex) : null,
              onLongPress: (_hasRating && widget.onChanged != null)
                  ? () async {
                      await HapticFeedback.mediumImpact();
                      widget.onChanged!(0);

                      _stopHolding();
                    }
                  : null,
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_border_rounded,
                color: starColor,
                size: widget.size,
              ),
            );
          },
        );
      }),
    );
  }
}

/// A combined favorite-toggle and rating widget for a single film
class FilmRatingTile extends ConsumerWidget {
  /// Creates a tile for the film with [filmId] and optional [filmRating]
  const FilmRatingTile({
    required this.filmId,
    super.key,
    this.filmRating,
  });

  /// The film identifier used for keys and storage
  final String filmId;

  /// The current favorite and rating data for this film
  final FilmRating? filmRating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rating = filmRating?.rating;

    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        IconButton(
          key: ValueKey('fav_$filmId'),
          icon: Icon(
            filmRating?.isFavorite == true ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: filmRating?.isFavorite == true ? Colors.red : null,
          ),
          onPressed: () {
            unawaited(
              ref.read(favoritesProvider.notifier).toggleFavorite(filmId),
            );
          },
        ),
        Padding(
          padding: const .only(right: 8),
          child: RatingWidget(
            filmId: filmId,
            rating: rating,
            onChanged: (r) {
              if (r == 0) {
                unawaited(
                  ref.read(favoritesProvider.notifier).removeRating(filmId),
                );
              } else {
                unawaited(
                  ref.read(favoritesProvider.notifier).setRating(filmId, r),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
