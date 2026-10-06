import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/errors/app_exception.dart';
import 'package:jewel_ora/models/category_model.dart';
import 'package:jewel_ora/services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _service;
  StreamSubscription<List<CategoryModel>>? _sub;

  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  CategoryProvider(this._service) {
    _listen();
  }

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get activeCategories =>
      _categories.where((c) => c.isActive).toList();
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  void _listen() {
    _sub = _service.watchCategories().listen(
          (data) {
        _categories = data;
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

  /// True if another category already uses this name.
  bool nameExists(String name, {String? excludeId}) {
    final target = name.trim().toLowerCase();
    return _categories.any(
          (c) => c.id != excludeId && c.name.trim().toLowerCase() == target,
    );
  }

  /// Creates a new category (when [existing] is null) or updates one.
  Future<bool> save({
    CategoryModel? existing,
    required String name,
    required String imageUrl,
    required bool isActive,
  }) async {
    _errorMessage = null;
    _isSaving = true;
    notifyListeners();

    try {
      if (existing == null) {
        await _service.add(CategoryModel(
          id: '',
          name: name,
          imageUrl: imageUrl,
          isActive: isActive,
        ));
      } else {
        await _service.update(
          CategoryModel(
            id: existing.id,
            name: name,
            imageUrl: imageUrl,
            isActive: isActive,
            createdAt: existing.createdAt,
          ),
          nameChanged: existing.name != name,
        );
      }
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = AppStrings.somethingWentWrong;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> toggleActive(CategoryModel category) async {
    _errorMessage = null;
    try {
      await _service.setActive(category.id, !category.isActive);
      return true;
    } catch (_) {
      _errorMessage = AppStrings.somethingWentWrong;
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(String id) async {
    _errorMessage = null;
    try {
      await _service.delete(id);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
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