import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/theme/app_decoration.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final Border? border;
  final bool hasGlow;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.border,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = BorderRadius.circular(borderRadius ?? AppSizes.radiusLarge);

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: effectiveRadius,
        border: border ?? Border.all(color: AppColors.border, width: 1.0),
        boxShadow: AppDecoration.luxuryShadow,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          borderRadius: effectiveRadius,
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
