import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/widgets/empty_view.dart';
import 'package:jewel_ora/core/widgets/loading_view.dart';
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
    // After the first frame, because load() notifies listeners.
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
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: p)),
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
      if (!byId.containsKey(s.productId)) continue; // deleted products
      totalViews += s.views;
      totalEnquiries += s.enquiries;
    }

    Widget body;
    if (!stats.hasLoaded) {
      body = stats.errorMessage != null
          ? EmptyView(
        message: stats.errorMessage!,
        icon: Icons.error_outline,
        actionLabel: 'Retry',
        onAction: stats.load,
      )
          : const LoadingView();
    } else {
      body = RefreshIndicator(
        onRefresh: stats.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (stats.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Could not refresh. Showing the last loaded numbers.',
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                _StatTile(
                  icon: Icons.diamond_outlined,
                  label: 'Products',
                  value: '${products.length}',
                  note: '${products.where((p) => p.isAvailable).length} available',
                ),
                _StatTile(
                  icon: Icons.category_outlined,
                  label: 'Categories',
                  value: '${categories.length}',
                  note: '${categories.where((c) => c.isActive).length} visible',
                ),
                _StatTile(
                  icon: Icons.image_outlined,
                  label: 'Banners',
                  value: '${banners.length}',
                  note: '${banners.where((b) => b.isActive).length} visible',
                ),
                _StatTile(
                  icon: Icons.people_outline,
                  label: 'Customers',
                  value: stats.customerCount?.toString() ?? '-',
                  note: 'registered',
                ),
                _StatTile(
                  icon: Icons.visibility_outlined,
                  label: 'Product views',
                  value: '$totalViews',
                  note: 'product pages opened',
                ),
                _StatTile(
                  icon: Icons.chat_outlined,
                  label: 'Enquiries',
                  value: '$totalEnquiries',
                  note: 'WhatsApp taps',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _RankSection(
              title: 'Most viewed',
              icon: Icons.visibility_outlined,
              emptyText: 'No views yet. They appear when customers open products.',
              items: mostViewed,
              onTap: _openProduct,
            ),
            const SizedBox(height: 24),
            _RankSection(
              title: 'Most enquired',
              icon: Icons.chat_outlined,
              emptyText: 'No enquiries yet. They appear when customers tap WhatsApp.',
              items: mostEnquired,
              onTap: _openProduct,
            ),
            const SizedBox(height: 16),
            const Text(
              'Each customer is counted once per product per app session, '
                  'so the numbers are a guide, not an exact total.',
              style: TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(icon, size: 16, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textGrey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            Text(
              note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String emptyText;
  final List<_Ranked> items;
  final ValueChanged<ProductModel> onTap;

  const _RankSection({
    required this.title,
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
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Card(
          child: items.isEmpty
              ? Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              emptyText,
              style: const TextStyle(color: AppColors.textGrey),
            ),
          )
              : Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const Divider(height: 1),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: p.firstImage.isEmpty
                    ? Container(
                  color: AppColors.primaryLight,
                  child: const Icon(Icons.image_outlined),
                )
                    : CachedNetworkImage(
                  imageUrl: ImageUrl.optimized(p.firstImage, width: 150),
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
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    p.categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            Icon(icon, size: 16, color: AppColors.textGrey),
            const SizedBox(width: 4),
            Text(
              '${item.count}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}