import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/core/config.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/providers/dio_provider.dart';

/// Base state for species data
sealed class SpeciesState {
  const SpeciesState(this.species);

  /// Loaded species list
  final List<Species> species;
}

/// Species have not been loaded yet
class SpeciesInitial extends SpeciesState {
  /// Creates an initial state with no species
  const SpeciesInitial() : super(const []);
}

/// Species are currently loading
class SpeciesLoading extends SpeciesState {
  /// Creates a loading state with no species
  const SpeciesLoading() : super(const []);
}

/// Species have been loaded successfully
class SpeciesData extends SpeciesState {
  /// Creates a data state with the given [species]
  const SpeciesData(super.species);
}

/// An error occurred while loading species
class SpeciesError extends SpeciesState {
  /// Creates an error state with the given [failure] and no species
  const SpeciesError(this.failure, super.species);

  /// Details about what went wrong
  final Failure failure;
}

/// Provider for the species state, backed by [SpeciesNotifier]
final speciesProvider = NotifierProvider<SpeciesNotifier, SpeciesState>(
  SpeciesNotifier.new,
);

/// Manages species data, loading from the API and caching the result
class SpeciesNotifier extends Notifier<SpeciesState> {
  @override
  SpeciesState build() {
    return const SpeciesInitial();
  }

  /// Loads species from the API if not already loaded
  Future<void> load() async {
    if (state is SpeciesData) return;
    state = const SpeciesLoading();
    try {
      final client = ref.read(restClientProvider);
      final species = await client.species.getSpecies(limit: defaultApiLimit);
      state = SpeciesData(species);
    } on DioException catch (e) {
      state = SpeciesError(Failure.fromDio(e), []);
    }
  }
}

/// Test helper that returns a fixed [SpeciesState] instead of calling the API
class FakeSpeciesNotifier extends SpeciesNotifier {
  /// Creates a notifier that always returns [mockState]
  FakeSpeciesNotifier(this.mockState);

  /// The state to return from [build]
  final SpeciesState mockState;

  @override
  SpeciesState build() => mockState;
}
