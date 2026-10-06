import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/errors/app_exception.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/empty_view.dart';
import 'package:jewel_ora/core/widgets/loading_view.dart';
import 'package:jewel_ora/models/cart_item_model.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/cart_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/providers/user_nav_provider.dart';
import 'package:jewel_ora/screens/user/product_detail_screen.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _clear(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Clear cart',
      message: 'Remove all items from your cart?',
      confirmText: 'Clear',
    );
    if (!ok || !context.mounted) return;

    final cart = context.read<CartProvider>();
    final success = await cart.clear();
    if (!context.mounted) return;
    if (!success) {
      showAppSnackBar(
        context,
        cart.errorMessage ?? AppStrings.somethingWentWrong,
        isError: true,
      );
    }
  }

  Future<void> _remove(
      BuildContext context,
      CartItemModel item,
      String name,
      ) async {
    final cart = context.read<CartProvider>();
    final ok = await cart.remove(item.productId);
    if (!context.mounted) return;

    if (!ok) {
      showAppSnackBar(
        context,
        cart.errorMessage ?? AppStrings.somethingWentWrong,
        isError: true,
      );
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$name removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => cart.restore(item),
          ),
        ),
      );
  }

  Future<void> _sendEnquiry(
      BuildContext context,
      List<({ProductModel product, int quantity})> lines,
      ) async {
    final phone = context.read<SettingsProvider>().settings.whatsappNumber;
    final name = context.read<AuthProvider>().user?.name ?? '';

    try {
      await WhatsAppService.open(
        phone: phone,
        message: WhatsAppService.buildCartMessage(lines, customerName: name),
      );
    } on AppException catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message, isError: true);
    }
  }

  void _openProduct(BuildContext context, String productId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: productId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final productsP = context.watch<ProductProvider>();
    final byId = {for (final p in productsP.products) p.id: p};

    // Split the cart into items we can send and items we cannot.
    final orderable = <({ProductModel product, int quantity})>[];
    var excluded = 0; // out of stock or deleted
    for (final item in cart.items) {
      final p = byId[item.productId];
      if (p != null && p.isAvailable) {
        orderable.add((product: p, quantity: item.quantity));
      } else {
        excluded++;
      }
    }
    final total = orderable.fold<double>(
      0,
          (sum, l) => sum + l.product.price * l.quantity,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              tooltip: 'Clear cart',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _clear(context),
            ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (cart.isLoading || productsP.isLoading) return const LoadingView();

          if (cart.items.isEmpty) {
            return EmptyView(
              message: 'Your cart is empty',
              icon: Icons.shopping_bag_outlined,
              actionLabel: 'Browse the shop',
              onAction: () => context
                  .read<UserNavProvider>()
                  .setIndex(UserNavProvider.shopTab),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final item = cart.items[i];
                    final p = byId[item.productId];

                    return Dismissible(
                      key: ValueKey(item.productId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white),
                      ),
                      onDismissed: (_) =>
                          _remove(context, item, p?.name ?? 'Item'),
                      child: p == null
                          ? _MissingTile(
                        onRemove: () =>
                            context.read<CartProvider>().remove(item.productId),
                      )
                          : _CartTile(
                        product: p,
                        quantity: item.quantity,
                        onTap: () => _openProduct(context, p.id),
                        onRemove: () => _remove(context, item, p.name),
                        onDecrease: () => cart.changeQuantity(
                            p.id, item.quantity - 1),
                        onIncrease: () => cart.changeQuantity(
                            p.id, item.quantity + 1),
                      ),
                    );
                  },
                ),
              ),

              // ---------- Summary and WhatsApp ----------
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (excluded > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '$excluded ${excluded == 1 ? 'item is' : 'items are'} '
                              'unavailable and not included below.',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.error),
                        ),
                      ),
                    Row(
                      children: [
                        const Text('Estimated total',
                            style: TextStyle(color: AppColors.textGrey)),
                        const Spacer(),
                        Text(
                          Formatters.price(total),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: orderable.isEmpty
                          ? null
                          : () => _sendEnquiry(context, orderable),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whatsapp,
                      ),
                      icon: const Icon(Icons.chat),
                      label: const Text('Send Enquiry on WhatsApp'),
                    ),
                  ],
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
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _CartTile({
    required this.product,
    required this.quantity,
    required this.onTap,
    required this.onRemove,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: p.firstImage.isEmpty
                      ? Container(
                    color: AppColors.primaryLight,
                    child: const Icon(Icons.image_outlined),
                  )
                      : CachedNetworkImage(
                    imageUrl: ImageUrl.optimized(p.firstImage, width: 240),
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                    const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        InkWell(
                          onTap: onRemove,
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(Icons.close,
                                size: 18, color: AppColors.textGrey),
                          ),
                        ),
                      ],
                    ),
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
                      Text(
                        Formatters.price(p.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _QtyButton(
                            icon: Icons.remove,
                            onTap: quantity > 1 ? onDecrease : null,
                          ),
                          SizedBox(
                            width: 36,
                            child: Text(
                              '$quantity',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ),
                          _QtyButton(
                            icon: Icons.add,
                            onTap: quantity < CartProvider.maxQuantity
                                ? onIncrease
                                : null,
                          ),
                          const Spacer(),
                          Text(
                            Formatters.price(p.price * quantity),
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
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
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.textDark : AppColors.border,
        ),
      ),
    );
  }
}

/// Shown when the product was deleted by the admin.
class _MissingTile extends StatelessWidget {
  final VoidCallback onRemove;
  const _MissingTile({required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.search_off, color: AppColors.textGrey),
        title: const Text('This product is no longer available'),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onRemove,
        ),
      ),
    );
  }
}