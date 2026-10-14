import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/brand_logo.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/screens/auth/auth_gate.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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

    // 1. Entrance animation (Logo scale, fade, and slide up)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
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
    final startTime = DateTime.now();
    const minSplashDuration = Duration(milliseconds: 2400);

    // Wait until AuthProvider has resolved its initial auth state from Firebase
    try {
      final auth = context.read<AuthProvider>();
      while (auth.status == AuthStatus.initial) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
      }
    } catch (_) {
      // In case provider lookup is delayed, continue smoothly
    }

    final elapsed = DateTime.now().difference(startTime);
    if (elapsed < minSplashDuration) {
      await Future.delayed(minSplashDuration - elapsed);
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

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E173E), // Royal Imperial Plum
              Color(0xFF20102B), // Deep Velvet Plum
              Color(0xFF14081E), // Midnight Obsidian Plum
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient Radial Glow
            Center(
              child: Container(
                width: size.width * 0.75,
                height: size.width * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.16),
                      blurRadius: 110,
                      spreadRadius: 35,
                    ),
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 150,
                      spreadRadius: 60,
                    ),
                  ],
                ),
              ),
            ),

            // Floating Diamond Dust / Sparkles Layer
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _sparkleController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _SplashParticlesPainter(
                      progress: _sparkleController.value,
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
                        // Luxury Brand Emblem with Golden Halo Ring
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.accent.withValues(alpha: 0.85),
                                AppColors.primaryLight.withValues(alpha: 0.4),
                                AppColors.accentDark.withValues(alpha: 0.65),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.32),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: AppColors.primaryDark
                                    .withValues(alpha: 0.45),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF261233),
                            ),
                            child: const BrandLogo(
                              size: 78,
                              showShadow: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Brand Title
                        const Text(
                          'JEWEL ORA',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 5.5,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Refined Decorative Divider with Diamond Star
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 34,
                              height: 1,
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
                              width: 34,
                              height: 1,
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

                        // Subtitle / Tagline
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            AppStrings.appTagline.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2.4,
                              color: Colors.white.withValues(alpha: 0.74),
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

            // Bottom Loader & Hallmark Trust Badge
            Positioned(
              left: 0,
              right: 0,
              bottom: 46,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mini modern jewel loader
                    const AppLoader(
                      size: 38,
                      color: AppColors.accentLight,
                    ),
                    const SizedBox(height: 18),
                    // Hallmark certification badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 13,
                          color: AppColors.accent.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '100% CERTIFIED • BIS 916 HALLMARKED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.8,
                            color: Colors.white.withValues(alpha: 0.52),
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

/// Floating subtle diamond sparkles painter for the splash screen background
class _SplashParticlesPainter extends CustomPainter {
  final double progress;

  _SplashParticlesPainter({required this.progress});

  static final List<({double x, double y, double size, double speed})> _stars =
      List.generate(16, (i) {
    final rand = math.Random(i * 997 + 13);
    return (
      x: rand.nextDouble(),
      y: rand.nextDouble(),
      size: 2.0 + rand.nextDouble() * 3.5,
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

      paint.color = (i % 3 == 0 ? AppColors.accent : Colors.white)
          .withValues(alpha: 0.45 * blink);

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
    return oldDelegate.progress != progress;
  }
}
