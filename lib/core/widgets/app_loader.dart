import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';

class GlobalLoaderState {
  final bool isShowing;
  final String message;
  final String? subMessage;

  const GlobalLoaderState({
    this.isShowing = false,
    this.message = 'Loading...',
    this.subMessage,
  });
}

/// Global loader controller accessible anywhere across the app
class GlobalLoader {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final ValueNotifier<GlobalLoaderState> notifier =
      ValueNotifier<GlobalLoaderState>(const GlobalLoaderState());

  static bool get isShowing => notifier.value.isShowing;

  static void show({
    String message = 'Please wait...',
    String? subMessage,
  }) {
    notifier.value = GlobalLoaderState(
      isShowing: true,
      message: message,
      subMessage: subMessage,
    );
  }

  static void hide() {
    if (notifier.value.isShowing) {
      notifier.value = const GlobalLoaderState(isShowing: false);
    }
  }
}

/// Overlay that wraps MaterialApp to render the bespoke full-screen Jewellery loader
class GlobalLoaderOverlay extends StatelessWidget {
  final Widget child;

  const GlobalLoaderOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GlobalLoaderState>(
      valueListenable: GlobalLoader.notifier,
      builder: (context, state, _) {
        return Stack(
          children: [
            child,
            if (state.isShowing)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    builder: (context, animValue, _) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Luxury frosted glass backdrop
                          BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 6.0 * animValue,
                              sigmaY: 6.0 * animValue,
                            ),
                            child: Container(
                              color: const Color(0xFF14081E).withValues(
                                alpha: 0.55 * animValue,
                              ),
                            ),
                          ),
                          // Elevated glassmorphism card
                          Opacity(
                            opacity: animValue,
                            child: Transform.scale(
                              scale: 0.92 + (0.08 * animValue),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 30,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: AppColors.borderAccent
                                        .withValues(alpha: 0.65),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2E173E)
                                          .withValues(alpha: 0.28),
                                      blurRadius: 40,
                                      offset: const Offset(0, 16),
                                    ),
                                    BoxShadow(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.12),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Bespoke luxury diamond solitaire loader
                                    const AppLoader(size: 68),
                                    const SizedBox(height: 20),
                                    // Title message
                                    Text(
                                      state.message,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                        decoration: TextDecoration.none,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    if (state.subMessage != null &&
                                        state.subMessage!.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        state.subMessage!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textGrey,
                                          decoration: TextDecoration.none,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 14),
                                    // Subtle 3-dot luxury shimmer pulse
                                    _PulseDots(animValue: animValue),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Three small pulsing dots under the loader message
class _PulseDots extends StatelessWidget {
  final double animValue;
  const _PulseDots({required this.animValue});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == 1
                ? AppColors.accent
                : AppColors.primary.withValues(alpha: 0.45),
          ),
        );
      }),
    );
  }
}

/// The modern, high-fashion Jewellery Diamond & Orbit Loader
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

  // ---------- Static Overlay API (delegates to GlobalLoader) ----------
  static void show(BuildContext? context,
      {String message = 'Loading...', String? subMessage}) {
    GlobalLoader.show(message: message, subMessage: subMessage);
  }

  static void hide([BuildContext? context]) {
    GlobalLoader.hide();
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
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.color ?? AppColors.primary;
    final accent = AppColors.accent;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ModernJewelleryLoaderPainter(
                    progress: _controller.value,
                    primaryColor: primary,
                    accentColor: accent,
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
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                letterSpacing: 0.2,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Modern bespoke painter that renders:
/// 1. Pulsing ambient gemstone halo
/// 2. Dual counter-rotating eternity orbit rings
/// 3. Faceted brilliant-cut solitaire diamond with dynamic refraction shading
/// 4. Sweeping specular highlight (diamond fire)
/// 5. Sparkling star glints at diamond vertices
class _ModernJewelleryLoaderPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color primaryColor;
  final Color accentColor;

  _ModernJewelleryLoaderPainter({
    required this.progress,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Ambient Breathing Halo
    final pulse = 0.5 + 0.5 * math.sin(progress * 2 * math.pi);
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.16 + (0.14 * pulse))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.3);
    canvas.drawCircle(center, w * 0.36, glowPaint);

    // 2. Dual Orbiting Eternity Rings
    _drawOrbitRings(canvas, center, w);

    // 3. Faceted Brilliant Cut Solitaire Diamond in Center
    _drawBrilliantDiamond(canvas, center, w, h);

    // 4. Sparkling Star Flares (Glitter Glints)
    _drawSparkleStars(canvas, center, w);
  }

  void _drawOrbitRings(Canvas canvas, Offset center, double w) {
    final ringRadius = w * 0.44;
    final strokeWidth = math.max(1.5, w * 0.032);

    // Outer Clockwise Orbit Ring
    final outerAngle = progress * 2 * math.pi;
    final outerRect = Rect.fromCircle(center: center, radius: ringRadius);

    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        transform: GradientRotation(outerAngle),
        colors: [
          primaryColor.withValues(alpha: 0.05),
          primaryColor.withValues(alpha: 0.5),
          accentColor,
          Colors.white,
        ],
        stops: const [0.0, 0.45, 0.85, 1.0],
      ).createShader(outerRect);

    canvas.drawArc(outerRect, outerAngle, 1.6 * math.pi, false, outerPaint);

    // Leading diamond bead on outer ring
    final beadAngle = outerAngle + 1.6 * math.pi;
    final beadPos = Offset(
      center.dx + ringRadius * math.cos(beadAngle),
      center.dy + ringRadius * math.sin(beadAngle),
    );
    final beadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(beadPos, math.max(2.2, w * 0.038), beadPaint);

    // Inner Counter-Clockwise Slender Ring
    final innerRadius = w * 0.37;
    final innerAngle = -progress * 2 * math.pi * 0.85;
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, w * 0.02)
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        transform: GradientRotation(innerAngle),
        colors: [
          accentColor.withValues(alpha: 0.0),
          accentColor.withValues(alpha: 0.45),
          AppColors.primaryLight,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(innerRect);

    canvas.drawArc(innerRect, innerAngle, 1.25 * math.pi, false, innerPaint);
  }

  void _drawBrilliantDiamond(Canvas canvas, Offset center, double w, double h) {
    // Diamond bounds
    final dw = w * 0.46;
    final dh = h * 0.46;
    final top = center.dy - dh * 0.48;
    final bottom = center.dy + dh * 0.52;
    final left = center.dx - dw * 0.50;
    final right = center.dx + dw * 0.50;

    // Key Diamond Anchor Points
    final tableTopY = top;
    final girdleY = center.dy - dh * 0.04;
    final culet = Offset(center.dx, bottom); // Bottom point

    final tableLeft = Offset(center.dx - dw * 0.22, tableTopY);
    final tableRight = Offset(center.dx + dw * 0.22, tableTopY);
    final girdleLeft = Offset(left, girdleY);
    final girdleRight = Offset(right, girdleY);
    final girdleMidLeft = Offset(center.dx - dw * 0.16, girdleY);
    final girdleMidRight = Offset(center.dx + dw * 0.16, girdleY);

    // Dynamic light rotation angle for realistic facet refraction
    final lightAngle = progress * 2 * math.pi;

    // Helper to compute facet luminance (refraction highlight)
    Color facetColor(double facetPhase, {bool isTable = false}) {
      final intensity = (0.5 + 0.5 * math.sin(lightAngle + facetPhase)).clamp(0.0, 1.0);
      if (isTable) {
        return Color.lerp(
          primaryColor.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.85),
          intensity,
        )!;
      }
      return Color.lerp(
        accentColor.withValues(alpha: 0.30),
        primaryColor.withValues(alpha: 0.75),
        intensity,
      )!;
    }

    final facetFillPaint = Paint()..style = PaintingStyle.fill;

    // 1. Center Table Polygon
    final tablePath = Path()
      ..moveTo(tableLeft.dx, tableLeft.dy)
      ..lineTo(tableRight.dx, tableRight.dy)
      ..lineTo(girdleMidRight.dx, girdleMidRight.dy)
      ..lineTo(girdleMidLeft.dx, girdleMidLeft.dy)
      ..close();
    facetFillPaint.color = facetColor(0.0, isTable: true);
    canvas.drawPath(tablePath, facetFillPaint);

    // 2. Left Crown Facet
    final leftCrownPath = Path()
      ..moveTo(tableLeft.dx, tableLeft.dy)
      ..lineTo(girdleMidLeft.dx, girdleMidLeft.dy)
      ..lineTo(girdleLeft.dx, girdleLeft.dy)
      ..close();
    facetFillPaint.color = facetColor(math.pi * 0.6);
    canvas.drawPath(leftCrownPath, facetFillPaint);

    // 3. Right Crown Facet
    final rightCrownPath = Path()
      ..moveTo(tableRight.dx, tableRight.dy)
      ..lineTo(girdleRight.dx, girdleRight.dy)
      ..lineTo(girdleMidRight.dx, girdleMidRight.dy)
      ..close();
    facetFillPaint.color = facetColor(math.pi * 1.3);
    canvas.drawPath(rightCrownPath, facetFillPaint);

    // 4. Center Pavilion Facet (to culet)
    final centerPavilionPath = Path()
      ..moveTo(girdleMidLeft.dx, girdleMidLeft.dy)
      ..lineTo(girdleMidRight.dx, girdleMidRight.dy)
      ..lineTo(culet.dx, culet.dy)
      ..close();
    facetFillPaint.color = facetColor(math.pi * 0.35);
    canvas.drawPath(centerPavilionPath, facetFillPaint);

    // 5. Left Pavilion Facet
    final leftPavilionPath = Path()
      ..moveTo(girdleLeft.dx, girdleLeft.dy)
      ..lineTo(girdleMidLeft.dx, girdleMidLeft.dy)
      ..lineTo(culet.dx, culet.dy)
      ..close();
    facetFillPaint.color = facetColor(math.pi * 0.9);
    canvas.drawPath(leftPavilionPath, facetFillPaint);

    // 6. Right Pavilion Facet
    final rightPavilionPath = Path()
      ..moveTo(girdleMidRight.dx, girdleMidRight.dy)
      ..lineTo(girdleRight.dx, girdleRight.dy)
      ..lineTo(culet.dx, culet.dy)
      ..close();
    facetFillPaint.color = facetColor(math.pi * 1.6);
    canvas.drawPath(rightPavilionPath, facetFillPaint);

    // Dynamic Specular Light Sweep (Diamond Fire sheen)
    final sweepProgress = (progress * 1.5) % 1.0;
    final sweepX = left + (dw * 1.6 * sweepProgress) - (dw * 0.3);
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.65),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(sweepX, top, dw * 0.28, dh))
      ..style = PaintingStyle.fill;

    final fullDiamondPath = Path()
      ..moveTo(tableLeft.dx, tableLeft.dy)
      ..lineTo(tableRight.dx, tableRight.dy)
      ..lineTo(girdleRight.dx, girdleRight.dy)
      ..lineTo(culet.dx, culet.dy)
      ..lineTo(girdleLeft.dx, girdleLeft.dy)
      ..close();

    canvas.save();
    canvas.clipPath(fullDiamondPath);
    canvas.drawRect(Rect.fromLTWH(sweepX, top, dw * 0.28, dh), sheenPaint);
    canvas.restore();

    // Crisp Facet Outline Strokes
    final edgePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.3, w * 0.024)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final innerLinePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, w * 0.018)
      ..strokeCap = StrokeCap.round;

    // Draw diamond silhouette
    canvas.drawPath(fullDiamondPath, edgePaint);

    // Draw facet lines
    canvas.drawLine(tableLeft, girdleMidLeft, innerLinePaint);
    canvas.drawLine(tableRight, girdleMidRight, innerLinePaint);
    canvas.drawLine(girdleMidLeft, girdleMidRight, innerLinePaint);
    canvas.drawLine(girdleMidLeft, culet, innerLinePaint);
    canvas.drawLine(girdleMidRight, culet, innerLinePaint);
  }

  void _drawSparkleStars(Canvas canvas, Offset center, double w) {
    // 3 distinct sparkles around the diamond
    final sparkles = [
      (
        // Top right brilliance sparkle
        Offset(center.dx + w * 0.24, center.dy - w * 0.22),
        ((progress * 2.0) % 1.0),
        w * 0.12,
      ),
      (
        // Bottom left culet sparkle
        Offset(center.dx - w * 0.22, center.dy + w * 0.18),
        ((progress * 2.0 + 0.5) % 1.0),
        w * 0.09,
      ),
      (
        // Center table glint
        Offset(center.dx, center.dy - w * 0.08),
        ((progress * 3.0 + 0.25) % 1.0),
        w * 0.08,
      ),
    ];

    for (final sp in sparkles) {
      final phase = sp.$2;
      final opacity = math.sin(phase * math.pi).clamp(0.0, 1.0);
      if (opacity <= 0.05) continue;

      final spCenter = sp.$1;
      final size = sp.$3 * (0.6 + 0.4 * opacity);

      final starPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.95 * opacity)
        ..style = PaintingStyle.fill;

      final starGlow = Paint()
        ..color = accentColor.withValues(alpha: 0.5 * opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.5);
      canvas.drawCircle(spCenter, size * 0.4, starGlow);

      final starPath = Path()
        ..moveTo(spCenter.dx, spCenter.dy - size)
        ..quadraticBezierTo(spCenter.dx, spCenter.dy, spCenter.dx + size, spCenter.dy)
        ..quadraticBezierTo(spCenter.dx, spCenter.dy, spCenter.dx, spCenter.dy + size)
        ..quadraticBezierTo(spCenter.dx, spCenter.dy, spCenter.dx - size, spCenter.dy)
        ..quadraticBezierTo(spCenter.dx, spCenter.dy, spCenter.dx, spCenter.dy - size)
        ..close();

      canvas.drawPath(starPath, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ModernJewelleryLoaderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor;
  }
}
