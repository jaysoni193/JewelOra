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
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/cart_provider.dart';
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

  Future<void> _chatOnWhatsApp(BuildContext context, ProductModel p) async {
    final phone = context.read<SettingsProvider>().settings.whatsappNumber;
    final name = context.read<AuthProvider>().user?.name ?? '';
    StatsService.recordEnquiry(p.id);
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
            : 'Added to cart ($quantity in your cart)',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsP = context.watch<ProductProvider>();
    final p = productsP.products.where((e) => e.id == productId).firstOrNull;

    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: productsP.isLoading
            ? const Center(child: AppLoader(size: 50))
            : const EmptyState(
                title: 'Product Unavailable',
                subtitle: 'This piece is no longer available in the boutique.',
                icon: Icons.diamond_outlined,
              ),
      );
    }

    final specs = <(String, String)>[
      ('Category', p.categoryName),
      ('Material', p.material),
      ('Weight', p.weight),
    ].where((s) => s.$2.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Boutique Details'),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _share(context, p),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FavoriteButton(productId: p.id),
          ),
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
                // Availability or Featured Badge
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

                // Price
                Text(
                  Formatters.price(p.price),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.4,
                  ),
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
                  const SizedBox(height: 20),
                ],

                // Trust & Inquiry note
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 20,
                        color: AppColors.primaryDark,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '100% Certified Authentic Jewellery. Final customization, sizing, and payment details are confirmed directly with our boutique via WhatsApp.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ---------- Pinned Action Buttons ----------
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
                  onPressed: () => _chatOnWhatsApp(context, p),
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
