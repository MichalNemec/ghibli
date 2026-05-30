// Films tester
// ignore_for_file: avoid_redundant_argument_values

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/providers/dio_provider.dart';
import 'package:seznam_ghibli/providers/films_provider.dart';

import '../helpers/mocks.mocks.dart';

Films _makeFilm(String id, String title, String? releaseDate) {
  return Films(
    id: id,
    title: title,
    originalTitle: null,
    originalTitleRomanised: null,
    description: null,
    director: null,
    producer: null,
    releaseDate: releaseDate,
    runningTime: null,
    rtScore: null,
    people: null,
    species: null,
    locations: null,
    vehicles: null,
    url: null,
  );
}

void main() {
  group('FilmsProvider', () {
    late MockRestClient mockClient;
    late MockFilmsClient mockFilmsClient;

    setUp(() {
      mockClient = MockRestClient();
      mockFilmsClient = MockFilmsClient();
      when(mockClient.films).thenReturn(mockFilmsClient);
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          restClientProvider.overrideWithValue(mockClient),
        ],
      );
    }

    /// Flush microtasks repeatedly to let async operations settle.
    Future<void> flush() async {
      for (var i = 0; i < 100; i++) {
        await Future(() {});
      }
    }

    test('initial state is FilmsInitial', () {
      final container = createContainer();
      addTearDown(container.dispose);

      expect(container.read(filmsProvider), isA<FilmsInitial>());
    });

    test('load transitions to FilmsData with sorted films', () async {
      final filmB = _makeFilm('2', 'B', '2000');
      final filmA = _makeFilm('1', 'A', '1988');
      final filmC = _makeFilm('3', 'C', '2010');
      when(mockFilmsClient.getFilms(limit: anyNamed('limit'))).thenAnswer((_) async => [filmB, filmA, filmC]);

      final container = createContainer();
      addTearDown(container.dispose);
      container.read(filmsProvider);
      await flush();

      final state = container.read(filmsProvider);
      expect(state, isA<FilmsData>());
      final films = (state as FilmsData).films;
      expect(films.length, 3);
      expect(films[0].releaseDate, '1988');
      expect(films[1].releaseDate, '2000');
      expect(films[2].releaseDate, '2010');
    });

    test('load handles null release dates at end', () async {
      final filmA = _makeFilm('1', 'A', '1988');
      final filmB = _makeFilm('2', 'B', null);
      when(mockFilmsClient.getFilms(limit: anyNamed('limit'))).thenAnswer((_) async => [filmA, filmB]);

      final container = createContainer();
      addTearDown(container.dispose);
      container.read(filmsProvider);
      await flush();

      final state = container.read(filmsProvider) as FilmsData;
      expect(state.films.length, 2);
      expect(state.films[0].id, '1');
    });

    test('load error transitions to FilmsError', () async {
      when(mockFilmsClient.getFilms(limit: anyNamed('limit'))).thenThrow(
        DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final container = createContainer();
      addTearDown(container.dispose);
      container.read(filmsProvider);
      await flush();

      final state = container.read(filmsProvider);
      expect(state, isA<FilmsError>());
      expect((state as FilmsError).failure, isA<NetworkFailure>());
    });

    test('cache-once: second load() is no-op', () async {
      when(mockFilmsClient.getFilms(limit: anyNamed('limit'))).thenAnswer((_) async => [_makeFilm('1', 'A', '2000')]);

      final container = createContainer();
      addTearDown(container.dispose);
      container.read(filmsProvider);
      await flush();

      await container.read(filmsProvider.notifier).load();
      await flush();

      verify(mockFilmsClient.getFilms(limit: anyNamed('limit'))).called(1);
    });
  });
}
