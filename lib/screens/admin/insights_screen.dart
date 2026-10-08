import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/theme/app_text_styles.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/models/product_stats_model.dart';
import 'package:jewel_ora/providers/banner_provider.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/providers/stats_provider.dart';
import 'package:jewel_ora/screens/admin/product_form_screen.dart';
import 'package:provider/provider.dart';

typedef _Ranked = ({ProductModel product, int count});

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StatsProvider>().load();
    });
  }

  /// Top 5 existing products by the chosen counter (zero counts are skipped).
  List<_Ranked> _rank(
    List<ProductStatsModel> stats,
    Map<String, ProductModel> byId,
    int Function(ProductStatsModel) pick,
  ) {
    final list = <_Ranked>[];
    for (final s in stats) {
      final p = byId[s.productId];
      final c = pick(s);
      if (p != null && c > 0) list.add((product: p, count: c));
    }
    list.sort((a, b) => b.count.compareTo(a.count));
    return list.take(5).toList();
  }

  void _openProduct(ProductModel p) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ProductFormScreen(product: p)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final products = context.watch<ProductProvider>().products;
    final categories = context.watch<CategoryProvider>().categories;
    final banners = context.watch<BannerProvider>().banners;

    final byId = {for (final p in products) p.id: p};
    final mostViewed = _rank(stats.items, byId, (s) => s.views);
    final mostEnquired = _rank(stats.items, byId, (s) => s.enquiries);

    var totalViews = 0;
    var totalEnquiries = 0;
    for (final s in stats.items) {
      if (!byId.containsKey(s.productId)) continue;
      totalViews += s.views;
      totalEnquiries += s.enquiries;
    }

    Widget body;
    if (!stats.hasLoaded) {
      body = stats.errorMessage != null
          ? EmptyState(
              message: stats.errorMessage!,
              icon: Icons.error_outline,
              buttonTitle: 'Retry',
              onButtonPressed: stats.load,
            )
          : const Center(child: AppLoader());
    } else {
      body = RefreshIndicator(
        color: AppColors.primary,
        onRefresh: stats.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.p16),
          children: [
            if (stats.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: AppSizes.p12),
                padding: const EdgeInsets.all(AppSizes.p12),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Could not refresh. Showing cached numbers.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),

            // Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSizes.p12,
              mainAxisSpacing: AppSizes.p12,
              childAspectRatio: 1.25,
              children: [
                _StatTile(
                  icon: Icons.diamond_outlined,
                  label: 'Products',
                  value: '${products.length}',
                  note: '${products.where((p) => p.isAvailable).length} in stock',
                ),
                _StatTile(
                  icon: Icons.category_outlined,
                  label: 'Categories',
                  value: '${categories.length}',
                  note: '${categories.where((c) => c.isActive).length} visible',
                ),
                _StatTile(
                  icon: Icons.view_carousel_outlined,
                  label: 'Banners',
                  value: '${banners.length}',
                  note: '${banners.where((b) => b.isActive).length} active',
                ),
                _StatTile(
                  icon: Icons.people_outline,
                  label: 'Customers',
                  value: stats.customerCount?.toString() ?? '—',
                  note: 'registered accounts',
                ),
                _StatTile(
                  icon: Icons.visibility_outlined,
                  label: 'Product Views',
                  value: '$totalViews',
                  note: 'page view sessions',
                ),
                _StatTile(
                  icon: Icons.chat_bubble_outline,
                  label: 'Enquiries',
                  value: '$totalEnquiries',
                  note: 'WhatsApp clicks',
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p24),

            // Most Viewed
            _RankSection(
              title: 'Most Viewed Creations',
              subtitle: 'Jewellery pieces with highest boutique traffic',
              icon: Icons.visibility_outlined,
              emptyText: 'No views recorded yet. Product views will appear once customers explore the collection.',
              items: mostViewed,
              onTap: _openProduct,
            ),
            const SizedBox(height: AppSizes.p24),

            // Most Enquired
            _RankSection(
              title: 'Top WhatsApp Enquiries',
              subtitle: 'Pieces that generated direct concierge chats',
              icon: Icons.chat_bubble_outline,
              emptyText: 'No enquiries yet. Enquiries record when customers initiate WhatsApp consultation.',
              items: mostEnquired,
              onTap: _openProduct,
            ),
            const SizedBox(height: AppSizes.p20),

            // Footer Note
            Container(
              padding: const EdgeInsets.all(AppSizes.p12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSizes.r8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insights, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Unique counts are tracked per device session to deliver genuine engagement insights.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textGrey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Insights & Analytics'),
        actions: [
          IconButton(
            tooltip: 'Refresh Analytics',
            icon: const Icon(Icons.refresh),
            onPressed: stats.isLoading ? null : stats.load,
          ),
        ],
      ),
      body: body,
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String note;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSizes.p12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String emptyText;
  final List<_Ranked> items;
  final ValueChanged<ProductModel> onTap;

  const _RankSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.emptyText,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h4),
        const SizedBox(height: 2),
        Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textGrey)),
        const SizedBox(height: AppSizes.p12),
        AppCard(
          padding: EdgeInsets.zero,
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSizes.p20),
                  child: Center(
                    child: Text(
                      emptyText,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),
                      _RankTile(
                        rank: i + 1,
                        item: items[i],
                        icon: icon,
                        onTap: () => onTap(items[i].product),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _RankTile extends StatelessWidget {
  final int rank;
  final _Ranked item;
  final IconData icon;
  final VoidCallback onTap;

  const _RankTile({
    required this.rank,
    required this.item,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.r12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p12),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rank <= 3 ? AppColors.primaryLight : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: rank <= 3 ? AppColors.primary : AppColors.textGrey,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.p12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.r8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: p.firstImage.isEmpty
                    ? Container(
                        color: AppColors.primaryLight,
                        child: const Icon(Icons.diamond_outlined, color: AppColors.primary, size: 22),
                      )
                    : CachedNetworkImage(
                        imageUrl: ImageUrl.optimized(p.firstImage, width: 150),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: AppColors.surfaceVariant),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.broken_image_outlined, size: 20),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppSizes.p12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppSizes.r16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${item.count}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}