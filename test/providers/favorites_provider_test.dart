import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/models/film_rating.dart';
import 'package:seznam_ghibli/providers/favorites_provider.dart';
import 'package:seznam_ghibli/providers/storage_provider.dart';

import '../helpers/mocks.mocks.dart';

Widget _buildApp(List<Override> overrides) {
  return MaterialApp(
    home: ProviderScope(
      overrides: overrides,
      child: Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(favoritesProvider);
          return Scaffold(
            body: Text('count:${state.length}'),
          );
        },
      ),
    ),
  );
}

void main() {
  group('FavoritesProvider', () {
    late MockFavoritesStorage mockStorage;

    setUp(() {
      mockStorage = MockFavoritesStorage();
      when(mockStorage.getAll()).thenReturn({});
      when(mockStorage.saveAll(any)).thenAnswer((_) async {});
    });

    testWidgets('returns empty map when storage is empty', (tester) async {
      await tester.pumpWidget(
        _buildApp([
          favoritesStorageProvider.overrideWithValue(mockStorage),
        ]),
      );
      expect(find.text('count:0'), findsOneWidget);
    });

    testWidgets('returns data from storage', (tester) async {
      when(mockStorage.getAll()).thenReturn({
        'film1': const FilmRating(isFavorite: true, rating: 4),
      });
      await tester.pumpWidget(
        _buildApp([
          favoritesStorageProvider.overrideWithValue(mockStorage),
        ]),
      );
      expect(find.text('count:1'), findsOneWidget);
    });

    testWidgets('storage error propagates', (tester) async {
      when(mockStorage.getAll()).thenThrow(Exception('storage fail'));
      await tester.pumpWidget(
        _buildApp([
          favoritesStorageProvider.overrideWithValue(mockStorage),
        ]),
      );
      expect(tester.takeException(), isA<UnknownFailure>());
    });
  });
}
