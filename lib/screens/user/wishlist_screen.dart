import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/core/widgets/product_card.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/providers/wishlist_provider.dart';
import 'package:jewel_ora/screens/user/product_detail_screen.dart';
import 'package:provider/provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final productsP = context.watch<ProductProvider>();
    final categoriesP = context.watch<CategoryProvider>();

    final activeIds = categoriesP.activeCategories.map((c) => c.id).toSet();
    final byId = {for (final p in productsP.products) p.id: p};

    // Deleted products and products in hidden categories are skipped.
    final products = <ProductModel>[];
    for (final item in wishlist.items) {
      final p = byId[item.productId];
      if (p != null && activeIds.contains(p.categoryId)) products.add(p);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Wishlist')),
      body: Builder(
        builder: (context) {
          if (wishlist.isLoading ||
              productsP.isLoading ||
              categoriesP.isLoading) {
            return const Center(child: AppLoader(size: 50));
          }
          if (products.isEmpty) {
            return EmptyState(
              title: 'No favourites yet',
              subtitle: 'Tap the heart icon on any piece you love to save it to your wishlist.',
              icon: Icons.favorite_border_rounded,
              actionLabel: 'Browse Collection',
              onAction: () => Navigator.of(context).pop(),
            );
          }
          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, i) => ProductCard(
              product: products[i],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(productId: products[i].id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}