import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seznam_ghibli/core/failure.dart';

void main() {
  group('Failure.fromDio', () {
    test('connection timeout -> NetworkFailure', () {
      final error = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(),
      );
      final failure = Failure.fromDio(error);
      expect(failure, isA<NetworkFailure>());
      expect(failure.icon, Icons.wifi_off);
    });

    test('receive timeout -> NetworkFailure', () {
      final error = DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: RequestOptions(),
      );
      final failure = Failure.fromDio(error);
      expect(failure, isA<NetworkFailure>());
    });

    test('connection error -> NetworkFailure', () {
      final error = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(),
      );
      final failure = Failure.fromDio(error);
      expect(failure, isA<NetworkFailure>());
    });

    test('500 status code -> ServerFailure', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(),
        ),
        requestOptions: RequestOptions(),
      );
      final failure = Failure.fromDio(error);
      expect(failure, isA<ServerFailure>());
      expect(failure.icon, Icons.cloud_off);
    });

    test('404 status code -> NotFoundFailure', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(),
        ),
        requestOptions: RequestOptions(),
      );
      final failure = Failure.fromDio(error);
      expect(failure, isA<NotFoundFailure>());
      expect(failure.icon, Icons.search_off);
    });

    test('null status code -> UnknownFailure', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(),
      );
      final failure = Failure.fromDio(error);
      expect(failure, isA<UnknownFailure>());
      expect(failure.icon, Icons.error_outline);
    });

    test('unknown error type -> UnknownFailure', () {
      final error = DioException(
        type: DioExceptionType.badCertificate,
        requestOptions: RequestOptions(),
      );
      final failure = Failure.fromDio(error);
      expect(failure, isA<UnknownFailure>());
    });

    test('other 4xx status -> UnknownFailure', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 418,
          requestOptions: RequestOptions(),
        ),
        requestOptions: RequestOptions(),
      );
      final failure = Failure.fromDio(error);
      expect(failure, isA<UnknownFailure>());
    });
  });
}
