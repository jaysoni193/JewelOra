import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service that monitors device network connectivity and real internet reachability.
class ConnectivityService {
  static final ConnectivityService instance = ConnectivityService._internal();
  factory ConnectivityService() => instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final _controller = StreamController<bool>.broadcast();

  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Starts listening to connectivity state changes.
  void init() {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      final online = await _evaluateConnectivity(results);
      _updateStatus(online);
    });
    // Initial check
    checkConnection();
  }

  /// Manually checks real internet connectivity.
  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final online = await _evaluateConnectivity(results);
      _updateStatus(online);
      return online;
    } catch (_) {
      // In widget tests or restricted environments, default to online
      return _isOnline;
    }
  }

  Future<bool> _evaluateConnectivity(List<ConnectivityResult> results) async {
    // If results only contain 'none', there is no interface active
    if (results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none)) {
      return false;
    }

    // On Web or in unit tests, skip socket lookup
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) {
      return true;
    }

    // Real DNS lookup to verify actual internet reachability
    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  void _updateStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      _controller.add(online);
    }
  }

  /// For testing purposes only: override online state
  @visibleForTesting
  void setMockStatus(bool online) {
    _updateStatus(online);
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
