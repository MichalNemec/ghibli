import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Base class for user-facing error types.
sealed class Failure {
  const Failure(this.message, this.icon);

  /// Maps a [DioException] to the most specific [Failure] subtype.
  ///
  /// Handles timeouts, connection errors, 5xx, 404, and unknown status codes.
  factory Failure.fromDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure(
        'No internet connection. Check your network and try again.',
      );
    }

    final code = e.response?.statusCode;
    if (code == null) {
      return const UnknownFailure(
        'Something unexpected happened. Please try again.',
      );
    }

    if (code >= 500) {
      return const ServerFailure(
        'The server is having trouble. Please try again later.',
      );
    }

    if (code == 404) {
      return const NotFoundFailure(
        'The requested resource was not found.',
      );
    }

    return UnknownFailure(
      'Something went wrong (error $code). Please try again.',
    );
  }

  /// Human-readable error description.
  final String message;

  /// Icon reflecting the error category.
  final IconData icon;
}

/// Connection-related failure (timeout, no network).
class NetworkFailure extends Failure {
  ///
  const NetworkFailure(String message) : super(message, Icons.wifi_off);
}

/// Server-side failure (5xx status codes).
class ServerFailure extends Failure {
  ///
  const ServerFailure(String message) : super(message, Icons.cloud_off);
}

/// Resource-not-found failure (404 status code).
class NotFoundFailure extends Failure {
  ///
  const NotFoundFailure(String message) : super(message, Icons.search_off);
}

/// Catch-all for unexpected failures.
class UnknownFailure extends Failure {
  ///
  const UnknownFailure(String message) : super(message, Icons.error_outline);
}
