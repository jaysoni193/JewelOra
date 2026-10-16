import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/theme/app_theme.dart';
import 'package:jewel_ora/core/widgets/connectivity_banner.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/banner_provider.dart';
import 'package:jewel_ora/providers/connectivity_provider.dart';
import 'package:jewel_ora/providers/cart_provider.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:jewel_ora/providers/enquiry_provider.dart';
import 'package:jewel_ora/providers/gold_savings_provider.dart';
import 'package:jewel_ora/providers/jewellery_vault_provider.dart';
import 'package:jewel_ora/providers/locale_provider.dart';
import 'package:jewel_ora/providers/occasion_reminder_provider.dart';
import 'package:jewel_ora/providers/metal_rate_provider.dart';
import 'package:jewel_ora/providers/price_alert_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/providers/shop_filter_provider.dart';
import 'package:jewel_ora/providers/stats_provider.dart';
import 'package:jewel_ora/providers/user_nav_provider.dart';
import 'package:jewel_ora/providers/bridal_planner_provider.dart';
import 'package:jewel_ora/providers/ring_size_provider.dart';
import 'package:jewel_ora/providers/video_appointment_provider.dart';
import 'package:jewel_ora/providers/wishlist_provider.dart';
import 'package:jewel_ora/screens/splash/splash_screen.dart';
import 'package:jewel_ora/services/auth_service.dart';
import 'package:jewel_ora/services/banner_service.dart';
import 'package:jewel_ora/services/cart_service.dart';
import 'package:jewel_ora/services/category_service.dart';
import 'package:jewel_ora/services/enquiry_service.dart';
import 'package:jewel_ora/services/metal_rate_service.dart';
import 'package:jewel_ora/services/notification_service.dart';
import 'package:jewel_ora/services/product_service.dart';
import 'package:jewel_ora/services/screen_security_service.dart';
import 'package:jewel_ora/services/settings_service.dart';
import 'package:jewel_ora/services/stats_service.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/services/crashlytics_service.dart';
import 'package:jewel_ora/services/wishlist_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Enable anti-screenshot & anti-screen-recording protection from app start
  await ScreenSecurityService.instance.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Firebase Crashlytics for production crash recording
  await CrashlyticsService.instance.init();
  // Initialize Push Notifications gracefully in background (100% Free Firebase Spark)
  NotificationService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => UserNavProvider()),
        ChangeNotifierProvider(create: (_) => ShopFilterProvider()),
        ChangeNotifierProvider(create: (_) => MetalRateProvider(MetalRateService())),
        ChangeNotifierProxyProvider<MetalRateProvider, PriceAlertProvider>(
          create: (_) => PriceAlertProvider(),
          update: (_, metalRates, alertProvider) {
            final p = alertProvider ?? PriceAlertProvider();
            p.checkRates(metalRates.rates);
            return p;
          },
        ),
        ChangeNotifierProvider(create: (_) => CategoryProvider(CategoryService())),
        ChangeNotifierProvider(create: (_) => JewelleryVaultProvider()),
        ChangeNotifierProvider(create: (_) => OccasionReminderProvider()),
        ChangeNotifierProvider(create: (_) => GoldSavingsProvider()),
        ChangeNotifierProvider(create: (_) => VideoAppointmentProvider()),
        ChangeNotifierProvider(create: (_) => BridalPlannerProvider()),
        ChangeNotifierProvider(create: (_) => RingSizeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider(ProductService())),
        ChangeNotifierProvider(create: (_) => BannerProvider(BannerService())),
        ChangeNotifierProvider(
          lazy: false, // start immediately so the app icon is always applied
          create: (_) => SettingsProvider(SettingsService()),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(CartService()),
          // Admins do not have a cart, so we skip loading one for them.
          update: (_, auth, cart) {
            NotificationService.instance.syncUserToken(auth.user?.uid);
            CrashlyticsService.instance.setUserId(auth.user?.uid ?? '');
            return cart!..updateUser(auth.isAdmin ? null : auth.user?.uid);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, WishlistProvider>(
          create: (_) => WishlistProvider(WishlistService()),
          // Admins do not use a wishlist, so we skip loading one for them.
          update: (_, auth, wishlist) =>
              wishlist!..updateUser(auth.isAdmin ? null : auth.user?.uid),
        ),
        ChangeNotifierProxyProvider<AuthProvider, EnquiryProvider>(
          create: (_) => EnquiryProvider(EnquiryService()),
          update: (_, auth, enquiry) =>
              enquiry!..updateUser(auth.user?.uid, isAdmin: auth.isAdmin),
        ),
        ChangeNotifierProvider(create: (_) => StatsProvider(StatsService())),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            key: ValueKey(localeProvider.locale),
            navigatorKey: GlobalLoader.navigatorKey,
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            locale: localeProvider.currentLocale,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.light,
            builder: (context, child) => GlobalLoaderOverlay(
              child: ConnectivityBannerWrapper(
                child: child ?? const SizedBox.shrink(),
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}