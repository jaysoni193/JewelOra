import 'package:flutter/foundation.dart';
import 'package:jewel_ora/models/occasion_reminder_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OccasionReminderProvider extends ChangeNotifier {
  static const _storageKey = 'jewel_ora_occasion_reminders';

  final SharedPreferences? _prefs;
  List<OccasionReminderModel> _reminders = [];
  bool _isLoaded = false;

  OccasionReminderProvider([this._prefs]) {
    _init();
  }

  List<OccasionReminderModel> get reminders => List.unmodifiable(_reminders);
  bool get isLoaded => _isLoaded;
  bool get isEmpty => _reminders.isEmpty;

  Future<void> _init() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        _reminders = raw
            .map((str) {
              try {
                return OccasionReminderModel.fromJson(str);
              } catch (_) {
                return null;
              }
            })
            .whereType<OccasionReminderModel>()
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
      final list = _reminders.map((r) => r.toJson()).toList();
      await prefs.setStringList(_storageKey, list);
    } catch (_) {
      // Test environment fallback
    }
  }

  Future<void> addReminder(OccasionReminderModel reminder) async {
    _reminders.add(reminder);
    await _persist();
    notifyListeners();
  }

  Future<void> removeReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> updateReminder(OccasionReminderModel updated) async {
    final idx = _reminders.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      _reminders[idx] = updated;
      await _persist();
      notifyListeners();
    }
  }

  /// Returns all user reminders sorted by shortest days until next occurrence
  List<OccasionReminderModel> getSortedReminders([DateTime? now]) {
    final today = now ?? DateTime.now();
    final list = List<OccasionReminderModel>.from(_reminders);
    list.sort((a, b) => a.daysUntilNext(today).compareTo(b.daysUntilNext(today)));
    return list;
  }

  /// Reminders occurring within the given threshold (defaults to 14 days)
  List<OccasionReminderModel> getUpcomingReminders({DateTime? now, int thresholdDays = 14}) {
    final today = now ?? DateTime.now();
    return getSortedReminders(today)
        .where((r) => r.isUpcoming(today, thresholdDays: thresholdDays))
        .toList();
  }

  /// Closest upcoming milestone
  OccasionReminderModel? getNearestReminder([DateTime? now]) {
    final sorted = getSortedReminders(now);
    return sorted.isNotEmpty ? sorted.first : null;
  }
}
