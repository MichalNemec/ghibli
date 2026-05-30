import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/constants/rating.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/models/film_rating.dart';
import 'package:seznam_ghibli/providers/storage_provider.dart';
import 'package:seznam_ghibli/storage/favorites_storage.dart';

/// Base state for favorites management
sealed class FavoritesState {
  const FavoritesState(this.ratings);

  /// Map of ratings keyed by film ID
  final Map<String, FilmRating> ratings;
}

/// Favorites are still loading from storage
class FavoritesLoading extends FavoritesState {
  /// Creates a loading state with no ratings
  const FavoritesLoading() : super(const {});
}

/// Favorites have been loaded successfully
class FavoritesData extends FavoritesState {
  /// Creates a data state with the given [ratings]
  const FavoritesData(super.ratings);
}

/// An error occurred while loading or saving favorites
class FavoritesError extends FavoritesState {
  /// Creates an error state with the given [failure] and possibly stale ratings
  const FavoritesError(this.failure, super.ratings);

  /// Details about what went wrong
  final Failure failure;
}

/// Provider for the favorites state, backed by [FavoritesNotifier]
final favoritesProvider = NotifierProvider<FavoritesNotifier, FavoritesState>(
  FavoritesNotifier.new,
);

/// Manages favorite films and ratings, persisted via [FavoritesStorage]
class FavoritesNotifier extends Notifier<FavoritesState> {
  @override
  FavoritesState build() {
    unawaited(Future.microtask(_load));
    return const FavoritesLoading();
  }

  Map<String, FilmRating> _currentRatings() {
    return state.ratings;
  }

  Future<void> _load() async {
    try {
      final storage = ref.read(favoritesStorageProvider);
      final data = storage.getAll();
      state = FavoritesData(data);
    } on Exception catch (_) {
      state = const FavoritesError(
        UnknownFailure('Could not load your favorites.'),
        {},
      );
    }
  }

  Future<void> _persistOrFallback(Map<String, FilmRating> ratings) async {
    try {
      final storage = ref.read(favoritesStorageProvider);
      await storage.saveAll(ratings);
      state = FavoritesData(ratings);
    } on Exception catch (_) {
      state = FavoritesError(
        const UnknownFailure('Could not save your favorites.'),
        ratings,
      );
    }
  }

  /// Toggles the favorite status for the film with [filmId]
  Future<void> toggleFavorite(String filmId) async {
    final current = _currentRatings()[filmId] ?? const FilmRating();
    final updated = current.copyWith(isFavorite: !current.isFavorite);
    final next = {..._currentRatings(), filmId: updated};
    await _persistOrFallback(next);
  }

  /// Sets the star [rating] (1–[maxRating]) for the film with [filmId]
  Future<void> setRating(String filmId, int rating) async {
    checkRating(rating);
    final current = _currentRatings()[filmId];
    final updated = (current ?? const FilmRating()).copyWith(rating: rating);
    final next = {..._currentRatings(), filmId: updated};
    await _persistOrFallback(next);
  }

  /// Removes the rating from the film with [filmId]
  Future<void> removeRating(String filmId) async {
    final current = _currentRatings()[filmId];
    final updated = (current ?? const FilmRating()).clearRating();
    final next = {..._currentRatings(), filmId: updated};
    await _persistOrFallback(next);
  }

  /// Returns favorited entries, optionally filtered by rating range
  List<MapEntry<String, FilmRating>> getFiltered({
    int? minRating,
    int? maxRating,
  }) {
    final ratings = state.ratings;
    var entries = ratings.entries.where((e) => e.value.isFavorite);
    if (minRating != null) {
      entries = entries.where((e) => (e.value.rating ?? 0) >= minRating);
    }
    if (maxRating != null) {
      entries = entries.where((e) => (e.value.rating ?? 0) <= maxRating);
    }
    return entries.toList();
  }
}
