import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/core/config.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/providers/dio_provider.dart';

/// Base state for people data
sealed class PeopleState {
  const PeopleState(this.people);

  /// Loaded people list
  final List<People> people;
}

/// People have not been loaded yet
class PeopleInitial extends PeopleState {
  /// Creates an initial state with no people
  const PeopleInitial() : super(const []);
}

/// People are currently loading
class PeopleLoading extends PeopleState {
  /// Creates a loading state with no people
  const PeopleLoading() : super(const []);
}

/// People have been loaded successfully
class PeopleData extends PeopleState {
  /// Creates a data state with the given [people]
  const PeopleData(super.people);
}

/// An error occurred while loading people
class PeopleError extends PeopleState {
  /// Creates an error state with the given [failure] and no people
  const PeopleError(this.failure, super.people);

  /// Details about what went wrong
  final Failure failure;
}

/// Provider for the people state, backed by [PeopleNotifier]
final peopleProvider = NotifierProvider<PeopleNotifier, PeopleState>(
  PeopleNotifier.new,
);

/// Manages people data, loading from the API and caching the result
class PeopleNotifier extends Notifier<PeopleState> {
  @override
  PeopleState build() {
    return const PeopleInitial();
  }

  /// Loads people from the API if not already loaded
  Future<void> load() async {
    if (state is PeopleData) return;
    state = const PeopleLoading();
    try {
      final client = ref.read(restClientProvider);
      final people = await client.people.getPeople(limit: defaultApiLimit);
      state = PeopleData(people);
    } on DioException catch (e) {
      state = PeopleError(Failure.fromDio(e), []);
    }
  }
}

/// Test helper that returns a fixed [PeopleState] instead of calling the API
class FakePeopleNotifier extends PeopleNotifier {
  /// Creates a notifier that always returns [mockState]
  FakePeopleNotifier(this.mockState);

  /// The state to return from [build]
  final PeopleState mockState;

  @override
  PeopleState build() => mockState;
}
