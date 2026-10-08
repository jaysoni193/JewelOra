import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class NetworkLogger {
  NetworkLogger._();

  static const _sensitiveHeaders = {
    'authorization',
    'x-api-key',
    'bearer',
    'cookie',
    'token',
    'secret',
  };

  static Map<String, String> _maskHeaders(Map<String, String>? headers) {
    if (headers == null) return {};
    final copy = <String, String>{};
    for (final entry in headers.entries) {
      if (_sensitiveHeaders.contains(entry.key.toLowerCase())) {
        copy[entry.key] = '***MASKED***';
      } else {
        copy[entry.key] = entry.value;
      }
    }
    return copy;
  }

  static void request({
    required String method,
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    dynamic body,
  }) {
    if (!kDebugMode) return;

    final buffer = StringBuffer()
      ..writeln('========== API REQUEST ==========')
      ..writeln('Method : $method')
      ..writeln('URL    : $url');
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('Headers: ${_maskHeaders(headers)}');
    }
    if (query != null && query.isNotEmpty) {
      buffer.writeln('Query  : $query');
    }
    if (body != null) {
      buffer.writeln('Body   : $body');
    }
    buffer.writeln('=================================');

    developer.log(buffer.toString(), name: 'NETWORK');
  }

  static void response({
    required int statusCode,
    required String url,
    dynamic body,
    Duration? duration,
  }) {
    if (!kDebugMode) return;

    final buffer = StringBuffer()
      ..writeln('========== API RESPONSE =========')
      ..writeln('Status  : $statusCode')
      ..writeln('URL     : $url');
    if (duration != null) {
      buffer.writeln('Duration: ${duration.inMilliseconds}ms');
    }
    if (body != null) {
      final bodyStr = body.toString();
      buffer.writeln(
        'Response: ${bodyStr.length > 500 ? "${bodyStr.substring(0, 500)}...[truncated]" : bodyStr}',
      );
    }
    buffer.writeln('=================================');

    developer.log(buffer.toString(), name: 'NETWORK');
  }

  static void error({
    int? statusCode,
    required String url,
    required Object error,
    dynamic responseBody,
  }) {
    if (!kDebugMode) return;

    final buffer = StringBuffer()
      ..writeln('========== API ERROR ============')
      ..writeln('Status  : ${statusCode ?? "N/A"}')
      ..writeln('URL     : $url')
      ..writeln('Error   : $error');
    if (responseBody != null) {
      buffer.writeln('Response: $responseBody');
    }
    buffer.writeln('=================================');

    developer.log(buffer.toString(), name: 'NETWORK');
  }
}
