import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/services/notification_service.dart';
import 'package:jewel_ora/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service;
  StreamSubscription<List<ProductModel>>? _sub;

  List<ProductModel> _products = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  ProductProvider(this._service) {
    _listen();
  }

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  ProductModel? findById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void _listen() {
    _sub = _service.watchProducts().listen(
      (data) {
        _products = data;
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

  /// Adds a product (when [existing] is null) or updates one.
  Future<bool> save({
    ProductModel? existing,
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required String categoryName,
    required List<String> images,
    double? mrp,
    String? offerTag,
    String? metalType,
    double? metalWeight,
    double? makingCharges,
    bool useDynamicRate = false,
    required String material,
    required String weight,
    required bool isAvailable,
    required bool isFeatured,
    List<String> availableSizes = const [],
  }) async {
    _errorMessage = null;
    _isSaving = true;
    notifyListeners();

    try {
      final product = ProductModel(
        id: existing?.id ?? '',
        name: name,
        description: description,
        price: price,
        mrp: mrp,
        offerTag: offerTag,
        categoryId: categoryId,
        categoryName: categoryName,
        images: images,
        material: material,
        weight: weight,
        metalType: metalType,
        metalWeight: metalWeight,
        makingCharges: makingCharges,
        useDynamicRate: useDynamicRate,
        isAvailable: isAvailable,
        isFeatured: isFeatured,
        availableSizes: availableSizes,
        createdAt: existing?.createdAt,
      );

      if (existing == null) {
        await _service.add(product);
        unawaited(NotificationService.instance.notifyNewCollection(
          productName: name,
          categoryName: categoryName,
          price: price,
          imageUrl: images.isNotEmpty ? images.first : null,
        ));
      } else {
        await _service.update(product);
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

  Future<bool> toggleAvailable(ProductModel p) =>
      _run(() => _service.setAvailable(p.id, !p.isAvailable));

  Future<bool> toggleFeatured(ProductModel p) =>
      _run(() => _service.setFeatured(p.id, !p.isFeatured));

  Future<bool> delete(String id) => _run(() => _service.delete(id));

  /// Admin Tool 1: Duplicate product piece
  Future<bool> duplicate(ProductModel p) =>
      _run(() => _service.duplicate(p));

  /// Admin Tool 2: Bulk price change
  Future<int> bulkUpdatePrices({
    required double percentage,
    String? categoryId,
    String? metalType,
  }) async {
    _errorMessage = null;
    _isSaving = true;
    notifyListeners();

    try {
      final count = await _service.bulkUpdatePrices(
        products: _products,
        percentage: percentage,
        categoryId: categoryId,
        metalType: metalType,
      );
      return count;
    } catch (_) {
      _errorMessage = AppStrings.somethingWentWrong;
      return 0;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
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