import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_icons.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/providers/shop_filter_provider.dart';
import 'package:jewel_ora/providers/user_nav_provider.dart';
import 'package:jewel_ora/screens/user/cart_screen.dart';
import 'package:jewel_ora/screens/user/home_screen.dart';
import 'package:jewel_ora/screens/user/profile_screen.dart';
import 'package:jewel_ora/screens/user/shop_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class UserShell extends StatelessWidget {
  const UserShell({super.key});

  @override
  Widget build(BuildContext context) {
    // Created here (not in main.dart) so that they reset on logout.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserNavProvider()),
        ChangeNotifierProvider(create: (_) => ShopFilterProvider()),
      ],
      child: const _UserShellView(),
    );
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

    return Scaffold(
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
            const NavigationDestination(
              icon: Icon(AppIcons.home),
              selectedIcon: Icon(AppIcons.homeActive, color: AppColors.primaryDark),
              label: AppStrings.navHome,
            ),
            const NavigationDestination(
              icon: Icon(AppIcons.shop),
              selectedIcon: Icon(AppIcons.shopActive, color: AppColors.primaryDark),
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
            const NavigationDestination(
              icon: Icon(AppIcons.profile),
              selectedIcon: Icon(AppIcons.profileActive, color: AppColors.primaryDark),
              label: AppStrings.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}