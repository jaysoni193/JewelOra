import 'package:flutter/material.dart';
import 'package:jewel_ora/core/widgets/app_bottom_sheet.dart';

/// AppDialog delegates all calls to [AppBottomSheet] so that all modal dialogs
/// are presented as clean, responsive common bottom sheets across the application.
class AppDialog {
  AppDialog._();

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
    IconData? icon,
  }) {
    return AppBottomSheet.confirm(
      context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: isDestructive,
      icon: icon,
    );
  }

  static Future<bool> delete(
    BuildContext context, {
    required String title,
    required String message,
    String? deleteText,
    String? confirmText,
  }) {
    return AppBottomSheet.delete(
      context,
      title: title,
      message: message,
      deleteText: deleteText,
      confirmText: confirmText,
    );
  }

  static Future<bool> logout(BuildContext context) {
    return AppBottomSheet.logout(context);
  }

  static Future<void> success(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return AppBottomSheet.success(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  static Future<void> error(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return AppBottomSheet.error(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }
}
