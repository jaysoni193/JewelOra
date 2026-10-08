import 'package:flutter/material.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      title: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      type: AppButtonType.primary,
    );
  }
}