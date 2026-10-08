import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_images.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/utils/image_url.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? logoUrl;
  final bool showLogo;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const AppAppBar({
    super.key,
    this.title,
    this.logoUrl,
    this.showLogo = false,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    Widget? titleWidget;

    if (showLogo) {
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (logoUrl != null && logoUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: ImageUrl.optimized(logoUrl!, width: 140),
              height: 32,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => Image.asset(
                AppImages.logo,
                height: 32,
                fit: BoxFit.contain,
              ),
            )
          else
            Image.asset(
              AppImages.logo,
              height: 32,
              fit: BoxFit.contain,
            ),
          if (title != null && title!.isNotEmpty) ...[
            const SizedBox(width: 10),
            Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      );
    } else if (title != null) {
      titleWidget = Text(
        title!,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      );
    }

    return AppBar(
      title: titleWidget,
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      bottom: bottom,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        AppSizes.appBarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
