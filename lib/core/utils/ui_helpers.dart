import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';

void showAppSnackBar(
    BuildContext context,
    String message, {
      bool isError = false,
    }) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
}

/// Shows a Yes/No dialog. Returns true if the user confirms.
Future<bool> showConfirmDialog(
    BuildContext context, {
      required String title,
      required String message,
      String confirmText = 'Yes',
    }) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}