import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/empty_view.dart';
import 'package:jewel_ora/core/widgets/loading_view.dart';
import 'package:jewel_ora/models/banner_model.dart';
import 'package:jewel_ora/providers/banner_provider.dart';
import 'package:jewel_ora/screens/admin/banner_form_screen.dart';
import 'package:provider/provider.dart';

class BannerListScreen extends StatelessWidget {
  const BannerListScreen({super.key});

  void _openForm(BuildContext context, [BannerModel? banner]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BannerFormScreen(banner: banner)),
    );
  }

  Future<void> _delete(BuildContext context, BannerModel banner) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete banner',
      message: 'Delete this banner? This cannot be undone.',
      confirmText: 'Delete',
    );
    if (!ok || !context.mounted) return;

    final provider = context.read<BannerProvider>();
    final success = await provider.delete(banner.id);
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      success
          ? 'Banner deleted'
          : (provider.errorMessage ?? AppStrings.somethingWentWrong),
      isError: !success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BannerProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Banners')),
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
          if (provider.banners.isEmpty) {
            return const EmptyView(
              message: 'No banners yet. Tap Add to create one.',
              icon: Icons.image_outlined,
            );
          }
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.drag_indicator,
                        size: 18, color: AppColors.textGrey),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Long press a banner and drag to change its order.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textGrey),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: provider.banners.length,
                  onReorder: provider.reorder,
                  itemBuilder: (context, i) {
                    final b = provider.banners[i];
                    return Padding(
                      key: ValueKey(b.id),
                      padding: const EdgeInsets.only(bottom: 12),
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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: Opacity(
              opacity: banner.isActive ? 1 : 0.4,
              child: CachedNetworkImage(
                imageUrl: ImageUrl.optimized(banner.imageUrl, width: 800),
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) =>
                const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
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
                        color: AppColors.primaryDark),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner.title.isEmpty ? 'Untitled banner' : banner.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        banner.isActive ? 'Visible to customers' : 'Hidden',
                        style: TextStyle(
                          fontSize: 12,
                          color: banner.isActive
                              ? AppColors.success
                              : AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: banner.isActive,
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
        ],
      ),
    );
  }
}