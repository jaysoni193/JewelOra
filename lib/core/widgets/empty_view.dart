import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';

class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyView({
    super.key,
    this.message = AppStrings.noData,
    this.icon = Icons.diamond_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: message,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}