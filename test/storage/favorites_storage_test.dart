import 'package:flutter_test/flutter_test.dart';
import 'package:seznam_ghibli/models/film_rating.dart';
import 'package:seznam_ghibli/storage/favorites_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FavoritesStorage', () {
    late FavoritesStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = FavoritesStorage(prefs);
    });

    test('getAll returns empty map when no data', () {
      expect(storage.getAll(), <String, FilmRating>{});
    });

    test('save and getAll round-trip', () async {
      await storage.save(
        'film1',
        const FilmRating(isFavorite: true, rating: 4),
      );

      final all = storage.getAll();
      expect(all.length, 1);
      expect(all['film1']?.isFavorite, true);
      expect(all['film1']?.rating, 4);
    });

    test('save updates existing entry', () async {
      await storage.save(
        'film1',
        const FilmRating(isFavorite: true, rating: 3),
      );
      await storage.save(
        'film1',
        const FilmRating(isFavorite: true, rating: 5),
      );

      final all = storage.getAll();
      expect(all['film1']?.rating, 5);
    });

    test('saveAll replaces all data', () async {
      await storage.save(
        'film1',
        const FilmRating(isFavorite: true, rating: 3),
      );
      await storage.saveAll({
        'film2': const FilmRating(isFavorite: true, rating: 5),
      });

      final all = storage.getAll();
      expect(all.length, 1);
      expect(all.containsKey('film2'), true);
      expect(all.containsKey('film1'), false);
    });

    test('remove deletes entry', () async {
      await storage.save('film1', const FilmRating(isFavorite: true));
      await storage.remove('film1');

      expect(storage.getAll(), <String, FilmRating>{});
    });

    test('remove non-existent key does nothing', () async {
      await storage.save('film1', const FilmRating(isFavorite: true));
      await storage.remove('nonexistent');

      expect(storage.getAll().length, 1);
    });

    test('multiple entries persist', () async {
      await storage.save('a', const FilmRating(isFavorite: true, rating: 5));
      await storage.save(
        'b',

        /// Matching against forced default value
        // ignore: avoid_redundant_argument_values
        const FilmRating(isFavorite: false, rating: null),
      );

      final all = storage.getAll();
      expect(all.length, 2);
      expect(all['a']?.isFavorite, true);
      expect(all['b']?.isFavorite, false);
    });

    test('storageKey is visible for testing', () {
      expect(FavoritesStorage.storageKey, 'film_ratings');
    });
  });
}
