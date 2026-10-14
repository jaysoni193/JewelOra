import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_icons.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/providers/cart_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/providers/user_nav_provider.dart';
import 'package:jewel_ora/screens/user/cart_screen.dart';
import 'package:jewel_ora/screens/user/home_screen.dart';
import 'package:jewel_ora/screens/user/profile_screen.dart';
import 'package:jewel_ora/screens/user/shop_screen.dart';
import 'package:provider/provider.dart';

class UserShell extends StatelessWidget {
  const UserShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const _UserShellView();
  }
}

class _UserShellView extends StatelessWidget {
  const _UserShellView();

  // IndexedStack keeps each tab alive, so scroll position is not lost.
  static const _pages = [
    HomeScreen(),
    ShopScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<UserNavProvider>();
    final cartCount = context.watch<CartProvider>().itemCount;
    final settings = context.watch<SettingsProvider>().settings;

    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(index: nav.index, children: _pages),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(top: BorderSide(color: AppColors.border, width: 1.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: nav.index,
              onDestinationSelected: nav.setIndex,
              destinations: [
                NavigationDestination(
                  icon: const Icon(AppIcons.home),
                  selectedIcon: const Icon(AppIcons.homeActive, color: AppColors.primaryDark),
                  label: AppStrings.navHome,
                ),
                NavigationDestination(
                  icon: const Icon(AppIcons.shop),
                  selectedIcon: const Icon(AppIcons.shopActive, color: AppColors.primaryDark),
                  label: AppStrings.navShop,
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: cartCount > 0,
                    backgroundColor: AppColors.primaryDark,
                    label: Text(
                      '$cartCount',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                    child: const Icon(AppIcons.cart),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: cartCount > 0,
                    backgroundColor: AppColors.primaryDark,
                    label: Text(
                      '$cartCount',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                    child: const Icon(AppIcons.cartActive, color: AppColors.primaryDark),
                  ),
                  label: AppStrings.navCart,
                ),
                NavigationDestination(
                  icon: const Icon(AppIcons.profile),
                  selectedIcon: const Icon(AppIcons.profileActive, color: AppColors.primaryDark),
                  label: AppStrings.navProfile,
                ),
              ],
            ),
          ),
        ),

        // Force Update Blocking Screen if admin enabled it
        if (settings.forceUpdate)
          Positioned.fill(
            child: Material(
              color: Colors.black87,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.system_update_rounded, size: 54, color: AppColors.primary),
                      const SizedBox(height: 16),
                      const Text(
                        'Update Required',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        settings.forceUpdateMessage.isNotEmpty
                            ? settings.forceUpdateMessage
                            : 'A new version of Jewel Ora is available with exciting features. Please update to continue.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}