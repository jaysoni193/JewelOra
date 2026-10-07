import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/theme/app_theme.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/banner_provider.dart';
import 'package:jewel_ora/providers/cart_provider.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/providers/stats_provider.dart';
import 'package:jewel_ora/providers/wishlist_provider.dart';
import 'package:jewel_ora/screens/auth/auth_gate.dart';
import 'package:jewel_ora/services/auth_service.dart';
import 'package:jewel_ora/services/banner_service.dart';
import 'package:jewel_ora/services/cart_service.dart';
import 'package:jewel_ora/services/category_service.dart';
import 'package:jewel_ora/services/product_service.dart';
import 'package:jewel_ora/services/settings_service.dart';
import 'package:jewel_ora/services/stats_service.dart';
import 'package:jewel_ora/services/wishlist_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => CategoryProvider(CategoryService())),
        ChangeNotifierProvider(create: (_) => ProductProvider(ProductService())),
        ChangeNotifierProvider(create: (_) => BannerProvider(BannerService())),
        ChangeNotifierProvider(create: (_) => SettingsProvider(SettingsService())),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(CartService()),
          // Admins do not have a cart, so we skip loading one for them.
          update: (_, auth, cart) =>
          cart!..updateUser(auth.isAdmin ? null : auth.user?.uid),
        ),
        ChangeNotifierProxyProvider<AuthProvider, WishlistProvider>(
          create: (_) => WishlistProvider(WishlistService()),
          // Admins do not use a wishlist, so we skip loading one for them.
          update: (_, auth, wishlist) =>
          wishlist!..updateUser(auth.isAdmin ? null : auth.user?.uid),
        ),
        ChangeNotifierProvider(create: (_) => StatsProvider(StatsService())),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}