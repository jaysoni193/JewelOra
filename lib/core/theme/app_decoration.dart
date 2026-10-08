import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';

class AppDecoration {
  AppDecoration._();

  // Subtle Modern Card Shadow (Clean CaratLane / GIVA style)
  static List<BoxShadow> get luxuryShadow => [
    BoxShadow(
      color: const Color(0xFF1D1625).withValues(alpha: 0.04),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.03),
      offset: const Offset(0, 1),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.25),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // Card Decoration
  static BoxDecoration cardDecoration({
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
  }) =>
      BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusLarge),
        border: border ?? Border.all(color: AppColors.border, width: 1.0),
        boxShadow: luxuryShadow,
      );

  // Modern Halo for circular elements/avatars (Soft Lilac / Plum halo)
  static BoxDecoration goldHaloDecoration = BoxDecoration(
    shape: BoxShape.circle,
    gradient: const LinearGradient(
      colors: [Color(0xFFF7EFFB), Color(0xFFEDE2F5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border.all(color: AppColors.borderAccent.withValues(alpha: 0.8), width: 1.5),
  );

  static BoxDecoration modernHaloDecoration = goldHaloDecoration;
}
