import 'package:flutter/foundation.dart';
import 'package:jewel_ora/models/ring_size_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RingSizeProvider extends ChangeNotifier {
  static const String _keyPpi = 'jewel_ora_pixels_per_mm';
  static const String _keyRingSize = 'jewel_ora_user_ring_size';
  static const String _keyBangleSize = 'jewel_ora_user_bangle_size';
  static const String _keyIsCalibrated = 'jewel_ora_is_calibrated';

  final SharedPreferences? _prefs;
  double _pixelsPerMm = ScreenCalibrationConstants.defaultPixelsPerMm;
  bool _isCalibrated = false;
  String? _savedRingSize;
  String? _savedBangleSize;

  double get pixelsPerMm => _pixelsPerMm;
  bool get isCalibrated => _isCalibrated;
  String? get savedRingSize => _savedRingSize;
  String? get savedBangleSize => _savedBangleSize;

  RingSizeProvider([this._prefs]) {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _pixelsPerMm = prefs.getDouble(_keyPpi) ?? ScreenCalibrationConstants.defaultPixelsPerMm;
      _isCalibrated = prefs.getBool(_keyIsCalibrated) ?? false;
      _savedRingSize = prefs.getString(_keyRingSize);
      _savedBangleSize = prefs.getString(_keyBangleSize);
      notifyListeners();
    } catch (_) {
      // Test or offline fallback
    }
  }

  Future<void> calibrateWithCreditCard(double measuredPixelsWidth) async {
    final calculated = (measuredPixelsWidth / ScreenCalibrationConstants.creditCardWidthMm).clamp(3.5, 12.0);
    _pixelsPerMm = calculated;
    _isCalibrated = true;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setDouble(_keyPpi, _pixelsPerMm);
      await prefs.setBool(_keyIsCalibrated, true);
    } catch (_) {}
  }

  Future<void> calibrateWithCoin(double measuredPixelsDiameter) async {
    final calculated = (measuredPixelsDiameter / ScreenCalibrationConstants.coin5RupeeDiameterMm).clamp(3.5, 12.0);
    _pixelsPerMm = calculated;
    _isCalibrated = true;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setDouble(_keyPpi, _pixelsPerMm);
      await prefs.setBool(_keyIsCalibrated, true);
    } catch (_) {}
  }

  Future<void> setCustomPixelsPerMm(double value) async {
    _pixelsPerMm = value.clamp(3.5, 12.0);
    _isCalibrated = true;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setDouble(_keyPpi, _pixelsPerMm);
      await prefs.setBool(_keyIsCalibrated, true);
    } catch (_) {}
  }

  Future<void> saveUserRingSize(String size) async {
    _savedRingSize = size;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_keyRingSize, size);
    } catch (_) {}
  }

  Future<void> saveUserBangleSize(String size) async {
    _savedBangleSize = size;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_keyBangleSize, size);
    } catch (_) {}
  }

  Future<void> resetCalibration() async {
    _pixelsPerMm = ScreenCalibrationConstants.defaultPixelsPerMm;
    _isCalibrated = false;
    notifyListeners();

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove(_keyPpi);
      await prefs.remove(_keyIsCalibrated);
    } catch (_) {}
  }
}
