import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/storage/favorites_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides [SharedPreferences], must be overridden with a real instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

/// Provides [FavoritesStorage] backed by [sharedPreferencesProvider]
final favoritesStorageProvider = Provider<FavoritesStorage>((ref) {
  return FavoritesStorage(ref.watch(sharedPreferencesProvider));
});
