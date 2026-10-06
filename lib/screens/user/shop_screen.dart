import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/widgets/coming_soon_screen.dart';
import 'package:jewel_ora/core/widgets/empty_view.dart';
import 'package:jewel_ora/core/widgets/loading_view.dart';
import 'package:jewel_ora/core/widgets/product_card.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/providers/shop_filter_provider.dart';
import 'package:jewel_ora/screens/user/product_detail_screen.dart';
import 'package:provider/provider.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late final ShopFilterProvider _filter;

  String _lastKey = '';
  int _filteredCount = 0; // total results, used by the paging listener

  @override
  void initState() {
    super.initState();
    _filter = context.read<ShopFilterProvider>();
    _lastKey = _filter.filterKey;
    _filter.addListener(_onFilterChanged);
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _filter.removeListener(_onFilterChanged);
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Keeps the search box in sync when the filter is changed from outside
  /// (for example "Clear filters" or a category tapped on Home), and scrolls
  /// back to the top whenever the results change.
  void _onFilterChanged() {
    if (_searchCtrl.text != _filter.query) {
      _searchCtrl.text = _filter.query;
    }
    if (_filter.filterKey != _lastKey) {
      _lastKey = _filter.filterKey;
      if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(0);
    }
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      _filter.loadMore(_filteredCount);
    }
  }

  Future<void> _showSortSheet() async {
    final current = _filter.sort;
    final picked = await showModalBottomSheet<ShopSort>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final s in ShopSort.values)
              ListTile(
                title: Text(s.label),
                trailing: s == current
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, s),
              ),
          ],
        ),
      ),
    );
    if (picked != null) _filter.setSort(picked);
  }

  void _openProduct(String productId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: productId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsP = context.watch<ProductProvider>();
    final categoriesP = context.watch<CategoryProvider>();
    final filter = context.watch<ShopFilterProvider>();

    final categories = categoriesP.activeCategories;
    final activeIds = categories.map((c) => c.id).toSet();
    final selectedId = filter.effectiveCategoryId(activeIds);

    final filtered = filter.apply(productsP.products, activeIds);
    _filteredCount = filtered.length;
    final visible = filtered.take(filter.visibleCount).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: Column(
        children: [
          // ---------- Search ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: filter.setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search name, category or material',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filter.query.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => filter.setQuery(''),
                ),
              ),
            ),
          ),

          // ---------- Category chips ----------
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(
                  label: 'All',
                  selected: selectedId == null,
                  onTap: () => filter.setCategory(null),
                ),
                for (final c in categories)
                  _CategoryChip(
                    label: c.name,
                    selected: selectedId == c.id,
                    onTap: () => filter.setCategory(c.id),
                  ),
              ],
            ),
          ),

          // ---------- Result count and sort ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${filtered.length} ${filtered.length == 1 ? 'item' : 'items'}',
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showSortSheet,
                  icon: const Icon(Icons.swap_vert, size: 20),
                  label: Text(filter.sort.label),
                ),
              ],
            ),
          ),

          // ---------- Grid ----------
          Expanded(
            child: Builder(
              builder: (_) {
                if (productsP.isLoading || categoriesP.isLoading) {
                  return const LoadingView();
                }
                if (productsP.products.isEmpty) {
                  return const EmptyView(
                    message: 'No products yet. Please check back soon.',
                    icon: Icons.diamond_outlined,
                  );
                }
                if (filtered.isEmpty) {
                  return EmptyView(
                    message: 'No products found',
                    icon: Icons.search_off,
                    actionLabel: 'Clear filters',
                    onAction: filter.clearFilters,
                  );
                }
                return GridView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: visible.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (_, i) => ProductCard(
                    product: visible[i],
                    onTap: () => _openProduct(visible[i].id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}