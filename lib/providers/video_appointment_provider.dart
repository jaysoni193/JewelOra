import 'package:flutter/foundation.dart';
import 'package:jewel_ora/models/video_appointment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoAppointmentProvider extends ChangeNotifier {
  static const _storageKey = 'jewel_ora_video_appointments';

  final SharedPreferences? _prefs;
  List<VideoAppointmentModel> _appointments = [];
  bool _isLoaded = false;

  VideoAppointmentProvider([this._prefs]) {
    _init();
  }

  List<VideoAppointmentModel> get appointments => List.unmodifiable(_appointments);
  bool get isLoaded => _isLoaded;

  /// Returns active confirmed appointments sorted by earliest date first
  List<VideoAppointmentModel> get upcomingAppointments {
    final list = _appointments.where((a) => a.isUpcoming).toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    return List.unmodifiable(list);
  }

  /// The next upcoming video appointment
  VideoAppointmentModel? get nextUpcomingAppointment {
    final upcoming = upcomingAppointments;
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  bool get hasUpcoming => upcomingAppointments.isNotEmpty;

  Future<void> _init() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        _appointments = raw
            .map((str) {
              try {
                return VideoAppointmentModel.fromJson(str);
              } catch (_) {
                return null;
              }
            })
            .whereType<VideoAppointmentModel>()
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
      final list = _appointments.map((a) => a.toJson()).toList();
      await prefs.setStringList(_storageKey, list);
    } catch (_) {
      // Test environment fallback
    }
  }

  Future<void> bookAppointment(VideoAppointmentModel appt) async {
    _appointments.insert(0, appt);
    await _persist();
    notifyListeners();
  }

  Future<void> cancelAppointment(String id) async {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(status: 'cancelled');
      await _persist();
      notifyListeners();
    }
  }

  Future<void> deleteAppointment(String id) async {
    _appointments.removeWhere((a) => a.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _appointments.clear();
    await _persist();
    notifyListeners();
  }
}
