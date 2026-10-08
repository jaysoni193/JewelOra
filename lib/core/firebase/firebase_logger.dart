import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class FirebaseLogger {
  FirebaseLogger._();

  static const _sensitiveKeys = {
    'password',
    'token',
    'accessToken',
    'refreshToken',
    'auth',
    'secret',
    'cvv',
    'cardNumber',
    'pin',
  };

  /// Mask sensitive keys in a parameter map.
  static Map<String, dynamic>? _maskSensitive(Map<String, dynamic>? data) {
    if (data == null) return null;
    final copy = <String, dynamic>{};
    for (final entry in data.entries) {
      if (_sensitiveKeys.contains(entry.key.toLowerCase())) {
        copy[entry.key] = '***MASKED***';
      } else if (entry.value is Map<String, dynamic>) {
        copy[entry.key] = _maskSensitive(entry.value as Map<String, dynamic>);
      } else {
        copy[entry.key] = entry.value;
      }
    }
    return copy;
  }

  static void request({
    required String collection,
    required String operation,
    String? documentId,
    Map<String, dynamic>? parameters,
  }) {
    if (!kDebugMode) return;

    final masked = _maskSensitive(parameters);
    final buffer = StringBuffer()
      ..writeln('[FIREBASE REQUEST]')
      ..writeln('Collection : $collection')
      ..writeln('Operation  : $operation')
      ..writeln('Document ID: ${documentId ?? "N/A"}');
    if (masked != null && masked.isNotEmpty) {
      buffer.writeln('Parameters : $masked');
    }
    buffer.writeln('Timestamp  : ${DateTime.now().toIso8601String()}');

    developer.log(buffer.toString(), name: 'FIREBASE');
  }

  static void response({
    required String collection,
    required String operation,
    String? documentId,
    bool success = true,
    dynamic data,
    Duration? duration,
  }) {
    if (!kDebugMode) return;

    final buffer = StringBuffer()
      ..writeln('[FIREBASE RESPONSE]')
      ..writeln('Collection : $collection')
      ..writeln('Operation  : $operation')
      ..writeln('Document ID: ${documentId ?? "N/A"}')
      ..writeln('Success    : $success');
    if (duration != null) {
      buffer.writeln('Duration   : ${duration.inMilliseconds}ms');
    }
    if (data != null) {
      if (data is Map<String, dynamic>) {
        buffer.writeln('Response   : ${_maskSensitive(data)}');
      } else if (data is List) {
        buffer.writeln('Response   : List (${data.length} items)');
      } else {
        buffer.writeln('Response   : $data');
      }
    }
    buffer.writeln('Timestamp  : ${DateTime.now().toIso8601String()}');

    developer.log(buffer.toString(), name: 'FIREBASE');
  }

  static void error({
    required String collection,
    required String operation,
    String? documentId,
    required Object error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    final buffer = StringBuffer()
      ..writeln('[FIREBASE ERROR]')
      ..writeln('Collection : $collection')
      ..writeln('Operation  : $operation')
      ..writeln('Document ID: ${documentId ?? "N/A"}')
      ..writeln('Error      : $error')
      ..writeln('Timestamp  : ${DateTime.now().toIso8601String()}');

    developer.log(
      buffer.toString(),
      name: 'FIREBASE',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
