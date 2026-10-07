import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/errors/app_exception.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/empty_view.dart';
import 'package:jewel_ora/core/widgets/loading_view.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/screens/user/widgets/product_image_slider.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/widgets/favorite_button.dart';
import '../../core/widgets/view_tracker.dart';
import '../../providers/cart_provider.dart';
import '../../services/share_service.dart';
import '../../services/stats_service.dart';

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
            ? const LoadingView()
            : const EmptyView(
                message: 'This product is no longer available',
                icon: Icons.search_off,
              ),
      );
    }

    final specs = <(String, String)>[
      ('Category', p.categoryName),
      ('Material', p.material),
      ('Weight', p.weight),
    ].where((s) => s.$2.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
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
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ViewTracker(productId: p.id),
          ProductImageSlider(images: p.images),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!p.isAvailable)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Out of stock',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Formatters.price(p.price),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),

                if (specs.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          for (var i = 0; i < specs.length; i++) ...[
                            if (i > 0) const SizedBox(height: 10),
                            _SpecRow(label: specs[i].$1, value: specs[i].$2),
                          ],
                        ],
                      ),
                    ),
                  ),

                if (p.description.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.description,
                    style: const TextStyle(
                      height: 1.5,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.textGrey,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Final price and availability are confirmed with the '
                        'shop on WhatsApp.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),

      // ---------- Pinned action buttons ----------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: p.isAvailable
                      ? () => _addToCart(context, p)
                      : null,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Add to Cart'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _chatOnWhatsApp(context, p),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.whatsapp,
                  ),
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat on WhatsApp'),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(color: AppColors.textGrey)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
