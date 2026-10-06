import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/models/banner_model.dart';
import 'package:jewel_ora/services/banner_service.dart';

class BannerProvider extends ChangeNotifier {
  final BannerService _service;
  StreamSubscription<List<BannerModel>>? _sub;

  List<BannerModel> _banners = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  BannerProvider(this._service) {
    _listen();
  }

  List<BannerModel> get banners => _banners;

  /// What customers see on the home screen (used in Step 10).
  List<BannerModel> get activeBanners =>
      _banners.where((b) => b.isActive).toList();

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  void _listen() {
    _sub = _service.watchBanners().listen(
          (data) {
        _banners = data;
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

  Future<bool> save({
    BannerModel? existing,
    required String title,
    required String imageUrl,
    required bool isActive,
  }) async {
    _errorMessage = null;
    _isSaving = true;
    notifyListeners();

    try {
      if (existing == null) {
        // New banners go to the end of the list.
        final nextOrder = _banners.isEmpty
            ? 0
            : _banners.map((b) => b.order).reduce(math.max) + 1;
        await _service.add(BannerModel(
          id: '',
          imageUrl: imageUrl,
          title: title,
          order: nextOrder,
          isActive: isActive,
        ));
      } else {
        await _service.update(BannerModel(
          id: existing.id,
          imageUrl: imageUrl,
          title: title,
          order: existing.order,
          isActive: isActive,
        ));
      }
      return true;
    } catch (_) {
      _errorMessage = AppStrings.somethingWentWrong;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> toggleActive(BannerModel b) =>
      _run(() => _service.setActive(b.id, !b.isActive));

  Future<bool> delete(String id) => _run(() => _service.delete(id));

  /// Called by the drag-and-drop list.
  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1; // Flutter's reorder quirk
    if (oldIndex == newIndex) return;

    final list = List.of(_banners);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    // Update the screen immediately, then save in the background.
    _banners = list;
    notifyListeners();

    await _run(() => _service.reorder(list));
  }

  Future<bool> _run(Future<void> Function() action) async {
    _errorMessage = null;
    try {
      await action();
      return true;
    } catch (_) {
      _errorMessage = AppStrings.somethingWentWrong;
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