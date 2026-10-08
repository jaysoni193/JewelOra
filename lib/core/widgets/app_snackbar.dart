import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    Color bgColor = AppColors.surfaceDark;
    IconData icon = Icons.info_outline_rounded;
    Color iconColor = AppColors.primary;

    if (isError) {
      bgColor = AppColors.error;
      icon = Icons.error_outline_rounded;
      iconColor = Colors.white;
    } else if (isSuccess) {
      bgColor = AppColors.success;
      icon = Icons.check_circle_outline_rounded;
      iconColor = Colors.white;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          action: action,
          content: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) {
    show(context, message, isSuccess: true);
  }

  static void error(BuildContext context, String message) {
    show(context, message, isError: true);
  }

  static void info(BuildContext context, String message) {
    show(context, message);
  }

  static void showSuccess(BuildContext context, String message) => success(context, message);
  static void showError(BuildContext context, String message) => error(context, message);
  static void showWarning(BuildContext context, String message) => show(context, message);
  static void showInfo(BuildContext context, String message) => info(context, message);
}
