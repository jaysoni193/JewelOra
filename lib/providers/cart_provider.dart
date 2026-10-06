import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/errors/app_exception.dart';
import 'package:jewel_ora/models/cart_item_model.dart';
import 'package:jewel_ora/services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  static const int maxQuantity = 10; // of one product
  static const int maxItems = 20; // different products

  final CartService _service;
  StreamSubscription<List<CartItemModel>>? _sub;

  String? _uid;
  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  CartProvider(this._service);

  List<CartItemModel> get items => _items;
  int get itemCount => _items.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Called by the ProxyProvider in main.dart whenever login state changes.
  /// It does not call notifyListeners, because it runs while widgets build.
  /// The first data event from Firestore notifies the screens.
  void updateUser(String? uid) {
    if (uid == _uid) return;

    _sub?.cancel();
    _sub = null;
    _uid = uid;
    _items = [];
    _errorMessage = null;

    if (uid == null) {
      _isLoading = false;
      return;
    }

    _isLoading = true;
    _sub = _service.watchCart(uid).listen(
          (data) {
        _items = data;
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

  int quantityOf(String productId) {
    for (final i in _items) {
      if (i.productId == productId) return i.quantity;
    }
    return 0;
  }

  /// Returns the new quantity, or null if it failed (see [errorMessage]).
  Future<int?> add(String productId) async {
    _errorMessage = null;
    final uid = _uid;
    if (uid == null) return null;

    final isNew = quantityOf(productId) == 0;
    if (isNew && _items.length >= maxItems) {
      _errorMessage = 'Your cart is full ($maxItems items). '
          'Please remove something first.';
      return null;
    }

    try {
      return await _service.addOrIncrement(
        uid,
        productId,
        maxQuantity: maxQuantity,
      );
    } on AppException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (_) {
      _errorMessage = AppStrings.somethingWentWrong;
      return null;
    }
  }

  Future<bool> changeQuantity(String productId, int quantity) async {
    final uid = _uid;
    if (uid == null || quantity < 1 || quantity > maxQuantity) return false;
    return _run(() => _service.setQuantity(uid, productId, quantity));
  }

  /// The item disappears from the screen at once; if saving fails, it returns.
  Future<bool> remove(String productId) async {
    final uid = _uid;
    if (uid == null) return false;

    final index = _items.indexWhere((i) => i.productId == productId);
    if (index == -1) return true;
    final removed = _items[index];

    _items = List.of(_items)..removeAt(index);
    notifyListeners();

    final ok = await _run(() => _service.remove(uid, productId));
    if (!ok) {
      _items = List.of(_items)..insert(index.clamp(0, _items.length), removed);
      notifyListeners();
    }
    return ok;
  }

  Future<bool> restore(CartItemModel item) {
    final uid = _uid;
    if (uid == null) return Future.value(false);
    return _run(() => _service.restore(uid, item));
  }

  Future<bool> clear() {
    final uid = _uid;
    if (uid == null) return Future.value(false);
    return _run(() => _service.clear(uid));
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