import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/widgets/coming_soon_screen.dart';
import 'package:jewel_ora/core/widgets/empty_view.dart';
import 'package:jewel_ora/core/widgets/loading_view.dart';
import 'package:jewel_ora/core/widgets/product_card.dart';
import 'package:jewel_ora/providers/banner_provider.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/screens/user/product_detail_screen.dart';
import 'package:jewel_ora/screens/user/widgets/home_banner_carousel.dart';
import 'package:jewel_ora/screens/user/widgets/home_category_list.dart';
import 'package:provider/provider.dart';

import '../../providers/shop_filter_provider.dart';
import '../../providers/user_nav_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _comingSoon(BuildContext context, String title) {
    // Replaced by real screens in Steps 11 and 12.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ComingSoonScreen(title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final banners = context.watch<BannerProvider>();
    final categories = context.watch<CategoryProvider>();
    final products = context.watch<ProductProvider>();

    final activeIds = categories.activeCategories.map((c) => c.id).toSet();
    final featured = products.products
        .where((p) =>
    p.isFeatured &&
        (categories.isLoading || activeIds.contains(p.categoryId)))
        .take(10)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ---------- Logo and shop name ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    if (settings.logoUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: ImageUrl.optimized(settings.logoUrl, width: 200),
                        height: 40,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => const Icon(
                            Icons.diamond_outlined,
                            color: AppColors.primary),
                      )
                    else
                      const Icon(Icons.diamond_outlined,
                          size: 36, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        settings.appName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------- Welcome message ----------
            if (settings.welcomeMessage.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    settings.welcomeMessage,
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                ),
              ),

            // ---------- Banners ----------
            SliverToBoxAdapter(
              child: banners.isLoading
                  ? const SizedBox(height: 150, child: LoadingView())
                  : HomeBannerCarousel(banners: banners.activeBanners),
            ),

            // ---------- Categories ----------
            if (categories.activeCategories.isNotEmpty) ...[
              const SliverToBoxAdapter(child: _SectionTitle('Shop by category')),
              SliverToBoxAdapter(
                child: HomeCategoryList(
                  categories: categories.activeCategories,
                  onTap: (c) {
                    context.read<ShopFilterProvider>().showCategory(c.id);
                    context
                        .read<UserNavProvider>()
                        .setIndex(UserNavProvider.shopTab);
                  },
                ),
              ),
            ],

            // ---------- Featured products ----------
            const SliverToBoxAdapter(child: _SectionTitle('Featured')),
            if (products.isLoading)
              const SliverToBoxAdapter(
                child: SizedBox(height: 200, child: LoadingView()),
              )
            else if (featured.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: EmptyView(
                    message: 'No featured products yet',
                    icon: Icons.diamond_outlined,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => ProductCard(
                      product: featured[i],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(productId: featured[i].id),
                            ),
                          ),
                    ),
                    childCount: featured.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}