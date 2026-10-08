import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';

enum AppButtonType { primary, secondary, outlined, text }

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final double? width;

  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.width,
  });

  const AppButton.outlined({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.width,
  }) : type = AppButtonType.outlined;

  const AppButton.secondary({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.width,
  }) : type = AppButtonType.secondary;

  const AppButton.text({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.width,
  }) : type = AppButtonType.text;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? AppSizes.buttonHeight;
    final isEnabled = onPressed != null && !isLoading;

    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == AppButtonType.outlined || type == AppButtonType.text
                ? AppColors.primaryDark
                : Colors.white,
          ),
        ),
      );
    } else {
      childContent = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 19),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    Widget buttonWidget;

    switch (type) {
      case AppButtonType.primary:
        buttonWidget = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: foregroundColor ?? Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
            elevation: isEnabled ? 2 : 0,
            shadowColor: AppColors.primary.withValues(alpha: 0.35),
            minimumSize: Size(isFullWidth ? double.infinity : (width ?? 0), effectiveHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
          child: childContent,
        );
        break;

      case AppButtonType.secondary:
        buttonWidget = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.surfaceVariant,
            foregroundColor: foregroundColor ?? AppColors.textDark,
            elevation: 0,
            minimumSize: Size(isFullWidth ? double.infinity : (width ?? 0), effectiveHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
          child: childContent,
        );
        break;

      case AppButtonType.outlined:
        buttonWidget = OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? AppColors.primaryDark,
            side: BorderSide(
              color: isEnabled
                  ? (foregroundColor ?? AppColors.primary)
                  : AppColors.border,
              width: 1.2,
            ),
            minimumSize: Size(isFullWidth ? double.infinity : (width ?? 0), effectiveHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
          child: childContent,
        );
        break;

      case AppButtonType.text:
        buttonWidget = TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor ?? AppColors.primaryDark,
            minimumSize: Size(isFullWidth ? double.infinity : (width ?? 0), effectiveHeight),
          ),
          child: childContent,
        );
        break;
    }

    return buttonWidget;
  }
}
