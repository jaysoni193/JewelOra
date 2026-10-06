import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/coming_soon_screen.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/screens/admin/product_list_screen.dart';
import 'package:provider/provider.dart';

import 'app_settings_screen.dart';
import 'banner_list_screen.dart';
import 'category_list_screen.dart';

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
      case 'App Settings':
        screen = const AppSettingsScreen();
        break;
      default:
        screen = ComingSoonScreen(title: title);
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: AppStrings.logout,
      message: 'Do you want to logout?',
      confirmText: AppStrings.logout,
    );
    if (ok && context.mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    final items = <_AdminMenuItem>[
      _AdminMenuItem('Products', Icons.diamond_outlined),
      _AdminMenuItem('Categories', Icons.category_outlined),
      _AdminMenuItem('Banners', Icons.image_outlined),
      _AdminMenuItem('App Settings', Icons.settings_outlined),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            tooltip: AppStrings.logout,
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.name ?? 'Admin'}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage your store from here',
              style: TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (_, i) => _AdminMenuCard(
                  item: items[i],
                  onTap: () => _open(context, items[i].title),
                ),
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
  const _AdminMenuItem(this.title, this.icon);
}

class _AdminMenuCard extends StatelessWidget {
  final _AdminMenuItem item;
  final VoidCallback onTap;
  const _AdminMenuCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryLight,
              child: Icon(item.icon, size: 28, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}