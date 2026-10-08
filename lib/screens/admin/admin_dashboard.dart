import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_icons.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/theme/app_decoration.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_dialog.dart';
import 'package:jewel_ora/core/widgets/coming_soon_screen.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/screens/admin/app_settings_screen.dart';
import 'package:jewel_ora/screens/admin/banner_list_screen.dart';
import 'package:jewel_ora/screens/admin/branding_management_screen.dart';
import 'package:jewel_ora/screens/admin/category_list_screen.dart';
import 'package:jewel_ora/screens/admin/insights_screen.dart';
import 'package:jewel_ora/screens/admin/product_list_screen.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _open(BuildContext context, String title) {
    Widget screen;
    switch (title) {
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
      _AdminMenuItem(
        'Banners',
        AppIcons.banners,
        'Home promotions',
      ),
      _AdminMenuItem(
        'App Branding',
        AppIcons.branding,
        'Logo & Appearance',
      ),
      _AdminMenuItem(
        'Store Settings',
        AppIcons.settings,
        'WhatsApp & info',
      ),
      _AdminMenuItem(
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
              border: Border.all(color: AppColors.borderAccent.withValues(alpha: 0.8)),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.admin_panel_settings_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
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
                          style: TextStyle(fontSize: 12, color: AppColors.textGrey),
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
                    color: outOfStockCount > 0 ? AppColors.error : AppColors.success,
                  ),
                ),
              ],
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
            ),
            child: Icon(item.icon, size: 22, color: AppColors.primaryDark),
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
                  style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}