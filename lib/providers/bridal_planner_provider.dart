import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:jewel_ora/models/bridal_planner_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BridalPlannerProvider extends ChangeNotifier {
  static const String _storageKey = 'jewel_ora_bridal_planner_profile';

  final SharedPreferences? _prefs;
  BridalPlannerProfile? _profile;
  bool _isLoading = true;

  BridalPlannerProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _profile != null;

  BridalPlannerProvider([this._prefs]) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_storageKey);
      if (dataStr != null && dataStr.isNotEmpty) {
        final map = jsonDecode(dataStr) as Map<String, dynamic>;
        _profile = BridalPlannerProfile.fromJson(map);
      }
    } catch (_) {
      // Test or offline fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile() async {
    if (_profile == null) return;
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_profile!.toJson());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {
      // Test or offline fallback
    }
  }

  Future<void> createOrUpdateProfile({
    required String brideName,
    required double totalBudget,
    DateTime? weddingDate,
    bool includeStarterTemplate = true,
  }) async {
    final existingItems = _profile?.items ?? [];
    final items = existingItems.isNotEmpty
        ? existingItems
        : (includeStarterTemplate ? BridalPlannerProfile.starterHeritageItems() : <BridalItem>[]);

    _profile = BridalPlannerProfile(
      brideName: brideName.trim().isEmpty ? 'Bride' : brideName.trim(),
      totalBudget: totalBudget > 0 ? totalBudget : 500000.0,
      weddingDate: weddingDate,
      items: items,
    );

    notifyListeners();
    await saveProfile();
  }

  Future<void> updateBudget(double newBudget) async {
    if (_profile == null || newBudget <= 0) return;
    _profile = _profile!.copyWith(totalBudget: newBudget);
    notifyListeners();
    await saveProfile();
  }

  Future<void> updateBrideDetails({String? brideName, DateTime? weddingDate}) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      brideName: brideName,
      weddingDate: weddingDate,
    );
    notifyListeners();
    await saveProfile();
  }

  Future<void> addItem(BridalItem item) async {
    if (_profile == null) return;
    final updatedList = List<BridalItem>.from(_profile!.items)..add(item);
    _profile = _profile!.copyWith(items: updatedList);
    notifyListeners();
    await saveProfile();
  }

  Future<void> updateItem(BridalItem item) async {
    if (_profile == null) return;
    final index = _profile!.items.indexWhere((i) => i.id == item.id);
    if (index == -1) return;

    final updatedList = List<BridalItem>.from(_profile!.items)..[index] = item;
    _profile = _profile!.copyWith(items: updatedList);
    notifyListeners();
    await saveProfile();
  }

  Future<void> deleteItem(String itemId) async {
    if (_profile == null) return;
    final updatedList = _profile!.items.where((i) => i.id != itemId).toList();
    _profile = _profile!.copyWith(items: updatedList);
    notifyListeners();
    await saveProfile();
  }

  Future<void> togglePurchased(String itemId, {double? actualSpend}) async {
    if (_profile == null) return;
    final index = _profile!.items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;

    final current = _profile!.items[index];
    final updated = current.copyWith(
      isPurchased: !current.isPurchased,
      actualSpend: !current.isPurchased
          ? (actualSpend ?? current.estimatedBudget)
          : null,
    );

    final updatedList = List<BridalItem>.from(_profile!.items)..[index] = updated;
    _profile = _profile!.copyWith(items: updatedList);
    notifyListeners();
    await saveProfile();
  }

  Future<void> loadStarterTemplate() async {
    if (_profile == null) return;
    final starter = BridalPlannerProfile.starterHeritageItems();
    _profile = _profile!.copyWith(items: starter);
    notifyListeners();
    await saveProfile();
  }

  Future<void> resetPlanner() async {
    _profile = null;
    notifyListeners();
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {
      // Test or offline fallback
    }
  }
}
