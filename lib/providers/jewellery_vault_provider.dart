import 'package:flutter/foundation.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';
import 'package:jewel_ora/models/vault_item_model.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JewelleryVaultProvider extends ChangeNotifier {
  static const _storageKey = 'jewel_ora_vault_items';

  final SharedPreferences? _prefs;
  List<VaultItemModel> _items = [];
  bool _isLoaded = false;

  JewelleryVaultProvider([this._prefs]) {
    _init();
  }

  List<VaultItemModel> get items => List.unmodifiable(_items);
  bool get isLoaded => _isLoaded;
  bool get isEmpty => _items.isEmpty;

  Future<void> _init() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_storageKey);
      if (raw != null) {
        _items = raw
            .map((str) {
              try {
                return VaultItemModel.fromJson(str);
              } catch (_) {
                return null;
              }
            })
            .whereType<VaultItemModel>()
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
      final list = _items.map((i) => i.toJson()).toList();
      await prefs.setStringList(_storageKey, list);
    } catch (_) {
      // Test environment fallback
    }
  }

  Future<void> addItem(VaultItemModel item) async {
    _items.insert(0, item);
    await _persist();
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> updateItem(VaultItemModel updated) async {
    final idx = _items.indexWhere((i) => i.id == updated.id);
    if (idx != -1) {
      _items[idx] = updated;
      await _persist();
      notifyListeners();
    }
  }

  double getTotalValuation(MetalRateModel rates) {
    var sum = 0.0;
    for (final i in _items) {
      sum += i.getCurrentValuation(rates);
    }
    return (sum * 100).round() / 100.0;
  }

  double getTotalPurchaseCost() {
    var sum = 0.0;
    for (final i in _items) {
      sum += i.purchasePrice;
    }
    return (sum * 100).round() / 100.0;
  }

  double getTotalGain(MetalRateModel rates) {
    return getTotalValuation(rates) - getTotalPurchaseCost();
  }

  double getTotalGainPercent(MetalRateModel rates) {
    final cost = getTotalPurchaseCost();
    if (cost <= 0) return 0.0;
    final gain = getTotalGain(rates);
    return ((gain / cost) * 100.0 * 10).round() / 10.0;
  }

  double getTotalNetGoldWeight() {
    var sum = 0.0;
    for (final i in _items) {
      if (i.metalType.contains('gold')) {
        sum += i.netWeight;
      }
    }
    return (sum * 100).round() / 100.0;
  }

  Future<void> sharePortfolioWhatsApp({
    required MetalRateModel rates,
    required String storePhone,
  }) async {
    final totalVal = getTotalValuation(rates);
    final totalGold = getTotalNetGoldWeight();

    final buffer = StringBuffer();
    buffer.writeln('Hello Jewel Ora! 🛡️✨');
    buffer.writeln();
    buffer.writeln('Here is my *Digital Jewellery Vault & Portfolio Summary*:');
    buffer.writeln('• Total Pieces: *${_items.length}*');
    buffer.writeln('• Pure Gold Weight: *${totalGold.toStringAsFixed(2)} g*');
    buffer.writeln('• Current Live Valuation: *${Formatters.currency(totalVal)}*');
    buffer.writeln();
    buffer.writeln('*My Vault Pieces:*');

    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      buffer.writeln('${i + 1}. *${item.name}* (${item.metalLabel})');
      buffer.writeln('   - Net Wt: ${item.netWeight.toStringAsFixed(2)}g | Value: ${Formatters.currency(item.getCurrentValuation(rates))}');
      if (item.huidOrCert != null && item.huidOrCert!.isNotEmpty) {
        buffer.writeln('   - Cert/HUID: ${item.huidOrCert}');
      }
    }

    buffer.writeln();
    buffer.writeln('I would like to enquire about trade-in exchange / appraisal. ✨');

    await WhatsAppService.open(phone: storePhone, message: buffer.toString());
  }
}
