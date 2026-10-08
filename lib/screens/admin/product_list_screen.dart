import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_dialog.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/screens/admin/product_form_screen.dart';
import 'package:provider/provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _query = '';
  String? _categoryId; // null = all

  void _openForm([ProductModel? product]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
  }

  Future<void> _delete(ProductModel p) async {
    final ok = await AppDialog.delete(
      context,
      title: 'Delete Piece',
      message: 'Are you sure you want to delete "${p.name}"? This action cannot be undone.',
      confirmText: 'Delete Piece',
    );
    if (!ok || !mounted) return;

    final provider = context.read<ProductProvider>();
    final success = await provider.delete(p.id);
    if (!mounted) return;
    showAppSnackBar(
      context,
      success
          ? 'Product deleted successfully'
          : (provider.errorMessage ?? AppStrings.somethingWentWrong),
      isError: !success,
    );
  }

  Future<void> _toggle(Future<bool> Function() action) async {
    final ok = await action();
    if (!ok && mounted) {
      showAppSnackBar(context, AppStrings.somethingWentWrong, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final categories = context.watch<CategoryProvider>().categories;

    final q = _query.trim().toLowerCase();
    final items = provider.products.where((p) {
      final matchCategory = _categoryId == null || p.categoryId == _categoryId;
      final matchQuery = q.isEmpty || p.name.toLowerCase().contains(q);
      return matchCategory && matchQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Jewellery Pieces (${provider.products.length})'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Piece'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search products by name',
                prefixIcon: const Icon(Icons.search_rounded, size: 22, color: AppColors.textGrey),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => setState(() => _query = ''),
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _categoryId == null,
                  onTap: () => setState(() => _categoryId = null),
                ),
                for (final c in categories)
                  _FilterChip(
                    label: c.name,
                    selected: _categoryId == c.id,
                    onTap: () => setState(() => _categoryId = c.id),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.isLoading) {
                  return const Center(child: AppLoader(size: 50));
                }
                if (provider.products.isEmpty) {
                  return const EmptyState(
                    title: 'No products in store',
                    subtitle: 'Tap the button below to add your first jewellery piece.',
                    icon: Icons.diamond_outlined,
                  );
                }
                if (items.isEmpty) {
                  return const EmptyState(
                    title: 'No pieces match your search',
                    subtitle: 'Try searching with a different keyword or category.',
                    icon: Icons.search_off_rounded,
                  );
                }
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final p = items[i];
                    return _ProductTile(
                      product: p,
                      onEdit: () => _openForm(p),
                      onDelete: () => _delete(p),
                      onToggleAvailable: () =>
                          _toggle(() => provider.toggleAvailable(p)),
                      onToggleFeatured: () =>
                          _toggle(() => provider.toggleFeatured(p)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
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

class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleAvailable;
  final VoidCallback onToggleFeatured;

  const _ProductTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailable,
    required this.onToggleFeatured,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;
    return AppCard(
      onTap: onEdit,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 76,
              height: 76,
              child: p.firstImage.isEmpty
                  ? Container(
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.diamond_outlined, color: AppColors.primary),
                    )
                  : CachedNetworkImage(
                      imageUrl: ImageUrl.optimized(p.firstImage, width: 220),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceVariant,
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image_outlined),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [p.categoryName, p.material]
                      .where((e) => e.isNotEmpty)
                      .join(' • '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.price(p.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.primaryDark,
                  ),
                ),
                if (p.isFeatured || !p.isAvailable)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 6,
                      children: [
                        if (p.isFeatured)
                          const _Badge('Featured', AppColors.primaryDark, AppColors.primaryLight),
                        if (!p.isAvailable)
                          const _Badge('Hidden / Out of Stock', AppColors.error, AppColors.errorLight),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textGrey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (v) {
              switch (v) {
                case 'edit':
                  onEdit();
                  break;
                case 'featured':
                  onToggleFeatured();
                  break;
                case 'available':
                  onToggleAvailable();
                  break;
                case 'delete':
                  onDelete();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Details'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'featured',
                child: Row(
                  children: [
                    Icon(p.isFeatured ? Icons.star_border_rounded : Icons.star_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(p.isFeatured ? 'Remove from Featured' : 'Mark as Featured'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'available',
                child: Row(
                  children: [
                    Icon(p.isAvailable ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                    SizedBox(width: 8),
                    Text(p.isAvailable ? 'Mark Unavailable' : 'Mark Available'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete Piece', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color bgColor;
  const _Badge(this.text, this.textColor, this.bgColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}