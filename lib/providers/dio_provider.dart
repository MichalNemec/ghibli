import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/interceptors/logging_interceptor.dart';

/// Dio provider with interceptors
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'https://ghibliapi.vercel.app'));
  dio.interceptors.add(LoggingInterceptor());
  return dio;
});

/// Api client
final restClientProvider = Provider<RestClient>((ref) {
  return RestClient(ref.watch(dioProvider));
});
