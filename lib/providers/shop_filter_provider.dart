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
  static const int pageSize = 20;

  String _query = '';
  String? _categoryId; // null = all
  ShopSort _sort = ShopSort.newest;
  int _visibleCount = pageSize;

  String get query => _query;
  String? get categoryId => _categoryId;
  ShopSort get sort => _sort;
  int get visibleCount => _visibleCount;

  /// Changes whenever the results must scroll back to the top.
  String get filterKey => '$_query|$_categoryId|${_sort.name}';

  /// The selected category, or null if it is hidden or deleted meanwhile.
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

  /// Used by Home: open a category with a clean search.
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

  void clearFilters() {
    _query = '';
    _categoryId = null;
    _visibleCount = pageSize;
    notifyListeners();
  }

  void loadMore(int total) {
    if (_visibleCount >= total) return;
    _visibleCount += pageSize;
    notifyListeners();
  }

  /// Applies visibility, category, search and sort. Returns the FULL
  /// filtered list; the screen shows only the first [visibleCount] items.
  List<ProductModel> apply(
      List<ProductModel> all,
      Set<String> activeCategoryIds,
      ) {
    final category = effectiveCategoryId(activeCategoryIds);
    final q = _query.trim().toLowerCase();

    final result = all.where((p) {
      if (!activeCategoryIds.contains(p.categoryId)) return false;
      if (category != null && p.categoryId != category) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.categoryName.toLowerCase().contains(q) ||
          p.material.toLowerCase().contains(q);
    }).toList();

    switch (_sort) {
      case ShopSort.newest:
        break; // already newest first from ProductService
      case ShopSort.priceLow:
        result.sort((a, b) => a.price.compareTo(b.price));
      case ShopSort.priceHigh:
        result.sort((a, b) => b.price.compareTo(a.price));
      case ShopSort.nameAZ:
        result.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return result;
  }
}