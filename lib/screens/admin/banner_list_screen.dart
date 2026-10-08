import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/theme/app_text_styles.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_dialog.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/app_snackbar.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/models/banner_model.dart';
import 'package:jewel_ora/providers/banner_provider.dart';
import 'package:jewel_ora/screens/admin/banner_form_screen.dart';
import 'package:provider/provider.dart';

class BannerListScreen extends StatelessWidget {
  const BannerListScreen({super.key});

  void _openForm(BuildContext context, [BannerModel? banner]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BannerFormScreen(banner: banner),
      ),
    );
  }

  Future<void> _delete(BuildContext context, BannerModel banner) async {
    final ok = await AppDialog.delete(
      context,
      title: 'Delete Banner',
      message: 'Delete this promotional banner? This action cannot be undone.',
      deleteText: 'Delete',
    );
    if (!ok || !context.mounted) return;

    final provider = context.read<BannerProvider>();
    final success = await provider.delete(banner.id);
    if (!context.mounted) return;

    if (success) {
      AppSnackbar.showSuccess(context, 'Banner deleted successfully');
    } else {
      AppSnackbar.showError(
        context,
        provider.errorMessage ?? AppStrings.somethingWentWrong,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BannerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotional Banners'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Banner', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const Center(child: AppLoader());
          }
          if (provider.banners.isEmpty) {
            return EmptyState(
              title: 'No Banners Yet',
              message: 'Add showcase banners to highlight collections and seasonal offers.',
              icon: Icons.view_carousel_outlined,
              buttonTitle: 'Add Banner',
              onButtonPressed: () => _openForm(context),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p12, AppSizes.p16, AppSizes.p8),
                child: Row(
                  children: [
                    const Icon(Icons.drag_indicator, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Long press and drag any banner to reorder the carousel display.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textGrey),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p4, AppSizes.p16, 90),
                  itemCount: provider.banners.length,
                  onReorder: provider.reorder,
                  itemBuilder: (context, i) {
                    final b = provider.banners[i];
                    return Padding(
                      key: ValueKey(b.id),
                      padding: const EdgeInsets.only(bottom: AppSizes.p12),
                      child: _BannerTile(
                        banner: b,
                        position: i + 1,
                        onEdit: () => _openForm(context, b),
                        onDelete: () => _delete(context, b),
                        onToggle: () => provider.toggleActive(b),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BannerTile extends StatelessWidget {
  final BannerModel banner;
  final int position;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _BannerTile({
    required this.banner,
    required this.position,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r12)),
            child: AspectRatio(
              aspectRatio: 16 / 7,
              child: Opacity(
                opacity: banner.isActive ? 1.0 : 0.45,
                child: CachedNetworkImage(
                  imageUrl: ImageUrl.optimized(banner.imageUrl, width: 800),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined, color: AppColors.textLight, size: 36),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.p12, AppSizes.p8, AppSizes.p8, AppSizes.p8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    '$position',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner.title.isEmpty ? 'Untitled Banner' : banner.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: banner.isActive ? AppColors.success : AppColors.textLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            banner.isActive ? 'Active on Home' : 'Hidden',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: banner.isActive ? AppColors.success : AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: banner.isActive,
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
          ),
        ],
      ),
    );
  }
}