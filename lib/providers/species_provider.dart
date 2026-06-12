import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/core/config.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/providers/dio_provider.dart';

/// Provider for the species state, backed by [SpeciesNotifier]
final speciesProvider = AsyncNotifierProvider<SpeciesNotifier, List<Species>>(
  SpeciesNotifier.new,
);

/// Manages species data, loading from the API and caching the result
class SpeciesNotifier extends AsyncNotifier<List<Species>> {
  @override
  Future<List<Species>> build() {
    return _fetchSpecies();
  }

  /// Private helper to fetch data from the API
  Future<List<Species>> _fetchSpecies() async {
    try {
      final client = ref.read(restClientProvider);
      return await client.species.getSpecies(limit: defaultApiLimit);
    } on DioException catch (e) {
      // It is good practice in Riverpod to forward the stackTrace for better debugging
      throw Failure.fromDio(e);
    }
  }
}

/// Test helper that returns a fixed List of [Species] instead of calling the API
class FakeSpeciesNotifier extends SpeciesNotifier {
  /// Creates a notifier that always returns [mockData]
  FakeSpeciesNotifier(this.mockData);

  /// The state to return from [build]
  final List<Species> mockData;

  @override
  Future<List<Species>> build() async => mockData;
}
