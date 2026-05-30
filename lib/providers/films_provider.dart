import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/core/config.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/providers/dio_provider.dart';

/// Base state for films data
sealed class FilmsState {
  const FilmsState(this.films);

  /// Loaded films list
  final List<Films> films;
}

/// Films have not been loaded yet
class FilmsInitial extends FilmsState {
  /// Creates an initial state with no films
  const FilmsInitial() : super(const []);
}

/// Films are currently loading
class FilmsLoading extends FilmsState {
  /// Creates a loading state with no films
  const FilmsLoading() : super(const []);
}

/// Films have been loaded successfully
class FilmsData extends FilmsState {
  /// Creates a data state with the given [films]
  const FilmsData(super.films);
}

/// An error occurred while loading films
class FilmsError extends FilmsState {
  /// Creates an error state with the given [failure] and no films
  const FilmsError(this.failure, super.films);

  /// Details about what went wrong
  final Failure failure;
}

/// Provider for the films state, backed by [FilmsNotifier]
final filmsProvider = NotifierProvider<FilmsNotifier, FilmsState>(
  FilmsNotifier.new,
);

/// Manages film data, loading from the API and caching the result
class FilmsNotifier extends Notifier<FilmsState> {
  @override
  FilmsState build() {
    unawaited(Future.microtask(_load));
    return const FilmsInitial();
  }

  /// Loads films from the API if not already loaded
  Future<void> load() async {
    if (state is FilmsData) return;
    await _load();
  }

  Future<void> _load() async {
    state = const FilmsLoading();
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

      state = FilmsData(films);
    } on DioException catch (e) {
      state = FilmsError(Failure.fromDio(e), []);
    }
  }
}

/// Test helper that returns a fixed [FilmsState] instead of calling the API
class FakeFilmsNotifier extends FilmsNotifier {
  /// Creates a notifier that always returns [mockState]
  FakeFilmsNotifier(this.mockState);

  /// The state to return from [build]
  final FilmsState mockState;

  @override
  FilmsState build() => mockState;
}
