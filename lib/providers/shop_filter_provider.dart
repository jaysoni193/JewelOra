import 'package:flutter/foundation.dart';
import 'package:jewel_ora/models/product_model.dart';

enum ShopSort {
  newest('Newest first'),
  priceLow('Price: Low to High'),
  priceHigh('Price: High to Low'),
  nameAZ('Name: A to Z');

  final String label;
  const ShopSort(this.label);
}

class ShopFilterProvider extends ChangeNotifier {
  static const int pageSize = 12;

  String _query = '';
  String? _categoryId; // null = all
  ShopSort _sort = ShopSort.newest;
  int _visibleCount = pageSize;

  // Task 3.4 Filter Attributes
  double? _minPrice;
  double? _maxPrice;
  final Set<String> _materials = {};
  bool _inStockOnly = false;

  String get query => _query;
  String? get categoryId => _categoryId;
  ShopSort get sort => _sort;
  int get visibleCount => _visibleCount;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  Set<String> get materials => Set.unmodifiable(_materials);
  bool get inStockOnly => _inStockOnly;

  bool get hasActiveFilters =>
      _query.isNotEmpty ||
      _categoryId != null ||
      _minPrice != null ||
      _maxPrice != null ||
      _materials.isNotEmpty ||
      _inStockOnly ||
      _sort != ShopSort.newest;

  int get activeFilterCount {
    var count = 0;
    if (_minPrice != null || _maxPrice != null) count++;
    if (_materials.isNotEmpty) count += _materials.length;
    if (_inStockOnly) count++;
    return count;
  }

  /// Changes whenever the results must scroll back to the top.
  String get filterKey =>
      '$_query|$_categoryId|${_sort.name}|$_minPrice|$_maxPrice|${_materials.join(',')}|$_inStockOnly';

  String? effectiveCategoryId(Set<String> activeCategoryIds) =>
      (_categoryId != null && activeCategoryIds.contains(_categoryId))
          ? _categoryId
          : null;

  void setQuery(String value) {
    _query = value;
    _visibleCount = pageSize;
    notifyListeners();
  }

  void setCategory(String? id) {
    _categoryId = id;
    _visibleCount = pageSize;
    notifyListeners();
  }

  void showCategory(String id) {
    _query = '';
    _categoryId = id;
    _visibleCount = pageSize;
    notifyListeners();
  }

  void setSort(ShopSort value) {
    _sort = value;
    _visibleCount = pageSize;
    notifyListeners();
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    _visibleCount = pageSize;
    notifyListeners();
  }

  void toggleMaterial(String material) {
    if (_materials.contains(material)) {
      _materials.remove(material);
    } else {
      _materials.add(material);
    }
    _visibleCount = pageSize;
    notifyListeners();
  }

  void setInStockOnly(bool value) {
    _inStockOnly = value;
    _visibleCount = pageSize;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _categoryId = null;
    _sort = ShopSort.newest;
    _minPrice = null;
    _maxPrice = null;
    _materials.clear();
    _inStockOnly = false;
    _visibleCount = pageSize;
    notifyListeners();
  }

  void loadMore(int total) {
    if (_visibleCount >= total) return;
    _visibleCount += pageSize;
    notifyListeners();
  }

  /// Applies category, search, price range, material, in-stock, and sort filters.
  List<ProductModel> apply(
    List<ProductModel> all,
    Set<String> activeCategoryIds,
  ) {
    final category = effectiveCategoryId(activeCategoryIds);
    final q = _query.trim().toLowerCase();

    final result = all.where((p) {
      if (!activeCategoryIds.contains(p.categoryId)) return false;
      if (category != null && p.categoryId != category) return false;
      if (_inStockOnly && !p.isAvailable) return false;
      if (_minPrice != null && p.price < _minPrice!) return false;
      if (_maxPrice != null && p.price > _maxPrice!) return false;
      if (_materials.isNotEmpty && !_materials.contains(p.material)) return false;

      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.categoryName.toLowerCase().contains(q) ||
          p.material.toLowerCase().contains(q);
    }).toList();

    switch (_sort) {
      case ShopSort.newest:
        break;
      case ShopSort.priceLow:
        result.sort((a, b) => a.price.compareTo(b.price));
      case ShopSort.priceHigh:
        result.sort((a, b) => b.price.compareTo(a.price));
      case ShopSort.nameAZ:
        result.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }
    return result;
  }
}