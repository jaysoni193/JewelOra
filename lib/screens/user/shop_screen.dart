import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'Sort Collection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const Divider(height: 1),
              for (final s in ShopSort.values)
                ListTile(
                  title: Text(
                    s.label,
                    style: TextStyle(
                      fontWeight: s == current ? FontWeight.w700 : FontWeight.w500,
                      color: s == current ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                  trailing: s == current
                      ? const Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(ctx, s),
                ),
            ],
          ),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Jewellery Collection'),
      ),
      body: Column(
        children: [
          // ---------- Search Field ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: filter.setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: AppStrings.searchProducts,
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textGrey, size: 22),
                suffixIcon: filter.query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => filter.setQuery(''),
                      ),
              ),
            ),
          ),

          // ---------- Category Choice Chips ----------
          SizedBox(
            height: 42,
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

          // ---------- Result count and Sort action ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${filtered.length} ${filtered.length == 1 ? 'item' : 'items'} found',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showSortSheet,
                  icon: const Icon(Icons.swap_vert_rounded, size: 18),
                  label: Text(filter.sort.label),
                ),
              ],
            ),
          ),

          // ---------- Responsive Product Grid ----------
          Expanded(
            child: Builder(
              builder: (context) {
                if (productsP.isLoading || categoriesP.isLoading) {
                  return const Center(child: AppLoader(size: 50));
                }
                if (productsP.products.isEmpty) {
                  return const EmptyState(
                    title: 'Collection is empty',
                    subtitle: 'Please check back soon for our latest arrivals.',
                    icon: Icons.diamond_outlined,
                  );
                }
                if (filtered.isEmpty) {
                  return EmptyState(
                    title: 'No jewellery found',
                    subtitle: 'Try adjusting your search or category filters.',
                    icon: Icons.search_off_rounded,
                    actionLabel: 'Clear filters',
                    onAction: filter.clearFilters,
                  );
                }
                return GridView.builder(
                  controller: _scrollCtrl,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: visible.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, i) => ProductCard(
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
        selectedColor: AppColors.primaryLight,
        backgroundColor: AppColors.surface,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.primaryDark : AppColors.textDark,
        ),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.2 : 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
        ),
      ),
    );
  }
}