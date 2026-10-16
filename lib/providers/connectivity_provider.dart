import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jewel_ora/services/connectivity_service.dart';

/// Provider that exposes internet connectivity status across the entire application.
class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;

  bool _isOnline = true;
  bool _isChecking = false;
  bool _showRestoredBanner = false;
  Timer? _restoredTimer;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  bool get isChecking => _isChecking;
  bool get showRestoredBanner => _showRestoredBanner;

  ConnectivityProvider([ConnectivityService? service])
      : _service = service ?? ConnectivityService.instance {
    _init();
  }

  void _init() {
    _isOnline = _service.isOnline;
    _service.init();
    _subscription = _service.onConnectivityChanged.listen((online) {
      _handleStatusChange(online);
    });
  }

  void _handleStatusChange(bool online) {
    if (_isOnline == online) return;

    final wasOffline = !_isOnline;
    _isOnline = online;

    if (wasOffline && online) {
      // Show "Back Online" message briefly
      _showRestoredBanner = true;
      _restoredTimer?.cancel();
      _restoredTimer = Timer(const Duration(seconds: 3), () {
        _showRestoredBanner = false;
        notifyListeners();
      });
    } else {
      _showRestoredBanner = false;
      _restoredTimer?.cancel();
    }

    notifyListeners();
  }

  /// Manually triggers a re-check of internet connectivity (e.g. from Retry button).
  Future<bool> checkConnection() async {
    _isChecking = true;
    notifyListeners();

    try {
      final online = await _service.checkConnection();
      _handleStatusChange(online);
      return online;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  /// For unit testing: forces mock online/offline state
  @visibleForTesting
  void setMockStatus(bool online) {
    _handleStatusChange(online);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _restoredTimer?.cancel();
    super.dispose();
  }
}
