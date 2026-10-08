import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/theme/app_text_styles.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_dialog.dart';
import 'package:jewel_ora/core/widgets/app_image.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/app_snackbar.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/models/category_model.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:jewel_ora/screens/admin/category_form_screen.dart';
import 'package:provider/provider.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  void _openForm(BuildContext context, [CategoryModel? category]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryFormScreen(category: category),
      ),
    );
  }

  Future<void> _delete(BuildContext context, CategoryModel category) async {
    final confirmed = await AppDialog.delete(
      context,
      title: 'Delete Category',
      message: 'Delete "${category.name}"? This action cannot be undone.',
      deleteText: 'Delete',
    );
    if (!confirmed || !context.mounted) return;

    final provider = context.read<CategoryProvider>();
    final success = await provider.delete(category.id);
    if (!context.mounted) return;

    if (success) {
      AppSnackbar.showSuccess(context, 'Category deleted successfully');
    } else {
      AppSnackbar.showError(
        context,
        provider.errorMessage ?? AppStrings.somethingWentWrong,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Category', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const Center(child: AppLoader());
          }
          if (provider.categories.isEmpty) {
            return EmptyState(
              title: 'No Categories',
              message: 'No categories created yet. Tap Add Category to get started.',
              icon: Icons.category_outlined,
              buttonTitle: 'Add Category',
              onButtonPressed: () => _openForm(context),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p16, AppSizes.p16, 90),
            itemCount: provider.categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSizes.p12),
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
    return AppCard(
      padding: const EdgeInsets.all(AppSizes.p12),
      child: Row(
        children: [
          AppImage(
            imageUrl: category.imageUrl,
            width: 64,
            height: 64,
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
          const SizedBox(width: AppSizes.p16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: AppTextStyles.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: category.isActive ? AppColors.success : AppColors.textLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.isActive ? 'Visible to customers' : 'Hidden',
                      style: AppTextStyles.caption.copyWith(
                        color: category.isActive ? AppColors.success : AppColors.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: category.isActive,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryLight,
            onChanged: (value) => onToggle(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textGrey),
            onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
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