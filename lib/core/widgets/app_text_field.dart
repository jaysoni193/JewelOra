import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.focusNode,
    this.readOnly = false,
    this.enabled = true,
    this.onChanged,
    this.onTap,
    this.textInputAction,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    Widget? effectiveSuffix;
    if (widget.isPassword) {
      effectiveSuffix = IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textGrey,
          size: 20,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    } else if (widget.suffixIcon != null) {
      effectiveSuffix = widget.suffixIcon;
    }

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      textInputAction: widget.textInputAction,
      style: TextStyle(
        fontSize: 15,
        color: widget.enabled ? AppColors.textDark : AppColors.textGrey,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 20, color: AppColors.textGrey)
            : null,
        suffixIcon: effectiveSuffix,
      ),
    );
  }
}