import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';

class FavoriteButton extends StatelessWidget {
  final String productId;
  const FavoriteButton({super.key, required this.productId});

  Future<void> _toggle(BuildContext context) async {
    final wishlist = context.read<WishlistProvider>();
    final ok = await wishlist.toggle(productId);
    if (!ok && context.mounted) {
      showAppSnackBar(
        context,
        wishlist.errorMessage ?? AppStrings.somethingWentWrong,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds only when THIS product's heart changes.
    final isFav = context.select<WishlistProvider, bool>(
          (w) => w.isFavorite(productId),
    );

    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _toggle(context),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: isFav ? AppColors.error : AppColors.textGrey,
          ),
        ),
      ),
    );
  }
}