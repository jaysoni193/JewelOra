import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/models/product_model.dart';
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
    required String material,
    required String weight,
    required bool isAvailable,
    required bool isFeatured,
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
        categoryId: categoryId,
        categoryName: categoryName,
        images: images,
        material: material,
        weight: weight,
        isAvailable: isAvailable,
        isFeatured: isFeatured,
        createdAt: existing?.createdAt,
      );

      if (existing == null) {
        await _service.add(product);
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