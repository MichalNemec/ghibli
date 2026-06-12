import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/constants/rating.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/models/film_rating.dart';
import 'package:seznam_ghibli/providers/storage_provider.dart';
import 'package:seznam_ghibli/storage/favorites_storage.dart';

/// Provider for the favorites state, backed by [FavoritesNotifier]
final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Map<String, FilmRating>>(
      FavoritesNotifier.new,
    );

/// Manages favorite films and ratings, persisted via [FavoritesStorage]
class FavoritesNotifier extends Notifier<Map<String, FilmRating>> {
  @override
  Map<String, FilmRating> build() {
    try {
      final storage = ref.read(favoritesStorageProvider);
      return storage
          .getAll(); // Riverpod handles putting this into AsyncData or AsyncLoading
    } on Exception catch (_) {
      throw const UnknownFailure('Could not load your favorites.');
    }
  }

  /// Toggles the favorite status for the film with [filmId]
  void toggleFavorite(String filmId) {
    final current = state[filmId] ?? const FilmRating();
    final updated = current.copyWith(isFavorite: !current.isFavorite);
    state = {...state, filmId: updated};
    unawaited(_persist());
  }

  /// Sets the star [rating] (1–[kMaxRating]) for the film with [filmId]
  void setRating(String filmId, int rating) {
    final current = state[filmId] ?? const FilmRating();
    final FilmRating updated;

    if (rating != 0) {
      checkRating(rating);
      updated = current.copyWith(rating: rating);
    } else {
      updated = current.clearRating();
    }

    state = {...state, filmId: updated};
    unawaited(_persist());
  }

  /// Private helper that updates local state immediately, updates storage,
  /// and automatically falls back if persistence fails.
  Future<void> _persist() async {
    final storage = ref.read(favoritesStorageProvider);
    try {
      await storage.saveAll(state);
    } catch (e, stacktrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: stacktrace,
          context: ErrorDescription('favorites persist'),
        ),
      );
      // Optionally revert the optimistic state
      state = storage.getAll();
    }
  }
}

/// Filter parameters data class
class FavoriteFilters {
  ///
  const FavoriteFilters({
    required this.minRating,
    required this.maxRating,
    this.showUnrated = true,
  });

  /// Minimum star rating value.
  final int minRating;

  /// Maximum star rating value.
  final int maxRating;

  /// Toggle to show unrated films.
  final bool showUnrated;

  /// Returns true if values match defaults
  bool get isDefault =>
      minRating == kMinRating && maxRating == kMaxRating && showUnrated;
}

/// A specialized provider that dynamically exposes filtered favorites.
final ProviderFamily<List<MapEntry<String, FilmRating>>, FavoriteFilters>
filteredFavoritesProvider =
    Provider.family<List<MapEntry<String, FilmRating>>, FavoriteFilters>((
      ref,
      filters,
    ) {
      // Watch the raw favorites state
      final ratings = ref.watch(favoritesProvider);

      var entries = ratings.entries.where((e) => e.value.isFavorite);

      if (!filters.showUnrated) {
        entries = entries.where((e) => e.value.rating != null);
      }

      // min
      entries = entries.where(
        (e) => (e.value.rating ?? 0) >= filters.minRating,
      );
      // max
      entries = entries.where(
        (e) => (e.value.rating ?? 0) <= filters.maxRating,
      );

      return entries.toList();
    });

/// Manages the current filter state for the favorites screen.
/// Persists across the app lifetime (not autoDispose) so filter
/// preferences survive navigation.
final favoritesFilterProvider =
    NotifierProvider<FavoritesFilterNotifier, FavoriteFilters>(
      FavoritesFilterNotifier.new,
    );

/// Notifier that holds the active [FavoriteFilters] state.
/// Defaults to minRating=1, maxRating=5, showUnrated=true.
class FavoritesFilterNotifier extends Notifier<FavoriteFilters> {
  @override
  FavoriteFilters build() => const FavoriteFilters(
    minRating: kMinRating,
    maxRating: kMaxRating,
  );

  /// Convenience getter for the current minimum rating threshold
  int get minRating => state.minRating;

  /// Convenience getter for the current maximum rating threshold
  int get maxRating => state.maxRating;

  /// Convenience getter for the current "show unrated" toggle
  bool get showUnrated => state.showUnrated;

  /// Updates both the min and max rating bounds simultaneously
  void setRange(int min, int max) => state = FavoriteFilters(
    minRating: min,
    maxRating: max,
    showUnrated: state.showUnrated,
  );

  /// Toggles whether unrated films are shown in the filtered results
  // ignore: avoid_positional_boolean_parameters
  void setShowUnrated(bool value) => state = FavoriteFilters(
    minRating: state.minRating,
    maxRating: state.maxRating,
    showUnrated: value,
  );

  /// Resets all filters back to their default values
  void reset() => state = const FavoriteFilters(
    minRating: kMinRating,
    maxRating: kMaxRating,
  );
}
