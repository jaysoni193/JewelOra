import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/models/app_settings_model.dart';
import 'package:jewel_ora/services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service;
  StreamSubscription<AppSettingsModel>? _sub;

  AppSettingsModel _settings = const AppSettingsModel();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  SettingsProvider(this._service) {
    _sub = _service.watchSettings().listen(
          (data) {
        _settings = data;
        _isLoading = false;
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