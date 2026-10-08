import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/helpers.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';

class FavoriteButton extends StatelessWidget {
  final String productId;
  final double size;

  const FavoriteButton({
    super.key,
    required this.productId,
    this.size = 18.0,
  });

  Future<void> _toggle(BuildContext context) async {
    AppHelpers.lightImpact();
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _toggle(context),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey<bool>(isFav),
                size: size,
                color: isFav ? AppColors.error : AppColors.textGrey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}