import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/empty_view.dart';
import 'package:jewel_ora/core/widgets/loading_view.dart';
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
    final ok = await showConfirmDialog(
      context,
      title: 'Delete product',
      message: 'Delete "${p.name}"? This cannot be undone.',
      confirmText: 'Delete',
    );
    if (!ok || !mounted) return;

    final provider = context.read<ProductProvider>();
    final success = await provider.delete(p.id);
    if (!mounted) return;
    showAppSnackBar(
      context,
      success
          ? 'Product deleted'
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
      appBar: AppBar(title: Text('Products (${provider.products.length})')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search products',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 44,
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
              builder: (_) {
                if (provider.isLoading) return const LoadingView();
                if (provider.products.isEmpty) {
                  return const EmptyView(
                    message: 'No products yet. Tap Add to create one.',
                    icon: Icons.diamond_outlined,
                  );
                }
                if (items.isEmpty) {
                  return const EmptyView(
                    message: 'No products match your search',
                    icon: Icons.search_off,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
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
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: p.firstImage.isEmpty
                      ? Container(
                    color: AppColors.primaryLight,
                    child: const Icon(Icons.image_outlined),
                  )
                      : CachedNetworkImage(
                    imageUrl: ImageUrl.optimized(p.firstImage, width: 220),
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                    const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [p.categoryName, p.material]
                          .where((e) => e.isNotEmpty)
                          .join(' • '),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.price(p.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
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
                              const _Badge('Featured', AppColors.primary),
                            if (!p.isAvailable)
                              const _Badge('Hidden', AppColors.error),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'edit':
                      onEdit();
                    case 'featured':
                      onToggleFeatured();
                    case 'available':
                      onToggleAvailable();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'featured',
                    child: Text(
                        p.isFeatured ? 'Remove featured' : 'Mark featured'),
                  ),
                  PopupMenuItem(
                    value: 'available',
                    child: Text(
                        p.isAvailable ? 'Mark unavailable' : 'Mark available'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}