import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/interceptors/logging_interceptor.dart';

/// Dio provider with interceptors
final dioProvider = Provider<Dio>((ref) {
  // Prevent the state from being destroyed when listeners are removed
  ref.keepAlive();

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://ghibliapi.vercel.app',
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 1500),
    ),
  );
  dio.interceptors.add(LoggingInterceptor());
  return dio;
});

/// Api client
final restClientProvider = Provider<RestClient>((ref) {
  return RestClient(ref.read(dioProvider));
});
