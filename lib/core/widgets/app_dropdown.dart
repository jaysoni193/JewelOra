import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final bool enabled;

  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.hint,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveValue =
        items.any((item) => item.value == value) ? value : null;

    return DropdownButtonFormField<T>(
      isExpanded: true,
      initialValue: effectiveValue,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          key: item.key,
          value: item.value,
          enabled: item.enabled,
          alignment: item.alignment,
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: item.child,
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.textGrey),
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textDark,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      ),
      dropdownColor: AppColors.surface,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: AppColors.textGrey)
            : null,
        enabled: enabled,
      ),
    );
  }
}
