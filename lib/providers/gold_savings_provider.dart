import 'package:flutter/foundation.dart';
import 'package:jewel_ora/models/gold_savings_scheme_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoldSavingsProvider extends ChangeNotifier {
  static const _storageKey = 'jewel_ora_gold_savings_plans';

  final SharedPreferences? _prefs;
  List<GoldSavingsSchemeModel> _plans = [];
  bool _isLoaded = false;

  GoldSavingsProvider([this._prefs]) {
    _init();
  }

  List<GoldSavingsSchemeModel> get plans => List.unmodifiable(_plans);
  bool get isLoaded => _isLoaded;
  bool get hasActivePlan => _plans.isNotEmpty;

  GoldSavingsSchemeModel? get activePlan {
    if (_plans.isEmpty) return null;
    return _plans.firstWhere((p) => !p.isMatured, orElse: () => _plans.first);
  }

  Future<void> _init() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        _plans = raw
            .map((str) {
              try {
                return GoldSavingsSchemeModel.fromJson(str);
              } catch (_) {
                return null;
              }
            })
            .whereType<GoldSavingsSchemeModel>()
            .toList();
      }
    } catch (_) {
      // Test environment fallback
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final list = _plans.map((p) => p.toJson()).toList();
      await prefs.setStringList(_storageKey, list);
    } catch (_) {
      // Test environment fallback
    }
  }

  Future<void> enrollPlan(GoldSavingsSchemeModel plan) async {
    _plans.insert(0, plan);
    await _persist();
    notifyListeners();
  }

  Future<void> payInstallment(String planId) async {
    final index = _plans.indexWhere((p) => p.id == planId);
    if (index != -1) {
      final current = _plans[index];
      if (current.monthsPaid < current.totalTenureMonths) {
        _plans[index] = current.copyWith(
          monthsPaid: current.monthsPaid + 1,
          lastPaymentDate: DateTime.now(),
        );
        await _persist();
        notifyListeners();
      }
    }
  }

  Future<void> cancelPlan(String planId) async {
    _plans.removeWhere((p) => p.id == planId);
    await _persist();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _plans.clear();
    await _persist();
    notifyListeners();
  }
}
