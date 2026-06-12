import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/core/config.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/providers/dio_provider.dart';

/// Provider for the vehicles state, backed by [VehiclesNotifier]
final vehiclesProvider =
    AsyncNotifierProvider<VehiclesNotifier, List<Vehicles>>(
      VehiclesNotifier.new,
    );

/// Manages vehicles data, loading from the API and caching the result
class VehiclesNotifier extends AsyncNotifier<List<Vehicles>> {
  @override
  Future<List<Vehicles>> build() async {
    return _fetchVehicles();
  }

  /// Private helper to fetch data from the API
  Future<List<Vehicles>> _fetchVehicles() async {
    try {
      final client = ref.read(restClientProvider);
      return await client.vehicles.getVehicles(limit: defaultApiLimit);
    } on DioException catch (e) {
      // It is good practice in Riverpod to forward the stackTrace for better debugging
      throw Failure.fromDio(e);
    }
  }
}

/// Test helper that returns a fixed List of [Vehicles] instead of calling the API
class FakeVehiclesNotifier extends VehiclesNotifier {
  /// Creates a notifier that always returns [mockData]
  FakeVehiclesNotifier(this.mockData);

  /// The state to return from [build]
  final List<Vehicles> mockData;

  @override
  Future<List<Vehicles>> build() async => mockData;
}
