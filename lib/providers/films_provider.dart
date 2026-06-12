import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/core/config.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/providers/dio_provider.dart';

/// Provider for the films state, backed by [FilmsNotifier]
final filmsProvider = AsyncNotifierProvider<FilmsNotifier, List<Films>>(
  FilmsNotifier.new,
);

/// Manages film data, loading from the API and caching the result
class FilmsNotifier extends AsyncNotifier<List<Films>> {
  @override
  Future<List<Films>> build() async {
    return _fetchFilms();
  }

  /// Loads films from the API if not already loaded
  Future<List<Films>> _fetchFilms() async {
    try {
      final client = ref.read(restClientProvider);
      final films = await client.films.getFilms(limit: defaultApiLimit);

      films.sort((a, b) {
        final dateA = a.releaseDate;
        final dateB = b.releaseDate;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      });
      return films;
    } on DioException catch (e) {
      // It is good practice in Riverpod to forward the stackTrace for better debugging
      throw Failure.fromDio(e);
    }
  }
}

/// Test helper that returns a fixed List of [Films] instead of calling the API
class FakeFilmsNotifier extends FilmsNotifier {
  /// Creates a notifier that always returns [mockData]
  FakeFilmsNotifier(this.mockData);

  /// The state to return from [build]
  final List<Films> mockData;

  @override
  Future<List<Films>> build() async => mockData;
}
