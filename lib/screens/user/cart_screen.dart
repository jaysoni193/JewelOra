import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/errors/app_exception.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/models/enquiry_model.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/cart_provider.dart';
import 'package:jewel_ora/providers/enquiry_provider.dart';
import 'package:jewel_ora/providers/metal_rate_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/providers/user_nav_provider.dart';
import 'package:jewel_ora/screens/user/enquiry_history_screen.dart';
import 'package:jewel_ora/screens/user/product_detail_screen.dart';
import 'package:jewel_ora/services/stats_service.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _sendEnquiry(
    BuildContext context,
    List<({ProductModel product, int quantity, String? size, double price})> items,
  ) async {
    final settings = context.read<SettingsProvider>().settings;
    final user = context.read<AuthProvider>().user;
    final name = user?.name ?? '';

    // Record stats for each product
    for (final i in items) {
      StatsService.recordEnquiry(i.product.id);
    }

    final total = items.fold(0.0, (sum, i) => sum + (i.price * i.quantity));

    // Record Enquiry in history
    if (user != null) {
      context.read<EnquiryProvider>().recordEnquiry(
        EnquiryModel(
          id: '',
          userId: user.uid,
          userName: user.name,
          userPhone: user.phone,
          userEmail: user.email,
          items: items
              .map(
                (i) => EnquiryItemModel(
                  productId: i.product.id,
                  productName: i.product.name,
                  productPrice: i.price,
                  productImage: i.product.firstImage,
                  quantity: i.quantity,
                  size: i.size,
                ),
              )
              .toList(),
          totalAmount: total,
          message: 'Cart enquiry for ${items.length} items',
          status: 'submitted',
          createdAt: DateTime.now(),
        ),
      );
    }

    try {
      await WhatsAppService.open(
        phone: settings.whatsappNumber,
        message: WhatsAppService.buildCartMessage(
          items.map((i) => (product: i.product, quantity: i.quantity, size: i.size, price: i.price)).toList(),
          customerName: name,
        ),
      );
    } on AppException catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final productsP = context.watch<ProductProvider>();
    final ratesP = context.watch<MetalRateProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.shoppingBag),
        actions: [
          IconButton(
            tooltip: 'My Enquiries & Quotes',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EnquiryHistoryScreen()),
            ),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (cart.isLoading && cart.items.isEmpty) {
            return const Center(child: AppLoader(size: 50));
          }

          if (cart.items.isEmpty) {
            return EmptyState(
              title: AppStrings.cartEmpty,
              subtitle: AppStrings.cartEmptySubtitle,
              icon: Icons.shopping_bag_outlined,
              actionLabel: AppStrings.exploreCollection,
              onAction: () => context.read<UserNavProvider>().setIndex(UserNavProvider.shopTab),
            );
          }

          // Precompute orderable items and total upfront so Estimated Total and Send button are never zero/disabled
          final orderable = <({ProductModel product, int quantity, String? size, double price})>[];
          var excluded = 0;

          for (final item in cart.items) {
            final product = productsP.findById(item.productId);
            if (product != null) {
              if (product.isAvailable) {
                final price = product.getEffectivePrice(ratesP.rates);
                orderable.add((
                  product: product,
                  quantity: item.quantity,
                  size: item.size,
                  price: price,
                ));
              } else {
                excluded++;
              }
            }
          }

          final estimatedTotal = orderable.fold(0.0, (sum, i) => sum + (i.price * i.quantity));

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: cart.items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final item = cart.items[i];
                    final product = productsP.findById(item.productId);

                    if (product == null) {
                      return _MissingTile(onRemove: () => cart.remove(item.productId));
                    }

                    final effectivePrice = product.getEffectivePrice(ratesP.rates);

                    return _CartTile(
                      product: product,
                      effectivePrice: effectivePrice,
                      quantity: item.quantity,
                      size: item.size,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(productId: product.id),
                        ),
                      ),
                      onRemove: () => cart.remove(product.id),
                      onDecrease: () => cart.changeQuantity(product.id, item.quantity - 1),
                      onIncrease: () => cart.changeQuantity(product.id, item.quantity + 1),
                    );
                  },
                ),
              ),

              // Bottom Checkout / Enquiry Bar
              Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: const Border(top: BorderSide(color: AppColors.border)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (excluded > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '$excluded ${excluded == 1 ? 'item is' : 'items are'} '
                            'unavailable and not included in enquiry.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.estimatedTotal,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            Formatters.price(estimatedTotal),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppButton(
                        title: AppStrings.sendEnquiryWhatsApp,
                        icon: Icons.chat_rounded,
                        backgroundColor: AppColors.whatsapp,
                        onPressed: orderable.isEmpty
                            ? null
                            : () => _sendEnquiry(context, orderable),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final ProductModel product;
  final double effectivePrice;
  final int quantity;
  final String? size;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _CartTile({
    required this.product,
    required this.effectivePrice,
    required this.quantity,
    this.size,
    required this.onTap,
    required this.onRemove,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 82,
              height: 82,
              child: p.firstImage.isEmpty
                  ? Container(
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.diamond_outlined, color: AppColors.primary),
                    )
                  : CachedNetworkImage(
                      imageUrl: ImageUrl.optimized(p.firstImage, width: 250),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceVariant,
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image_outlined),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          height: 1.25,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: onRemove,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close_rounded, size: 18, color: AppColors.textGrey),
                      ),
                    ),
                  ],
                ),
                if (size != null && size!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Size: $size',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                if (!p.isAvailable)
                  const Text(
                    'Out of stock',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else ...[
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Text(
                        Formatters.price(effectivePrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      if (p.hasDiscount)
                        Text(
                          Formatters.price(p.mrp!),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _QtyButton(
                        icon: Icons.remove_rounded,
                        onTap: quantity > 1 ? onDecrease : null,
                      ),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '$quantity',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _QtyButton(
                        icon: Icons.add_rounded,
                        onTap: quantity < CartProvider.maxQuantity ? onIncrease : null,
                      ),
                      const Spacer(),
                      Text(
                        Formatters.price(p.price * quantity),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: enabled ? AppColors.surfaceVariant : Colors.transparent,
          border: Border.all(
            color: enabled ? AppColors.border : AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.textDark : AppColors.textLight,
        ),
      ),
    );
  }
}

class _MissingTile extends StatelessWidget {
  final VoidCallback onRemove;
  const _MissingTile({required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        leading: const Icon(Icons.search_off_rounded, color: AppColors.textGrey),
        title: const Text('This piece is no longer available'),
        trailing: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: onRemove,
        ),
      ),
    );
  }
}