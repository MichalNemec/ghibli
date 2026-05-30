import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:seznam_ghibli/models/film_rating.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and loads film ratings via [SharedPreferences]
class FavoritesStorage {
  /// Creates a storage backed by the given [SharedPreferences] instance
  FavoritesStorage(this._prefs);

  /// Storage key used in tests to verify persisted data
  @visibleForTesting
  static const String storageKey = 'film_ratings';

  final SharedPreferences _prefs;

  /// Returns all stored ratings, or an empty map if none exist
  Map<String, FilmRating> getAll() {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, Object?>;
    return decoded.map(
      (k, v) => MapEntry(k, FilmRating.fromJson(v! as Map<String, Object?>)),
    );
  }

  /// Saves a single [rating] for the given [filmId], keeping existing ones
  Future<void> save(String filmId, FilmRating rating) async {
    final all = getAll();
    all[filmId] = rating;
    await _prefs.setString(storageKey, jsonEncode(all));
  }

  /// Replaces all stored ratings with [ratings]
  Future<void> saveAll(Map<String, FilmRating> ratings) async {
    await _prefs.setString(storageKey, jsonEncode(ratings));
  }

  /// Removes the rating for the given [filmId]
  Future<void> remove(String filmId) async {
    final all = getAll()..remove(filmId);
    await _prefs.setString(storageKey, jsonEncode(all));
  }
}
