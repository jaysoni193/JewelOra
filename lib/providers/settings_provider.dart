import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/models/app_settings_model.dart';
import 'package:jewel_ora/services/settings_service.dart';

import '../services/app_icon_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service;
  StreamSubscription<AppSettingsModel>? _sub;

  AppSettingsModel _settings = const AppSettingsModel();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  SettingsProvider(this._service) {
    _initFromCache();
    _listen();
  }

  /// Instant local cache hydration for zero-flicker startup
  Future<void> _initFromCache() async {
    try {
      final cached = await _service.getCachedSettings();
      if (_isLoading) {
        _settings = cached;
        notifyListeners();
      }
    } catch (_) {}
  }

  void _listen() {
    _sub = _service.watchSettings().listen(
      (data) {
        _settings = data;
        _isLoading = false;
        AppIconService.instance.update(data.appIcon);
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        _errorMessage = AppStrings.somethingWentWrong;
        notifyListeners();
      },
    );
  }

  AppSettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<bool> save(AppSettingsModel updated) async {
    _errorMessage = null;
    _isSaving = true;
    notifyListeners();
    try {
      await _service.save(updated);
      _settings = updated;
      return true;
    } catch (_) {
      _errorMessage = AppStrings.somethingWentWrong;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}