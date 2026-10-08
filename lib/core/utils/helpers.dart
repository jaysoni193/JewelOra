import 'dart:async';
import 'package:flutter/services.dart';

class AppHelpers {
  AppHelpers._();

  /// Subtle haptic feedback for luxury feel on taps
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }
}

/// Debouncer to prevent rapid taps or rapid search queries
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
