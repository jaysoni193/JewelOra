import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_images.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ---------- Dynamic Brand Header ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                child: Row(
                  children: [
                    // Dynamic In-App Logo with Cached Image + Fallback
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        border: Border.all(
                          color: AppColors.borderGold.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: settings.logoUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: ImageUrl.optimized(settings.logoUrl, width: 140),
                                fit: BoxFit.contain,
                                errorWidget: (context, url, error) => Image.asset(
                                  AppImages.logo,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Image.asset(
                                AppImages.logo,
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.appName.isNotEmpty ? settings.appName : AppStrings.appName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            settings.welcomeMessage.isNotEmpty
                                ? settings.welcomeMessage
                                : AppStrings.appTagline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action quick search icon
                    IconButton(
                      icon: const Icon(Icons.search_rounded, color: AppColors.textDark),
                      onPressed: () {
                        context.read<UserNavProvider>().setIndex(UserNavProvider.shopTab);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 6)),

            // ---------- Promotional Banners ----------
            SliverToBoxAdapter(
              child: banners.isLoading
                  ? const SizedBox(height: 160, child: Center(child: AppLoader(size: 44)))
                  : HomeBannerCarousel(banners: banners.activeBanners),
            ),

            // ---------- Categories ----------
            if (categories.activeCategories.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: AppStrings.shopByCategory,
                  onAction: () {
                    context.read<ShopFilterProvider>().setCategory(null);
                    context.read<UserNavProvider>().setIndex(UserNavProvider.shopTab);
                  },
                ),
              ),
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

            // ---------- Featured Products Collection ----------
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: AppStrings.featuredCollection,
                actionText: AppStrings.viewAll,
                onAction: () {
                  context.read<ShopFilterProvider>().clearFilters();
                  context.read<UserNavProvider>().setIndex(UserNavProvider.shopTab);
                },
              ),
            ),

            if (products.isLoading)
              const SliverToBoxAdapter(
                child: SizedBox(height: 220, child: Center(child: AppLoader(size: 50))),
              )
            else if (featured.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: EmptyState(
                    title: 'No featured items yet',
                    subtitle: 'Explore our latest jewellery arrivals.',
                    icon: Icons.diamond_outlined,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => ProductCard(
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: AppColors.textDark,
            ),
          ),
          if (onAction != null)
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionText ?? 'View All',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}