import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/brand_logo.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/core/widgets/product_card.dart';
import 'package:jewel_ora/providers/banner_provider.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/screens/user/product_detail_screen.dart';
import 'package:jewel_ora/screens/user/store_info_screen.dart';
import 'package:jewel_ora/screens/user/widgets/home_banner_carousel.dart';
import 'package:jewel_ora/screens/user/widgets/home_category_list.dart';
import 'package:jewel_ora/screens/user/widgets/today_rates_strip.dart';
import 'package:provider/provider.dart';

import '../../providers/shop_filter_provider.dart';
import '../../providers/user_nav_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openAnnouncements(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AnnouncementsSheet(),
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
                    // Logo = the icon chosen in the Admin panel
                    const BrandLogo(size: 44),
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
                      tooltip: 'Search jewellery',
                      onPressed: () {
                        context.read<UserNavProvider>().setIndex(UserNavProvider.shopTab);
                      },
                    ),
                    // Action announcements / notifications icon
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textDark),
                      tooltip: 'Offers & Announcements',
                      onPressed: () => _openAnnouncements(context),
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

            // ---------- Live Metal Rates Strip (CaratLane & GIVA style) ----------
            const SliverToBoxAdapter(
              child: TodayRatesStrip(),
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

            // ---------- Visit Store Experience Banner ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                child: _StoreExperienceBanner(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StoreInfoScreen()),
                  ),
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

class _StoreExperienceBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _StoreExperienceBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Experience Boutique',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.verified_rounded, size: 14, color: AppColors.accent),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    settings.storeAddress.isNotEmpty
                        ? settings.storeAddress
                        : 'Visit our store for custom design consultations & free jewellery spa.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Visit',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementsSheet extends StatelessWidget {
  const _AnnouncementsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Offers & Highlights',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _AnnouncementTile(
                icon: Icons.local_fire_department_outlined,
                iconColor: AppColors.accent,
                title: 'Diwali Festive Sale Live!',
                subtitle: 'Flat 20% off on Diamond jewellery and special making charges.',
              ),
              const SizedBox(height: 10),
              _AnnouncementTile(
                icon: Icons.price_change_outlined,
                iconColor: AppColors.primary,
                title: 'Live Gold & Silver Rates',
                subtitle: 'Daily rates are updated automatically. Track trends on Home.',
              ),
              const SizedBox(height: 10),
              _AnnouncementTile(
                icon: Icons.cleaning_services_outlined,
                iconColor: const Color(0xFF0D9488),
                title: 'Complimentary Jewellery Spa',
                subtitle: 'Free ultrasonic cleaning available at our Experience Boutique.',
              ),
              const SizedBox(height: 16),
              AppButton(
                title: 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _AnnouncementTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}