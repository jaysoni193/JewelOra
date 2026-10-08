import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';

class AppLoader extends StatefulWidget {
  final double size;
  final String? message;
  final Color? color;

  const AppLoader({
    super.key,
    this.size = 56.0,
    this.message,
    this.color,
  });

  // ---------- Static Overlay API ----------
  static bool _isShowing = false;

  static void show(BuildContext context, {String message = 'Loading...'}) {
    if (_isShowing) return;
    _isShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLoader(size: 64),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      _isShowing = false;
    });
  }

  static void hide(BuildContext context) {
    if (!_isShowing) return;
    _isShowing = false;
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goldColor = widget.color ?? AppColors.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _JewelleryDiamondPainter(
                    progress: _controller.value,
                    primaryColor: goldColor,
                  ),
                );
              },
            ),
          ),
          if (widget.message != null && widget.message!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              widget.message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom painter that renders a faceted diamond with sparkling star lights
class _JewelleryDiamondPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color primaryColor;

  _JewelleryDiamondPainter({
    required this.progress,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // Glowing halo pulse
    final glowPulse = 0.5 + 0.5 * math.sin(progress * 2 * math.pi);
    final glowPaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.25 + 0.25 * glowPulse)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.25);
    canvas.drawCircle(center, w * 0.35, glowPaint);

    // Outer rotating sparkle satellites
    _drawSparkles(canvas, center, w * 0.45, progress);

    // Diamond Geometry Points
    final tableTopY = h * 0.22;
    final girdleY = h * 0.44;
    final bottomY = h * 0.85;

    final leftGirdle = Offset(w * 0.16, girdleY);
    final rightGirdle = Offset(w * 0.84, girdleY);
    final bottomPoint = Offset(w * 0.50, bottomY);
    final topLeftTable = Offset(w * 0.32, tableTopY);
    final topRightTable = Offset(w * 0.68, tableTopY);

    final linePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, w * 0.035)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final facetPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, w * 0.024)
      ..strokeCap = StrokeCap.round;

    // Fill subtle gold tint
    final fillPath = Path()
      ..moveTo(topLeftTable.dx, topLeftTable.dy)
      ..lineTo(topRightTable.dx, topRightTable.dy)
      ..lineTo(rightGirdle.dx, rightGirdle.dy)
      ..lineTo(bottomPoint.dx, bottomPoint.dy)
      ..lineTo(leftGirdle.dx, leftGirdle.dy)
      ..close();

    final fillPaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw Outer Outline
    canvas.drawPath(fillPath, linePaint);

    // Facet lines
    // Table bottom line
    canvas.drawLine(topLeftTable, leftGirdle, facetPaint);
    canvas.drawLine(topRightTable, rightGirdle, facetPaint);

    // Crown facets
    final midTable = Offset(w * 0.50, girdleY);
    canvas.drawLine(topLeftTable, midTable, facetPaint);
    canvas.drawLine(topRightTable, midTable, facetPaint);

    // Pavilion facets to bottom culet
    canvas.drawLine(midTable, bottomPoint, facetPaint);
    canvas.drawLine(Offset(w * 0.34, girdleY), bottomPoint, facetPaint);
    canvas.drawLine(Offset(w * 0.66, girdleY), bottomPoint, facetPaint);

    // Shimmering brilliance star in center
    final shimmerPhase = (progress * 2) % 1.0;
    final starOpacity = (math.sin(shimmerPhase * math.pi)).abs();
    _drawBrillianceStar(canvas, center.translate(0, -h * 0.04), w * 0.16, starOpacity);
  }

  void _drawSparkles(Canvas canvas, Offset center, double radius, double progress) {
    const sparkleCount = 4;
    for (int i = 0; i < sparkleCount; i++) {
      final angle = progress * 2 * math.pi + (i * (2 * math.pi / sparkleCount));
      final dist = radius + 4 * math.sin((progress * 4 + i) * math.pi);
      final spCenter = Offset(
        center.dx + dist * math.cos(angle),
        center.dy + dist * math.sin(angle),
      );

      final pulse = (0.5 + 0.5 * math.sin((progress * 3 + i) * 2 * math.pi)).clamp(0.2, 1.0);
      final size = 4.0 * pulse;

      final spPaint = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.85 * pulse)
        ..style = PaintingStyle.fill;

      // Draw diamond sparkle 4-pointed star
      final starPath = Path()
        ..moveTo(spCenter.dx, spCenter.dy - size)
        ..quadraticBezierTo(spCenter.dx, spCenter.dy, spCenter.dx + size, spCenter.dy)
        ..quadraticBezierTo(spCenter.dx, spCenter.dy, spCenter.dx, spCenter.dy + size)
        ..quadraticBezierTo(spCenter.dx, spCenter.dy, spCenter.dx - size, spCenter.dy)
        ..quadraticBezierTo(spCenter.dx, spCenter.dy, spCenter.dx, spCenter.dy - size)
        ..close();

      canvas.drawPath(starPath, spPaint);
    }
  }

  void _drawBrillianceStar(Canvas canvas, Offset center, double size, double opacity) {
    if (opacity <= 0.05) return;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity.clamp(0.0, 0.95))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _JewelleryDiamondPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.primaryColor != primaryColor;
  }
}
