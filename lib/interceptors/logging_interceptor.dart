import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs all HTTP requests, responses, and errors via [debugPrint].
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[HTTP] --> ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      '[HTTP] <-- ${response.statusCode} ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[HTTP] <-- ERROR ${err.response?.statusCode} '
      '${err.requestOptions.path}: ${err.message}',
    );
    handler.next(err);
  }
}
