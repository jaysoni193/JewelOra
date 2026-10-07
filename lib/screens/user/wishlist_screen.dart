import 'package:flutter/material.dart';
import 'package:jewel_ora/core/widgets/empty_view.dart';
import 'package:jewel_ora/core/widgets/loading_view.dart';
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
      appBar: AppBar(title: const Text('My Wishlist')),
      body: Builder(
        builder: (_) {
          if (wishlist.isLoading ||
              productsP.isLoading ||
              categoriesP.isLoading) {
            return const LoadingView();
          }
          if (products.isEmpty) {
            return EmptyView(
              message: 'No favourites yet.\nTap the heart on any product.',
              icon: Icons.favorite_border,
              actionLabel: 'Go back',
              onAction: () => Navigator.of(context).pop(),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (_, i) => ProductCard(
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