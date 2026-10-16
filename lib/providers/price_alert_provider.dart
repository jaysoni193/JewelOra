import 'package:flutter/foundation.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';
import 'package:jewel_ora/models/price_alert_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PriceAlertProvider extends ChangeNotifier {
  static const _storageKey = 'jewel_ora_price_alerts';

  final SharedPreferences? _prefs;
  List<PriceAlertModel> _alerts = [];
  bool _isLoaded = false;
  final Set<String> _dismissedTriggerIds = {};

  PriceAlertProvider([this._prefs]) {
    _init();
  }

  List<PriceAlertModel> get alerts => List.unmodifiable(_alerts);
  List<PriceAlertModel> get activeAlerts => _alerts.where((a) => a.isActive).toList();
  bool get isLoaded => _isLoaded;

  Future<void> _init() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_storageKey);
      if (raw != null) {
        _alerts = raw
            .map((str) {
              try {
                return PriceAlertModel.fromJson(str);
              } catch (_) {
                return null;
              }
            })
            .whereType<PriceAlertModel>()
            .toList();
      }
    } catch (_) {
      // In-memory fallback if SharedPreferences fails in test environment
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final stringList = _alerts.map((a) => a.toJson()).toList();
      await prefs.setStringList(_storageKey, stringList);
    } catch (_) {
      // Ignore in tests
    }
  }

  Future<void> addAlert({
    required String metalType,
    required double targetRate,
  }) async {
    final newAlert = PriceAlertModel(
      id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
      metalType: metalType,
      targetRate: targetRate,
      createdAt: DateTime.now(),
      isActive: true,
      isTriggered: false,
    );
    _alerts.insert(0, newAlert);
    await _persist();
    notifyListeners();
  }

  Future<void> removeAlert(String id) async {
    _alerts.removeWhere((a) => a.id == id);
    _dismissedTriggerIds.remove(id);
    await _persist();
    notifyListeners();
  }

  Future<void> toggleAlert(String id, bool isActive) async {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isActive: isActive);
      await _persist();
      notifyListeners();
    }
  }

  /// Evaluates alerts against current live rates
  Future<void> checkRates(MetalRateModel rates) async {
    if (!rates.isEnabled) return;

    var changed = false;
    for (int i = 0; i < _alerts.length; i++) {
      final alert = _alerts[i];
      if (!alert.isActive) continue;

      final isHit = alert.checkHit(rates);
      if (isHit && !alert.isTriggered) {
        _alerts[i] = alert.copyWith(
          isTriggered: true,
          triggeredAt: DateTime.now(),
        );
        changed = true;
      } else if (!isHit && alert.isTriggered) {
        // Price rose back above target
        _alerts[i] = alert.copyWith(
          isTriggered: false,
        );
        _dismissedTriggerIds.remove(alert.id);
        changed = true;
      }
    }

    if (changed) {
      await _persist();
      notifyListeners();
    }
  }

  /// Triggered alerts that are active and not dismissed in current session
  List<PriceAlertModel> getActiveTriggeredAlerts() {
    return _alerts
        .where((a) => a.isActive && a.isTriggered && !_dismissedTriggerIds.contains(a.id))
        .toList();
  }

  void dismissTrigger(String id) {
    _dismissedTriggerIds.add(id);
    notifyListeners();
  }
}
