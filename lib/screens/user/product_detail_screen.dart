import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/errors/app_exception.dart';
import 'package:jewel_ora/core/storage/local_storage.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/core/widgets/favorite_button.dart';
import 'package:jewel_ora/core/widgets/view_tracker.dart';
import 'package:jewel_ora/models/enquiry_model.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/cart_provider.dart';
import 'package:jewel_ora/providers/enquiry_provider.dart';
import 'package:jewel_ora/providers/metal_rate_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/providers/ring_size_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/models/ar_try_on_model.dart';
import 'package:jewel_ora/screens/user/ar_try_on_screen.dart';
import 'package:jewel_ora/screens/user/widgets/diamond_guide_sheet.dart';
import 'package:jewel_ora/screens/user/widgets/drop_hint_dialog.dart';
import 'package:jewel_ora/screens/user/widgets/jewellery_care_dialog.dart';
import 'package:jewel_ora/screens/user/widgets/jewellery_vault_sheet.dart';
import 'package:jewel_ora/screens/user/widgets/old_gold_calculator_dialog.dart';
import 'package:jewel_ora/screens/user/widgets/product_customizer_widget.dart';
import 'package:jewel_ora/screens/user/widgets/product_image_slider.dart';
import 'package:jewel_ora/screens/user/widgets/ring_size_guide_dialog.dart';
import 'package:jewel_ora/services/share_service.dart';
import 'package:jewel_ora/services/stats_service.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  String _selectedMetalTone = 'Yellow Gold';
  String _selectedPurity = '18K';
  String _selectedDiamondType = 'Natural (SI-IJ)';
  bool _customizerInitialized = false;

  @override
  void initState() {
    super.initState();
    // Record recently viewed (0 Firestore read cost)
    LocalStorage.instance.addRecentlyViewed(widget.productId);
  }

  void _initCustomizer(ProductModel p) {
    if (_customizerInitialized) return;
    _customizerInitialized = true;

    // Default metal tone based on material
    final lowerMat = '${p.material} ${p.name}'.toLowerCase();
    if (lowerMat.contains('rose')) {
      _selectedMetalTone = 'Rose Gold';
    } else if (lowerMat.contains('white')) {
      _selectedMetalTone = 'White Gold';
    } else if (ProductCustomizerHelper.isSilver(p)) {
      _selectedMetalTone = 'Sterling Silver';
    } else {
      _selectedMetalTone = 'Yellow Gold';
    }

    // Default purity based on metalType
    if (ProductCustomizerHelper.isSilver(p)) {
      _selectedPurity = '925 Silver';
    } else if (p.metalType == 'gold_22k' || lowerMat.contains('22k') || lowerMat.contains('22 karat')) {
      _selectedPurity = '22K';
    } else if (p.metalType == 'gold_14k' || lowerMat.contains('14k') || lowerMat.contains('14 karat')) {
      _selectedPurity = '14K';
    } else if (p.metalType == 'gold_24k' || lowerMat.contains('24k')) {
      _selectedPurity = '24K';
    } else {
      _selectedPurity = '18K';
    }
  }

  String _buildCustomizationSummary(ProductModel p) {
    final parts = <String>[];
    if (_selectedSize != null && _selectedSize!.isNotEmpty) {
      parts.add('Size: $_selectedSize');
    }
    parts.add('$_selectedPurity $_selectedMetalTone');
    if (ProductCustomizerHelper.hasDiamonds(p)) {
      parts.add(_selectedDiamondType);
    }
    return parts.join(' • ');
  }

  Future<void> _chatOnWhatsApp(
    BuildContext context,
    ProductModel p,
    double effectivePrice,
  ) async {
    final phone = context.read<SettingsProvider>().settings.whatsappNumber;
    final user = context.read<AuthProvider>().user;
    final name = user?.name ?? '';
    final customSpec = _buildCustomizationSummary(p);
    StatsService.recordEnquiry(p.id);

    // Record in Enquiry History
    if (user != null) {
      context.read<EnquiryProvider>().recordEnquiry(
        EnquiryModel(
          id: '',
          userId: user.uid,
          userName: user.name,
          userPhone: user.phone,
          userEmail: user.email,
          items: [
            EnquiryItemModel(
              productId: p.id,
              productName: p.name,
              productPrice: effectivePrice,
              productImage: p.firstImage,
              quantity: 1,
              size: customSpec,
            ),
          ],
          totalAmount: effectivePrice,
          message: 'Enquired about ${p.name} ($customSpec)',
          status: 'submitted',
          createdAt: DateTime.now(),
        ),
      );
    }

    try {
      await WhatsAppService.open(
        phone: phone,
        message: WhatsAppService.buildProductMessage(
          p,
          customerName: name,
          selectedSize: customSpec,
        ),
      );
    } on AppException catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message, isError: true);
    }
  }

  Future<void> _share(BuildContext context, ProductModel p) async {
    final settings = context.read<SettingsProvider>().settings;

    try {
      await ShareService.shareProduct(
        p,
        shopName: settings.appName,
        whatsappNumber: settings.whatsappNumber,
      );
    } on AppException catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message, isError: true);
    }
  }

  Future<void> _addToCart(BuildContext context, ProductModel p) async {
    final cart = context.read<CartProvider>();
    final customSpec = _buildCustomizationSummary(p);
    final quantity = await cart.add(p.id, size: customSpec);
    if (!context.mounted) return;

    if (quantity == null) {
      showAppSnackBar(
        context,
        cart.errorMessage ?? AppStrings.somethingWentWrong,
        isError: true,
      );
    } else {
      showAppSnackBar(
        context,
        quantity == 1
            ? 'Added ($customSpec) to your bag'
            : 'Updated quantity to $quantity in your bag',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productP = context.watch<ProductProvider>();
    final ratesP = context.watch<MetalRateProvider>();
    final p = productP.findById(widget.productId);

    if (productP.isLoading && p == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: AppLoader(size: 50)),
      );
    }

    if (p == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: const EmptyState(
          title: 'Piece Not Found',
          subtitle: 'This item might have been removed or is no longer available.',
          icon: Icons.diamond_outlined,
        ),
      );
    }

    _initCustomizer(p);
    final effectivePrice = ProductCustomizerHelper.calculateCustomPrice(
      product: p,
      rates: ratesP.rates,
      selectedPurity: _selectedPurity,
      selectedDiamondType: _selectedDiamondType,
    );
    final ringSizer = context.watch<RingSizeProvider>();
    final sizes = p.effectiveSizes;
    if (_selectedSize == null && sizes.isNotEmpty) {
      if (ringSizer.savedRingSize != null) {
        final match = sizes.firstWhere(
          (s) => s == ringSizer.savedRingSize || s.contains(ringSizer.savedRingSize!),
          orElse: () => sizes.first,
        );
        _selectedSize = match;
      } else {
        _selectedSize = sizes.first;
      }
    }

    final specs = <(String, String)>[
      if (p.categoryName.isNotEmpty) ('Category', p.categoryName),
      ('Customized Color', _selectedMetalTone),
      ('Purity (Karat)', _selectedPurity),
      if (ProductCustomizerHelper.hasDiamonds(p)) ('Diamond Quality', _selectedDiamondType),
      if (p.material.isNotEmpty) ('Base Material', p.material),
      if (p.weight.isNotEmpty) ('Gross Weight', p.weight),
      if (p.metalWeight != null) ('Net Metal Weight', '${p.metalWeight} g'),
      if (p.makingCharges != null)
        ('Making Charges', Formatters.price(p.makingCharges!)),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (ArTryOnItem.fromProduct(p) != null)
            IconButton(
              tooltip: AppStrings.arVirtualTryOn,
              icon: const Icon(Icons.face_retouching_natural_rounded, color: AppColors.accentGold),
              onPressed: () => ArTryOnScreen.open(context, product: p),
            ),
          IconButton(
            tooltip: AppStrings.dropAHint,
            icon: const Icon(Icons.card_giftcard_rounded, color: AppColors.accent),
            onPressed: () => DropHintSheet.show(
              context,
              product: p,
              effectivePrice: effectivePrice,
              selectedSize: _buildCustomizationSummary(p),
            ),
          ),
          FavoriteButton(productId: p.id),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _share(context, p),
          ),
        ],
      ),
      body: Stack(
        children: [
          ViewTracker(productId: p.id),
          ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              // Product Images
              ProductImageSlider(images: p.images),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (p.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'IN STOCK',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'OUT OF STOCK',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (p.offerTag != null && p.offerTag!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            p.offerTag!.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (p.useDynamicRate)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt_rounded, size: 14, color: AppColors.primary),
                              SizedBox(width: 2),
                              Text(
                                'Live Rate Priced',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Product Name
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price & Discount Wrap
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      Text(
                        Formatters.price(effectivePrice),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      if (p.hasDiscount) ...[
                        Text(
                          Formatters.price(p.mrp!),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'Save ${Formatters.price(p.savings)} (${p.discountPercent}% OFF)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (ArTryOnItem.fromProduct(p) != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentGold.withValues(alpha: 0.15),
                            AppColors.primary.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        border: Border.all(
                          color: AppColors.accentGold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.face_retouching_natural_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AR Virtual Try-On',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Try this piece live on your face & neck using camera mirror',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                              ),
                            ),
                            icon: const Icon(Icons.videocam_rounded, size: 16),
                            label: const Text('Try Live', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () => ArTryOnScreen.open(context, product: p),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Drop a Hint Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 0.08),
                          AppColors.primary.withValues(alpha: 0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.card_giftcard_rounded,
                            color: AppColors.accent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.dropAHint,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppStrings.dropAHintSubtitle,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.send_rounded, size: 13),
                          label: const Text(
                            'Hint ✨',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () => DropHintSheet.show(
                            context,
                            product: p,
                            effectivePrice: effectivePrice,
                            selectedSize: _buildCustomizationSummary(p),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Size Selection Chips
                  if (sizes.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.selectSize,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => RingSizeGuideSheet.show(context),
                          icon: const Icon(Icons.straighten_rounded, size: 15),
                          label: Text(
                            ringSizer.savedRingSize != null
                                ? '${AppStrings.ringSizeGuide} (My Size: ${ringSizer.savedRingSize})'
                                : AppStrings.ringSizeGuide,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: sizes.map((size) {
                        final isSel = _selectedSize == size;
                        return ChoiceChip(
                          label: Text(size),
                          selected: isSel,
                          onSelected: (_) => setState(() => _selectedSize = size),
                          selectedColor: AppColors.primaryLight,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? AppColors.primaryDark : AppColors.textDark,
                          ),
                          side: BorderSide(
                            color: isSel ? AppColors.primary : AppColors.border,
                            width: isSel ? 1.2 : 1.0,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Interactive Customizer (Metal Tone, Purity & Diamonds)
                  ProductCustomizerWidget(
                    product: p,
                    rates: ratesP.rates,
                    selectedMetalTone: _selectedMetalTone,
                    selectedPurity: _selectedPurity,
                    selectedDiamondType: _selectedDiamondType,
                    onMetalToneChanged: (val) => setState(() => _selectedMetalTone = val),
                    onPurityChanged: (val) => setState(() => _selectedPurity = val),
                    onDiamondTypeChanged: (val) => setState(() => _selectedDiamondType = val),
                  ),
                  const SizedBox(height: 20),

                  // Specifications Card
                  if (specs.isNotEmpty) ...[
                    Text(
                      AppStrings.specifications,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Column(
                        children: [
                          for (var i = 0; i < specs.length; i++) ...[
                            if (i > 0) const Divider(height: 18),
                            _SpecRow(label: specs[i].$1, value: specs[i].$2),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Description
                  if (p.description.isNotEmpty) ...[
                    Text(
                      AppStrings.description,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.description,
                      style: const TextStyle(
                        height: 1.6,
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Authenticity & Care Tips
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _TrustBadge(icon: Icons.verified_outlined, title: AppStrings.certified100),
                            _TrustBadge(icon: Icons.autorenew_rounded, title: AppStrings.lifetimeExchange),
                            _TrustBadge(icon: Icons.local_shipping_outlined, title: AppStrings.insuredDelivery),
                          ],
                        ),
                        const Divider(height: 16),
                        InkWell(
                          onTap: () => JewelleryVaultSheet.show(context, initialTab: 1),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
                                SizedBox(width: 6),
                                Text(
                                  'Verify Hallmark & Certificate Authenticity 🛡️',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 14),
                        InkWell(
                          onTap: () => JewelleryCareSheet.show(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  AppStrings.careAndCleaningTips,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 14),
                        InkWell(
                          onTap: () => OldGoldCalculatorSheet.show(context),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.scale_rounded, size: 16, color: AppColors.accent),
                                SizedBox(width: 6),
                                Text(
                                  'Exchange Old Gold Against This Piece ⚖️',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (ProductCustomizerHelper.hasDiamonds(p)) ...[
                          const Divider(height: 14),
                          InkWell(
                            onTap: () => DiamondGuideSheet.show(context),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.diamond_outlined, size: 16, color: AppColors.accent),
                                  SizedBox(width: 6),
                                  Text(
                                    'Diamond 4Cs & Solitaire Grading Guide 💎',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ],
      ),

      // Pinned Action Buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  title: AppStrings.addToCart,
                  icon: Icons.shopping_bag_outlined,
                  onPressed: p.isAvailable ? () => _addToCart(context, p) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  title: AppStrings.whatsappEnquiry,
                  icon: Icons.chat_rounded,
                  backgroundColor: AppColors.whatsapp,
                  onPressed: () => _chatOnWhatsApp(context, p, effectivePrice),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String title;

  const _TrustBadge({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}
