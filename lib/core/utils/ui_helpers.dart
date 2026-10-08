import 'package:flutter/material.dart';
import 'package:jewel_ora/core/widgets/app_dialog.dart';
import 'package:jewel_ora/core/widgets/app_snackbar.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  AppSnackbar.show(
    context,
    message,
    isError: isError,
    isSuccess: !isError,
  );
}

/// Shows a Yes/No dialog. Returns true if the user confirms.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Yes',
}) {
  return AppDialog.confirm(
    context,
    title: title,
    message: message,
    confirmText: confirmText,
  );
}