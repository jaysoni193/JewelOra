import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/core/widgets/product_card.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/providers/metal_rate_provider.dart';
import 'package:jewel_ora/providers/price_alert_provider.dart';
import 'package:jewel_ora/screens/splash/splash_screen.dart';
import 'package:jewel_ora/models/wishlist_item_model.dart';
import 'package:jewel_ora/providers/wishlist_provider.dart';
import 'package:jewel_ora/screens/user/widgets/jewellery_care_dialog.dart';
import 'package:jewel_ora/screens/user/widgets/ring_size_guide_dialog.dart';
import 'package:jewel_ora/screens/user/widgets/today_rates_strip.dart';
import 'package:jewel_ora/core/widgets/connectivity_banner.dart';
import 'package:jewel_ora/providers/connectivity_provider.dart';
import 'package:jewel_ora/services/metal_rate_service.dart';
import 'package:jewel_ora/services/wishlist_service.dart';

class _FakeMetalRateService implements MetalRateService {
  @override
  Stream<MetalRateModel> watchRates() => Stream.value(const MetalRateModel());

  @override
  Future<MetalRateModel> getRates() async => const MetalRateModel();

  @override
  Future<void> save(MetalRateModel rates) async {}
}

class _FakeWishlistService implements WishlistService {
  @override
  Stream<List<WishlistItemModel>> watch(String uid) => Stream.value([]);

  @override
  Future<void> add(String uid, String productId) async {}

  @override
  Future<void> remove(String uid, String productId) async {}
}

void main() {
  testWidgets('AppButton renders and triggers onPressed callback', (tester) async {
    var wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            title: 'Test Button',
            onPressed: () => wasTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);
    await tester.tap(find.text('Test Button'));
    await tester.pump();
    expect(wasTapped, isTrue);
  });

  testWidgets('AppLoader renders luxury custom painter with message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLoader(
            size: 64,
            message: 'Loading your jewellery...',
          ),
        ),
      ),
    );

    expect(find.byType(AppLoader), findsOneWidget);
    expect(find.text('Loading your jewellery...'), findsOneWidget);
  });

  testWidgets('EmptyState displays title and message correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            title: 'No Items',
            message: 'Nothing here yet',
          ),
        ),
      ),
    );

    expect(find.text('No Items'), findsOneWidget);
    expect(find.text('Nothing here yet'), findsOneWidget);
  });

  testWidgets('AppCard renders child with decoration', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppCard(
            child: Text('Card Content'),
          ),
        ),
      ),
    );

    expect(find.text('Card Content'), findsOneWidget);
    expect(find.byType(AppCard), findsOneWidget);
  });

  testWidgets('RingSizeGuideSheet renders all tabs including Visual Sizer Slider without Material errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RingSizeGuideSheet(),
        ),
      ),
    );

    // Initial tab: Ring Chart
    expect(find.text('Ring Chart'), findsOneWidget);
    expect(find.text('US Size'), findsOneWidget);

    // Switch to Visual Sizer tab (contains the Slider)
    await tester.tap(find.text('Visual Sizer'));
    await tester.pumpAndSettle();

    expect(find.byType(Slider), findsOneWidget);

    // Switch to Bangles tab
    await tester.tap(find.text('Bangles'));
    await tester.pumpAndSettle();

    expect(find.text('Medium / Standard'), findsOneWidget);
  });

  testWidgets('JewelleryCareSheet renders tips correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: JewelleryCareSheet(),
        ),
      ),
    );

    expect(find.text('Gold & Platinum Care'), findsOneWidget);
    expect(find.text('925 Sterling Silver'), findsOneWidget);
  });

  testWidgets('SplashScreen renders without error and displays branding', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(isInitialLaunch: false),
      ),
    );
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('JEWEL ORA'), findsOneWidget);

    // Settle timer
    await tester.pump(const Duration(milliseconds: 3000));
  });

  testWidgets('TodayRatesStrip renders without RenderFlex overflow on narrow 320px screen', (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeService = _FakeMetalRateService();
    final metalRateProvider = MetalRateProvider(fakeService);
    final priceAlertProvider = PriceAlertProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: metalRateProvider),
          ChangeNotifierProvider.value(value: priceAlertProvider),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TodayRatesStrip(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify widget rendered with all elements intact and zero overflows
    expect(find.byType(TodayRatesStrip), findsOneWidget);
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('Exchange ⚖️'), findsOneWidget);
    expect(find.text('Price Alert 🔔'), findsOneWidget);
    expect(find.text(AppStrings.calculate), findsOneWidget);
  });

  testWidgets('ProductCard renders without RenderFlex overflow under tight constraints (w=155, h=230)', (tester) async {
    final product = ProductModel(
      id: 'test_prod_1',
      name: '22K Traditional Kundan Polki Bridal Necklace Set with Rubies',
      categoryId: 'cat_bridal',
      categoryName: 'Bridal Necklaces',
      price: 125000,
      mrp: 145000,
      material: '22K Yellow Gold (916 BIS Hallmark)',
      isAvailable: true,
      images: const [],
      createdAt: DateTime.now(),
    );

    final wishlistProvider = WishlistProvider(_FakeWishlistService());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: wishlistProvider,
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 155,
                height: 230,
                child: ProductCard(
                  product: product,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ProductCard), findsOneWidget);
    expect(find.text('BRIDAL NECKLACES'), findsOneWidget);
  });

  testWidgets('ConnectivityBannerWrapper displays Please Check Internet Connection when offline and Back Online on restore', (tester) async {
    final connectivityProvider = ConnectivityProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: connectivityProvider,
        child: const MaterialApp(
          home: ConnectivityBannerWrapper(
            child: Scaffold(
              body: Center(child: Text('Main App Content')),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Initially online: Banner is hidden off-screen with opacity 0.0
    expect(find.text('Main App Content'), findsOneWidget);
    final initialOpacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(initialOpacity.opacity, 0.0);
    final initialSlide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
    expect(initialSlide.offset, const Offset(0, -1.3));

    // Simulate going offline
    connectivityProvider.setMockStatus(false);
    await tester.pumpAndSettle();

    final offlineOpacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(offlineOpacity.opacity, 1.0);
    final offlineSlide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
    expect(offlineSlide.offset, Offset.zero);
    expect(find.text(AppStrings.pleaseCheckInternetConnection), findsOneWidget);
    expect(find.text(AppStrings.checkInternetSubtitle), findsOneWidget);
    expect(find.text(AppStrings.retry), findsOneWidget);

    // Simulate reconnecting
    connectivityProvider.setMockStatus(true);
    await tester.pump();

    expect(find.text(AppStrings.backOnline), findsOneWidget);

    // After 3 seconds, the "Back Online" pill should dismiss automatically
    await tester.pump(const Duration(seconds: 4));
    final finalOpacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(finalOpacity.opacity, 0.0);
  });

  testWidgets('EmptyState.offline renders offline icon, localized title, and retry button', (tester) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState.offline(
            onRetry: () => retried = true,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(AppStrings.noInternetConnection), findsOneWidget);
    expect(find.text(AppStrings.pleaseCheckInternetConnection), findsOneWidget);
    expect(find.text(AppStrings.retry), findsOneWidget);

    await tester.tap(find.text(AppStrings.retry));
    await tester.pump();
    expect(retried, isTrue);
  });
}

