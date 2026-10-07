import 'package:flutter/material.dart';
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.index,
        onDestinationSelected: nav.setIndex,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.diamond_outlined),
            selectedIcon: Icon(Icons.diamond),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_bag),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}