import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';

class AppDialog {
  AppDialog._();

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = AppStrings.cancel,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge),
          side: const BorderSide(color: AppColors.border),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        actionsPadding: const EdgeInsets.all(20),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 15, color: AppColors.textGrey, height: 1.4),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  title: cancelText,
                  height: 44,
                  onPressed: () => Navigator.pop(ctx, false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  title: confirmText,
                  height: 44,
                  backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
                  onPressed: () => Navigator.pop(ctx, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<bool> delete(
    BuildContext context, {
    required String title,
    required String message,
    String? deleteText,
    String confirmText = AppStrings.delete,
  }) {
    return confirm(
      context,
      title: title,
      message: message,
      confirmText: deleteText ?? confirmText,
      isDestructive: true,
    );
  }

  static Future<bool> logout(BuildContext context) {
    return confirm(
      context,
      title: AppStrings.logout,
      message: 'Are you sure you want to sign out?',
      confirmText: AppStrings.logout,
      isDestructive: true,
    );
  }

  static Future<void> success(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
            ),
            const SizedBox(height: 24),
            AppButton(
              title: buttonText,
              height: 44,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> error(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Close',
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 40),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
            ),
            const SizedBox(height: 24),
            AppButton(
              title: buttonText,
              height: 44,
              backgroundColor: AppColors.error,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}
