import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:jewel_ora/core/constants/app_icon_options.dart';

class AppIconService with WidgetsBindingObserver {
  AppIconService._();
  static final AppIconService instance = AppIconService._();

  static const _channel = MethodChannel('jewel_ora/app_icon');

  String _wanted = 'default'; // latest value from Firestore
  String? _applied;           // last value sent to Android
  bool _started = false;

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Call every time the settings change. Starts listening on first call.
  void update(String key) {
    if (!_supported) return;
    _wanted = key;
    if (!_started) {
      _started = true;
      WidgetsBinding.instance.addObserver(this);
    }
  }

  // The icon changes when the user leaves the app, never while using it.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _apply();
    }
  }

  Future<void> _apply() async {
    if (_applied == _wanted) return;
    _applied = _wanted;
    try {
      await _channel.invokeMethod('set', {
        'alias': AppIconOptions.byKey(_wanted).alias,
      });
    } catch (e) {
      _applied = null; // try again next time
      debugPrint('App icon change failed: $e');
    }
  }
}