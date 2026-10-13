import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/errors/app_exception.dart';
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
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/screens/user/widgets/product_image_slider.dart';
import 'package:jewel_ora/services/share_service.dart';
import 'package:jewel_ora/services/stats_service.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  Future<void> _chatOnWhatsApp(
    BuildContext context,
    ProductModel p,
    double effectivePrice,
  ) async {
    final phone = context.read<SettingsProvider>().settings.whatsappNumber;
    final user = context.read<AuthProvider>().user;
    final name = user?.name ?? '';
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
            ),
          ],
          totalAmount: effectivePrice,
          message: 'Enquired about ${p.name}',
          status: 'submitted',
          createdAt: DateTime.now(),
        ),
      );
    }

    try {
      await WhatsAppService.open(
        phone: phone,
        message: WhatsAppService.buildProductMessage(p, customerName: name),
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
    final quantity = await cart.add(p.id);
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
            ? 'Added to cart'
            : 'Added to cart (total $quantity in cart)',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final rates = context.watch<MetalRateProvider?>()?.rates;
    final p = productProvider.findById(productId);

    if (productProvider.isLoading && p == null) {
      return const Scaffold(
        body: Center(child: AppLoader()),
      );
    }

    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          title: 'Piece Not Found',
          subtitle: 'This item might have been archived or removed.',
          icon: Icons.diamond_outlined,
        ),
      );
    }

    final effectivePrice = p.getEffectivePrice(rates);

    final specs = <(String, String)>[
      if (p.categoryName.isNotEmpty) ('Category', p.categoryName),
      if (p.material.isNotEmpty) ('Material', p.material),
      if (p.weight.isNotEmpty) ('Weight', p.weight),
      if (p.metalType != null && p.metalType!.isNotEmpty)
        ('Metal Purity', p.metalType!.replaceAll('_', ' ').toUpperCase()),
      if (p.makingCharges != null && p.makingCharges! > 0)
        ('Making Charges', Formatters.price(p.makingCharges!)),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          p.categoryName.isNotEmpty ? p.categoryName : 'Jewellery Piece',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          FavoriteButton(productId: p.id),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _share(context, p),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          ViewTracker(productId: p.id),

          // Luxury Image Slider
          ProductImageSlider(images: p.images),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Offer Tag Banner (Diwali Sale, etc.)
                if (p.offerTag != null && p.offerTag!.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${p.offerTag!.toUpperCase()} SPECIAL OFFER',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Availability & Featured Badges
                Row(
                  children: [
                    if (!p.isAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'In Stock',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (p.isFeatured) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderAccent),
                          ),
                          child: const Text(
                            'Featured Piece',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      if (p.useDynamicRate) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
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
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Product Name
                Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),

                // Price & Discount Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      Formatters.price(effectivePrice),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (p.hasDiscount) ...[
                      const SizedBox(width: 10),
                      Text(
                        Formatters.price(p.mrp!),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textLight,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 10),
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
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),

                // Specifications Card
                if (specs.isNotEmpty) ...[
                  const Text(
                    'Specifications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                  const SizedBox(height: 24),
                ],

                // Authenticity & Trust Badges
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _TrustBadge(icon: Icons.verified_outlined, title: '100% Certified'),
                      _TrustBadge(icon: Icons.autorenew_rounded, title: 'Lifetime Exchange'),
                      _TrustBadge(icon: Icons.local_shipping_outlined, title: 'Insured Delivery'),
                    ],
                  ),
                ),
              ],
            ),
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
                  title: 'Add to Cart',
                  icon: Icons.shopping_bag_outlined,
                  onPressed: p.isAvailable ? () => _addToCart(context, p) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  title: 'Enquire on WhatsApp',
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
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textDark,
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
