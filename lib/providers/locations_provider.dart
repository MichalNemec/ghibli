import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/core/config.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/providers/dio_provider.dart';

/// Provider for the locations state, backed by [LocationsNotifier]
final locationsProvider =
    AsyncNotifierProvider<LocationsNotifier, List<Locations>>(
      LocationsNotifier.new,
    );

/// Manages locations data, loading from the API and caching the result
class LocationsNotifier extends AsyncNotifier<List<Locations>> {
  @override
  Future<List<Locations>> build() async {
    return _fetchLocations();
  }

  /// Private helper to fetch data from the API
  Future<List<Locations>> _fetchLocations() async {
    try {
      final client = ref.read(restClientProvider);
      return await client.locations.getLocations(limit: defaultApiLimit);
    } on DioException catch (e) {
      // It is good practice in Riverpod to forward the stackTrace for better debugging
      throw Failure.fromDio(e);
    }
  }
}

/// Test helper that returns a fixed List of [Locations] instead of calling the API
class FakeLocationsNotifier extends LocationsNotifier {
  /// Creates a notifier that always returns [mockData]
  FakeLocationsNotifier(this.mockData);

  /// The state to return from [build]
  final List<Locations> mockData;

  @override
  Future<List<Locations>> build() async => mockData;
}
