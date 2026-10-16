import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/brand_logo.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/core/widgets/product_card.dart';
import 'package:jewel_ora/providers/banner_provider.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:jewel_ora/providers/occasion_reminder_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/screens/user/product_detail_screen.dart';
import 'package:jewel_ora/screens/user/ar_try_on_screen.dart';
import 'package:jewel_ora/screens/user/store_info_screen.dart';
import 'package:jewel_ora/screens/user/widgets/gift_finder_sheet.dart';
import 'package:jewel_ora/screens/user/widgets/home_banner_carousel.dart';
import 'package:jewel_ora/screens/user/widgets/home_category_list.dart';
import 'package:jewel_ora/screens/user/widgets/occasion_reminder_sheet.dart';
import 'package:jewel_ora/screens/user/widgets/today_rates_strip.dart';
import 'package:jewel_ora/screens/user/widgets/video_shopping_sheet.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/responsive.dart';
import 'package:jewel_ora/providers/bridal_planner_provider.dart';
import 'package:jewel_ora/providers/video_appointment_provider.dart';
import 'package:jewel_ora/screens/user/widgets/bridal_planner_sheet.dart';
import 'package:provider/provider.dart';

import 'package:jewel_ora/screens/user/widgets/notification_center_sheet.dart';
import '../../providers/shop_filter_provider.dart';
import '../../providers/user_nav_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openAnnouncements(BuildContext context) {
    NotificationCenterSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final banners = context.watch<BannerProvider>();
    final categories = context.watch<CategoryProvider>();
    final products = context.watch<ProductProvider>();
    final upcomingMilestones = context.watch<OccasionReminderProvider>().getUpcomingReminders();
    final nextVideoAppt = context.watch<VideoAppointmentProvider>().nextUpcomingAppointment;
    final bridalProfile = context.watch<BridalPlannerProvider>().profile;

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
                    // Action Live Video Shopping icon
                    IconButton(
                      icon: const Icon(Icons.video_call_outlined, color: AppColors.primary),
                      tooltip: 'Live Video Shopping',
                      onPressed: () => VideoShoppingSheet.show(context),
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

            // ---------- Upcoming Milestone Alert Banner (if any within 14 days) ----------
            if (upcomingMilestones.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => OccasionReminderSheet.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          const Text('💖', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${upcomingMilestones.first.title} in ${upcomingMilestones.first.daysUntilNext(DateTime.now())} days!',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'Explore curated gifts for ${upcomingMilestones.first.recipient} →',
                                  style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // ---------- Upcoming Video Consultation Alert Banner ----------
            if (nextVideoAppt != null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => VideoShoppingSheet.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('📹', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Live Video Call: ${nextVideoAppt.categoryInterest}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${nextVideoAppt.appointmentDate.day}/${nextVideoAppt.appointmentDate.month} at ${nextVideoAppt.timeSlot} • ${nextVideoAppt.platform} →',
                                  style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // ---------- Active Bridal Trousseau Alert Banner ----------
            if (bridalProfile != null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => BridalPlannerSheet.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.12),
                            AppColors.accent.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('👰', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${bridalProfile.brideName}'s Bridal Trousseau",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${bridalProfile.purchasedCount}/${bridalProfile.totalItemsCount} pieces acquired • ${Formatters.price(bridalProfile.remainingBudget)} balance →',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // ---------- Curated Gift Finder Prompt Banner ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => GiftFinderSheet.show(context),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.08),
                            AppColors.accent.withValues(alpha: 0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('🎁', style: TextStyle(fontSize: 24)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      AppStrings.giftFinder,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'QUIZ',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  AppStrings.giftFinderSubtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGrey,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ---------- AR Virtual Try-On Banner ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => ArTryOnScreen.open(context),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentGold.withValues(alpha: 0.15),
                            AppColors.primary.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accentGold.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.face_retouching_natural_rounded,
                                color: AppColors.primary,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      AppStrings.arVirtualTryOn,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'LIVE AR',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  AppStrings.arTryOnSubtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGrey,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.gridColumns(context),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: Responsive.productCardAspectRatio(context),
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