import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/empty_view.dart';
import 'package:jewel_ora/core/widgets/loading_view.dart';
import 'package:jewel_ora/models/category_model.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:jewel_ora/screens/admin/category_form_screen.dart';
import 'package:provider/provider.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  void _openForm(BuildContext context, [CategoryModel? category]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryFormScreen(category: category),
      ),
    );
  }

  Future<void> _delete(BuildContext context, CategoryModel category) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete category',
      message: 'Delete "${category.name}"? This cannot be undone.',
      confirmText: 'Delete',
    );
    if (!ok || !context.mounted) return;

    final provider = context.read<CategoryProvider>();
    final success = await provider.delete(category.id);
    if (!context.mounted) return;

    showAppSnackBar(
      context,
      success
          ? 'Category deleted'
          : (provider.errorMessage ?? AppStrings.somethingWentWrong),
      isError: !success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Builder(
        builder: (_) {
          if (provider.isLoading) return const LoadingView();
          if (provider.categories.isEmpty) {
            return const EmptyView(
              message: 'No categories yet. Tap Add to create one.',
              icon: Icons.category_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: provider.categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final c = provider.categories[i];
              return _CategoryTile(
                category: c,
                onEdit: () => _openForm(context, c),
                onDelete: () => _delete(context, c),
                onToggle: () => provider.toggleActive(c),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 64,
                height: 64,
                child: category.imageUrl.isEmpty
                    ? Container(
                  color: AppColors.primaryLight,
                  child: const Icon(Icons.image_outlined),
                )
                    : CachedNetworkImage(
                  imageUrl:
                  ImageUrl.optimized(category.imageUrl, width: 200),
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
                    category.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.isActive ? 'Visible to customers' : 'Hidden',
                    style: TextStyle(
                      fontSize: 12,
                      color: category.isActive
                          ? AppColors.success
                          : AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: category.isActive,
              activeColor: AppColors.primary,
              onChanged: (_) => onToggle(),
            ),
            PopupMenuButton<String>(
              onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}