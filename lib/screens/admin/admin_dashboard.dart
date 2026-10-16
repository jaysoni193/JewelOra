import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_icons.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/theme/app_decoration.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_bottom_sheet.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/brand_logo.dart';
import 'package:jewel_ora/core/widgets/app_dialog.dart';
import 'package:jewel_ora/core/widgets/coming_soon_screen.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/screens/admin/app_settings_screen.dart';
import 'package:jewel_ora/screens/admin/admin_enquiry_list_screen.dart';
import 'package:jewel_ora/screens/admin/banner_list_screen.dart';
import 'package:jewel_ora/screens/admin/branding_management_screen.dart';
import 'package:jewel_ora/screens/admin/category_list_screen.dart';
import 'package:jewel_ora/screens/admin/insights_screen.dart';
import 'package:jewel_ora/screens/admin/metal_rates_screen.dart';
import 'package:jewel_ora/screens/admin/product_list_screen.dart';
import 'package:jewel_ora/services/seed_data_service.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _open(BuildContext context, String title) {
    Widget screen;
    switch (title) {
      case 'Daily Metal Rates':
        screen = const MetalRatesScreen();
        break;
      case 'Customer Enquiries':
        screen = const AdminEnquiryListScreen();
        break;
      case 'Products':
        screen = const ProductListScreen();
        break;
      case 'Categories':
        screen = const CategoryListScreen();
        break;
      case 'Banners':
        screen = const BannerListScreen();
        break;
      case 'Store Settings':
        screen = const AppSettingsScreen();
        break;
      case 'App Branding':
        screen = const BrandingManagementScreen();
        break;
      case 'Insights & Analytics':
        screen = const InsightsScreen();
        break;
      default:
        screen = ComingSoonScreen(title: title);
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await AppDialog.logout(context);
    if (ok && context.mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  Future<void> _confirmSeed(BuildContext context) async {
    final confirmed = await AppBottomSheet.show<bool>(
      context,
      child: CommonBottomSheetContainer(
        title: AppStrings.confirmResetData,
        subtitle: AppStrings.resetDataDesc,
        icon: Icons.auto_awesome_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderAccent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Features covered in sample catalogue:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Live Metal Rates (24K Gold, 22K Gold, Silver)', style: TextStyle(fontSize: 12.5)),
                  const Text('• MRP strikethrough & discounts (up to 30%)', style: TextStyle(fontSize: 12.5)),
                  const Text('• Festive offer tags & sizing chips', style: TextStyle(fontSize: 12.5)),
                  const Text('• Multi-image galleries & specifications', style: TextStyle(fontSize: 12.5)),
                  const Text('• 8 Categories & 3 Promotional Banners', style: TextStyle(fontSize: 12.5)),
                  const Text('• Both In-Stock & Out-of-Stock items', style: TextStyle(fontSize: 12.5)),
                  const SizedBox(height: 10),
                  Text(
                    'Cost: 29 Firestore writes (100% free under Spark tier).',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryDark.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: AppButton.outlined(
                    title: AppStrings.cancel,
                    height: 46,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    title: AppStrings.seedData,
                    height: 46,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      showAppSnackBar(context, 'Seeding sample catalogue...');
      try {
        final count = await SeedDataService.seedCatalogue();
        if (context.mounted) {
          showAppSnackBar(
            context,
            'Success! Loaded $count sample items across 8 categories & 3 banners.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          showAppSnackBar(context, 'Error seeding data: $e', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final productsCount = context.watch<ProductProvider>().products.length;
    final outOfStockCount = context
        .watch<ProductProvider>()
        .products
        .where((p) => !p.isAvailable)
        .length;
    final categoriesCount =
        context.watch<CategoryProvider>().activeCategories.length;

    final items = <_AdminMenuItem>[
      const _AdminMenuItem(
        'Daily Metal Rates',
        AppIcons.metalRates,
        'Gold & Silver live rates',
      ),
      const _AdminMenuItem(
        'Customer Enquiries',
        AppIcons.enquiries,
        'Quotes & lead tracker',
      ),
      _AdminMenuItem(
        'Products',
        AppIcons.products,
        '$productsCount items',
      ),
      _AdminMenuItem(
        'Categories',
        AppIcons.categories,
        '$categoriesCount active',
      ),
      const _AdminMenuItem(
        'Banners',
        AppIcons.banners,
        'Home promotions',
      ),
      const _AdminMenuItem(
        'App Branding',
        AppIcons.branding,
        'App icon & store name',
      ),
      const _AdminMenuItem(
        'Store Settings',
        AppIcons.settings,
        'Address, hours & WhatsApp',
      ),
      const _AdminMenuItem(
        'Insights & Analytics',
        AppIcons.insights,
        'Views & enquiries',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            tooltip: 'Seed Sample Catalogue (18 items)',
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
            onPressed: () => _confirmSeed(context),
          ),
          IconButton(
            tooltip: AppStrings.logout,
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Welcome Card
            AppCard(
              padding: const EdgeInsets.all(20),
              color: AppColors.surface,
              border: Border.all(
                  color: AppColors.borderAccent.withValues(alpha: 0.8)),
              child: Row(
                children: [
                  const BrandLogo(size: 52),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user?.name ?? 'Admin'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Jewel Ora Management Suite',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Store Snapshot Stats Row
            Row(
              children: [
                Expanded(
                  child: _StatPill(
                    label: 'Total Products',
                    value: '$productsCount',
                    icon: Icons.diamond_outlined,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatPill(
                    label: 'Out of Stock',
                    value: '$outOfStockCount',
                    icon: Icons.inventory_2_outlined,
                    color: outOfStockCount > 0
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // One-tap Seed Demo Catalogue Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryLight, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: AppColors.borderAccent.withValues(alpha: 0.8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sample Catalogue (18 Items)',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Populate all features: live metal rates, discounts, offers & sizes',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                      ),
                      icon: const Icon(Icons.bolt_rounded, size: 18),
                      label: const Text(
                        'Seed Demo Catalogue',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      onPressed: () => _confirmSeed(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            const Text(
              'Store Management',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),

            // Management Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, i) => _AdminMenuCard(
                item: items[i],
                onTap: () => _open(context, items[i].title),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuItem {
  final String title;
  final IconData icon;
  final String subtitle;
  const _AdminMenuItem(this.title, this.icon, this.subtitle);
}

class _AdminMenuCard extends StatelessWidget {
  final _AdminMenuItem item;
  final VoidCallback onTap;
  const _AdminMenuCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              border: Border.all(
                  color: AppColors.borderAccent.withValues(alpha: 0.7)),
            ),
            child: Icon(item.icon, size: 28, color: AppColors.primary),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
        boxShadow: AppDecoration.luxuryShadow,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}