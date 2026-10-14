import 'package:flutter/material.dart';

/// Screen classification and responsive helper for phones, foldables, and tablets.
class Responsive {
  Responsive._();

  static const double smallPhoneBreakpoint = 360.0;
  static const double foldBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double maxContentWidth = 1100.0;

  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < smallPhoneBreakpoint;

  static bool isFoldable(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= foldBreakpoint && w < tabletBreakpoint;
  }

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  /// Returns 2 columns for normal phones, 3 for foldables / mini tablets, and 4 for full tablets
  static int gridColumns(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= tabletBreakpoint) return 4;
    if (w >= foldBreakpoint) return 3;
    return 2;
  }

  /// Responsive card aspect ratio for product grids
  static double productCardAspectRatio(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= tabletBreakpoint) return 0.72;
    if (w >= foldBreakpoint) return 0.68;
    if (w < smallPhoneBreakpoint) return 0.62;
    return 0.65;
  }

  /// Responsive admin menu columns
  static int adminGridColumns(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= tabletBreakpoint) return 4;
    if (w >= foldBreakpoint) return 3;
    return 2;
  }

  /// Horizontal padding adapted to screen width
  static double horizontalPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= tabletBreakpoint) return 32.0;
    if (w >= foldBreakpoint) return 24.0;
    if (w < smallPhoneBreakpoint) return 12.0;
    return 16.0;
  }
}

/// Extension for convenient context-based responsive calls
extension ResponsiveContext on BuildContext {
  bool get isSmallPhone => Responsive.isSmallPhone(this);
  bool get isFoldable => Responsive.isFoldable(this);
  bool get isTablet => Responsive.isTablet(this);
  int get gridColumns => Responsive.gridColumns(this);
  double get responsiveHorizontalPadding => Responsive.horizontalPadding(this);

  T responsive<T>({
    required T phone,
    T? foldable,
    T? tablet,
  }) {
    if (isTablet && tablet != null) return tablet;
    if (isFoldable && foldable != null) return foldable;
    return phone;
  }
}

/// A wrapper that constrains content to a sensible max width and centers it on foldables and tablets
class ResponsiveContentWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveContentWrapper({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
