import 'package:flutter/foundation.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/models/product_stats_model.dart';
import 'package:jewel_ora/services/stats_service.dart';

class StatsProvider extends ChangeNotifier {
  final StatsService _service;
  StatsProvider(this._service);

  List<ProductStatsModel> _items = [];
  int? _customerCount; // null = could not be loaded
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<ProductStatsModel> get items => _items;
  int? get customerCount => _customerCount;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  /// Loads once per call (the admin screen has a refresh button).
  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _service.fetchProductStats();
      _hasLoaded = true;
    } catch (_) {
      _errorMessage = AppStrings.somethingWentWrong;
    }

    try {
      _customerCount = await _service.countCustomers();
    } catch (_) {
      _customerCount = null;
    }

    _isLoading = false;
    notifyListeners();
  }
}