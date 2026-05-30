import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/core/config.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/providers/dio_provider.dart';

/// Base state for vehicles data
sealed class VehiclesState {
  const VehiclesState(this.vehicles);

  /// Loaded vehicles list
  final List<Vehicles> vehicles;
}

/// Vehicles have not been loaded yet
class VehiclesInitial extends VehiclesState {
  /// Creates an initial state with no vehicles
  const VehiclesInitial() : super(const []);
}

/// Vehicles are currently loading
class VehiclesLoading extends VehiclesState {
  /// Creates a loading state with no vehicles
  const VehiclesLoading() : super(const []);
}

/// Vehicles have been loaded successfully
class VehiclesData extends VehiclesState {
  /// Creates a data state with the given [vehicles]
  const VehiclesData(super.vehicles);
}

/// An error occurred while loading vehicles
class VehiclesError extends VehiclesState {
  /// Creates an error state with the given [failure] and no vehicles
  const VehiclesError(this.failure, super.vehicles);

  /// Details about what went wrong
  final Failure failure;
}

/// Provider for the vehicles state, backed by [VehiclesNotifier]
final vehiclesProvider = NotifierProvider<VehiclesNotifier, VehiclesState>(
  VehiclesNotifier.new,
);

/// Manages vehicles data, loading from the API and caching the result
class VehiclesNotifier extends Notifier<VehiclesState> {
  @override
  VehiclesState build() {
    return const VehiclesInitial();
  }

  /// Loads vehicles from the API if not already loaded
  Future<void> load() async {
    if (state is VehiclesData) return;
    state = const VehiclesLoading();
    try {
      final client = ref.read(restClientProvider);
      final vehicles = await client.vehicles.getVehicles(
        limit: defaultApiLimit,
      );
      state = VehiclesData(vehicles);
    } on DioException catch (e) {
      state = VehiclesError(Failure.fromDio(e), []);
    }
  }
}

/// Test helper that returns a fixed [VehiclesState] instead of calling the API
class FakeVehiclesNotifier extends VehiclesNotifier {
  /// Creates a notifier that always returns [mockState]
  FakeVehiclesNotifier(this.mockState);

  /// The state to return from [build]
  final VehiclesState mockState;

  @override
  VehiclesState build() => mockState;
}
