import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';
import 'package:jewel_ora/services/metal_rate_service.dart';

class MetalRateProvider extends ChangeNotifier {
  final MetalRateService _service;
  StreamSubscription<MetalRateModel>? _sub;

  MetalRateModel _rates = const MetalRateModel();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  MetalRateProvider(this._service) {
    _listen();
  }

  void _listen() {
    _sub = _service.watchRates().listen(
      (data) {
        _rates = data;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        // Fallback to standard market rates so that offline or pending-permission states never crash or freeze the UI
        _rates = const MetalRateModel();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }

  MetalRateModel get rates => _rates;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<bool> save(MetalRateModel updated) async {
    _errorMessage = null;
    _isSaving = true;
    notifyListeners();
    try {
      await _service.save(updated);
      _rates = updated;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = AppStrings.somethingWentWrong;
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
