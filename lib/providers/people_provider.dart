import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/core/config.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/providers/dio_provider.dart';

/// Provider for the people state, backed by [PeopleNotifier]
final peopleProvider = AsyncNotifierProvider<PeopleNotifier, List<People>>(
  PeopleNotifier.new,
);

/// Manages people data natively using Riverpod's AsyncValue
class PeopleNotifier extends AsyncNotifier<List<People>> {
  @override
  Future<List<People>> build() async {
    return _fetchPeople();
  }

  /// Private helper to fetch data from the API
  Future<List<People>> _fetchPeople() async {
    try {
      final client = ref.read(restClientProvider);
      return await client.people.getPeople(limit: defaultApiLimit);
    } on DioException catch (e) {
      // It is good practice in Riverpod to forward the stackTrace for better debugging
      throw Failure.fromDio(e);
    }
  }
}

/// Test helper that returns a fixed List of [People] instead of calling the API
class FakePeopleNotifier extends PeopleNotifier {
  /// Creates a notifier that always returns [mockData]
  FakePeopleNotifier(this.mockData);

  /// The state to return from [build]
  final List<People> mockData;

  @override
  Future<List<People>> build() async => mockData;
}
