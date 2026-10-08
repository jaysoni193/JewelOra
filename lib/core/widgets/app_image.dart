import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/utils/image_url.dart';

class AppImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool isLocal;
  final int? optimizeWidth;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.isLocal = false,
    this.optimizeWidth,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageContent;

    if (imageUrl.isEmpty) {
      imageContent = _buildErrorWidget();
    } else if (isLocal || !imageUrl.startsWith('http')) {
      imageContent = Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else {
      final effectiveUrl = optimizeWidth != null
          ? ImageUrl.optimized(imageUrl, width: optimizeWidth!)
          : imageUrl;

      imageContent = CachedNetworkImage(
        imageUrl: effectiveUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ?? _buildShimmerPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorWidget(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageContent,
      );
    }

    return imageContent;
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceVariant.withValues(alpha: 0.6),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: AppColors.textLight,
          size: 26,
        ),
      ),
    );
  }
}
