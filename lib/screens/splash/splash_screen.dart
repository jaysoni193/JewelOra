import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/brand_logo.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/screens/auth/auth_gate.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  final bool isInitialLaunch;

  const SplashScreen({super.key, this.isInitialLaunch = true});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _sparkleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (Logo scale, fade, and gentle slide up)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.84, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.10),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Ambient sparkling stars animation
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _entranceController.forward();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    // 1. Guaranteed minimum splash duration of 2.8 seconds so every device (including moto e13)
    // displays the full luxury animation and branding
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    if (!widget.isInitialLaunch) {
      Navigator.of(context).maybePop();
      return;
    }

    // 2. Ensure AuthProvider has finished resolving initial Firebase auth status
    try {
      final auth = context.read<AuthProvider>();
      while (auth.status == AuthStatus.initial) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
      }
    } catch (_) {
      // In case provider lookup is delayed, proceed smoothly
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthGate(),
        transitionDuration: const Duration(milliseconds: 700),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Read dynamic app title from settings if customized by admin
    String appName = AppStrings.appName;
    try {
      final settings = context.watch<SettingsProvider>().settings;
      if (settings.appName.trim().isNotEmpty) {
        appName = settings.appName;
      }
    } catch (_) {}

    // Theme-aligned Colors
    final bgColorTop = isDark ? AppColors.surfaceDark : Colors.white;
    final bgColorMid = isDark ? AppColors.darkBackground : AppColors.background;
    final bgColorBottom = isDark
        ? const Color(0xFF100917)
        : AppColors.primaryLight.withValues(alpha: 0.40);

    final titleColor = isDark ? Colors.white : AppColors.textDark;
    final taglineColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final badgeTextColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : AppColors.textGrey;

    return Scaffold(
      backgroundColor: bgColorMid,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgColorTop, bgColorMid, bgColorBottom],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft Ambient Central Bloom
            Center(
              child: Container(
                width: size.width * 0.72,
                height: size.width * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? AppColors.primary.withValues(alpha: 0.28)
                          : AppColors.primaryLight.withValues(alpha: 0.85),
                      blurRadius: 110,
                      spreadRadius: 35,
                    ),
                    BoxShadow(
                      color: isDark
                          ? AppColors.accent.withValues(alpha: 0.16)
                          : AppColors.accentLight.withValues(alpha: 0.65),
                      blurRadius: 140,
                      spreadRadius: 45,
                    ),
                  ],
                ),
              ),
            ),

            // Floating Delicate Diamond Sparkles Layer (Theme-tinted)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _sparkleController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _SplashParticlesPainter(
                      progress: _sparkleController.value,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),

            // Center Branding Container
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Luxury Brand Emblem with Theme-aligned Halo Ring
                        Container(
                          padding: const EdgeInsets.all(3.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.accent,
                                AppColors.primary,
                                AppColors.borderAccent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: isDark ? 0.40 : 0.16,
                                ),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: AppColors.accent.withValues(
                                  alpha: isDark ? 0.25 : 0.10,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF261233)
                                  : Colors.white,
                            ),
                            child: const BrandLogo(
                              size: 80,
                              showShadow: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // App Brand Title (Aliged with App Theme Typography)
                        Text(
                          appName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 5.0,
                            color: titleColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Refined Decorative Divider with Diamond Star
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36,
                              height: 1.2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.accent.withValues(alpha: 0.75),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: AppColors.accent,
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 1.2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.accent.withValues(alpha: 0.75),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Localized Tagline
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            AppStrings.appTagline.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.2,
                              color: taglineColor,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Modern Jewellery Loader & Hallmark Trust Badge
            Positioned(
              left: 0,
              right: 0,
              bottom: 46,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Solitaire & Orbit Rings Loader in App Primary Color
                    const AppLoader(
                      size: 38,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 18),

                    // Hallmark certification badge matching App Theme
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '100% CERTIFIED • BIS 916 HALLMARKED',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.8,
                            color: badgeTextColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating subtle diamond sparkles painter that harmonizes with the theme
class _SplashParticlesPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _SplashParticlesPainter({required this.progress, required this.isDark});

  static final List<({double x, double y, double size, double speed})> _stars =
      List.generate(18, (i) {
    final rand = math.Random(i * 997 + 13);
    return (
      x: rand.nextDouble(),
      y: rand.nextDouble(),
      size: 2.2 + rand.nextDouble() * 3.5,
      speed: 0.5 + rand.nextDouble() * 1.0,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _stars.length; i++) {
      final s = _stars[i];
      final currentY = (s.y - (progress * s.speed * 0.15)) % 1.0;
      final px = s.x * size.width;
      final py = currentY * size.height;

      final blink = (math.sin((progress * s.speed * 2 * math.pi) + i)).abs();
      if (blink <= 0.08) continue;

      // Theme-aligned subtle rose-gold and royal plum sparkle glints
      final Color baseColor;
      if (isDark) {
        baseColor = (i % 3 == 0) ? AppColors.accent : Colors.white;
      } else {
        baseColor = (i % 2 == 0) ? AppColors.accent : AppColors.primary;
      }

      paint.color = baseColor.withValues(
        alpha: (isDark ? 0.40 : 0.30) * blink,
      );

      // Draw subtle 4-pointed glint
      final r = s.size * (0.6 + 0.4 * blink);
      final path = Path()
        ..moveTo(px, py - r)
        ..quadraticBezierTo(px, py, px + r, py)
        ..quadraticBezierTo(px, py, px, py + r)
        ..quadraticBezierTo(px, py, px - r, py)
        ..quadraticBezierTo(px, py, px, py - r)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
