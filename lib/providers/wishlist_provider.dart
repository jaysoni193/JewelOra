import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/models/wishlist_item_model.dart';
import 'package:jewel_ora/services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  static const int maxItems = 100;

  final WishlistService _service;
  StreamSubscription<List<WishlistItemModel>>? _sub;

  String? _uid;
  List<WishlistItemModel> _items = [];
  Set<String> _ids = {};
  bool _isLoading = false;
  String? _errorMessage;

  WishlistProvider(this._service);

  List<WishlistItemModel> get items => _items;
  int get count => _items.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isFavorite(String productId) => _ids.contains(productId);

  /// Called by the ProxyProvider in main.dart whenever login state changes.
  /// It does not call notifyListeners, because it runs while widgets build.
  void updateUser(String? uid) {
    if (uid == _uid) return;

    _sub?.cancel();
    _sub = null;
    _uid = uid;
    _items = [];
    _ids = {};
    _errorMessage = null;

    if (uid == null) {
      _isLoading = false;
      return;
    }

    _isLoading = true;
    _sub = _service.watch(uid).listen(
          (data) {
        _items = data;
        _ids = data.map((i) => i.productId).toSet();
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

  /// Adds or removes the heart. The screen updates through the live stream.
  Future<bool> toggle(String productId) async {
    final uid = _uid;
    if (uid == null) return false;
    _errorMessage = null;

    try {
      if (_ids.contains(productId)) {
        await _service.remove(uid, productId);
      } else {
        if (_ids.length >= maxItems) {
          _errorMessage = 'Your wishlist is full ($maxItems items).';
          return false;
        }
        await _service.add(uid, productId);
      }
      return true;
    } catch (_) {
      _errorMessage = AppStrings.somethingWentWrong;
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}