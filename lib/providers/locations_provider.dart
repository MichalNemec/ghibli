import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/core/config.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/providers/dio_provider.dart';

/// Base state for locations data
sealed class LocationsState {
  const LocationsState(this.locations);

  /// Loaded locations list
  final List<Locations> locations;
}

/// Locations have not been loaded yet
class LocationsInitial extends LocationsState {
  /// Creates an initial state with no locations
  const LocationsInitial() : super(const []);
}

/// Locations are currently loading
class LocationsLoading extends LocationsState {
  /// Creates a loading state with no locations
  const LocationsLoading() : super(const []);
}

/// Locations have been loaded successfully
class LocationsData extends LocationsState {
  /// Creates a data state with the given [locations]
  const LocationsData(super.locations);
}

/// An error occurred while loading locations
class LocationsError extends LocationsState {
  /// Creates an error state with the given [failure] and no locations
  const LocationsError(this.failure, super.locations);

  /// Details about what went wrong
  final Failure failure;
}

/// Provider for the locations state, backed by [LocationsNotifier]
final locationsProvider = NotifierProvider<LocationsNotifier, LocationsState>(
  LocationsNotifier.new,
);

/// Manages locations data, loading from the API and caching the result
class LocationsNotifier extends Notifier<LocationsState> {
  @override
  LocationsState build() {
    return const LocationsInitial();
  }

  /// Loads locations from the API if not already loaded
  Future<void> load() async {
    if (state is LocationsData) return;
    state = const LocationsLoading();
    try {
      final client = ref.read(restClientProvider);
      final locations = await client.locations.getLocations(
        limit: defaultApiLimit,
      );
      state = LocationsData(locations);
    } on DioException catch (e) {
      state = LocationsError(Failure.fromDio(e), []);
    }
  }
}

/// Test helper that returns a fixed [LocationsState]
/// instead of calling the API
class FakeLocationsNotifier extends LocationsNotifier {
  /// Creates a notifier that always returns [mockState]
  FakeLocationsNotifier(this.mockState);

  /// The state to return from [build]
  final LocationsState mockState;

  @override
  LocationsState build() => mockState;
}
