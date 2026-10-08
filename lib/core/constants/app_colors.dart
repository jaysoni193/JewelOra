import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Modern CaratLane (Plum / Royal Violet) & GIVA (Berry / Rose) Palette
  static const Color primary = Color(0xFF4F3267);          // CaratLane Signature Royal Plum / Deep Violet
  static const Color primaryDark = Color(0xFF381F4C);      // Deep Imperial Plum
  static const Color primaryLight = Color(0xFFF5EEFB);     // Soft Lilac / Lavender Blush Tint

  // GIVA Inspired Rose Berry & Silver Accents
  static const Color accent = Color(0xFFDE4E76);           // GIVA Signature Rose Berry / Vibrant Pink
  static const Color accentDark = Color(0xFFB82852);       // Deep Wine Berry
  static const Color accentLight = Color(0xFFFDF0F4);      // Soft Rose Blush
  static const Color silver = Color(0xFFA1A1AA);           // Modern Silver / Platinum Accent (GIVA Silver)
  static const Color silverLight = Color(0xFFF4F4F6);      // Delicate Silver Mist

  // Clean Neutral Foundations (GIVA & CaratLane Crisp Surfaces)
  static const Color background = Color(0xFFF9F8FA);       // Crisp Porcelain Off-White (No yellow tint)
  static const Color surface = Colors.white;               // Pure White Surface
  static const Color surfaceVariant = Color(0xFFF3EFF7);   // Light Lilac-Grey Tint
  static const Color surfaceDark = Color(0xFF1D1625);      // Deep Aubergine / Obsidian
  static const Color darkBackground = Color(0xFF140E1B);  // Dark Plum Charcoal

  // Modern Typography Hierarchy
  static const Color textDark = Color(0xFF1C1525);         // Deep Charcoal Plum (Ultra readable)
  static const Color textMuted = Color(0xFF554D63);        // Slate Mauve
  static const Color textGrey = Color(0xFF7E768C);         // Modern Slate Grey
  static const Color textLight = Color(0xFFA59EAF);        // Soft Hint Grey
  static const Color textWhite = Colors.white;

  // Modern Subtle Borders & Dividers
  static const Color border = Color(0xFFECE7F2);           // Delicate Lavender-Slate Border
  static const Color borderAccent = Color(0xFFD8CCE6);     // Soft Plum-Tinted Border
  static const Color divider = Color(0xFFF0EBF5);

  // Status & Actions
  static const Color error = Color(0xFFDE3B68);            // Vibrant Berry Red / Heart Pink
  static const Color errorLight = Color(0xFFFDF0F4);
  static const Color success = Color(0xFF0D9488);          // Modern Teal Emerald Green
  static const Color successLight = Color(0xFFE6F5F3);
  static const Color whatsapp = Color(0xFF25D366);         // WhatsApp Brand
  static const Color whatsappDark = Color(0xFF1EAE53);

  // Backward-compatibility aliases (guaranteeing zero breakage across codebase)
  static const Color goldAccent = accent;                  // Redirect to modern rose berry
  static const Color goldShimmer = primaryLight;           // Redirect to soft lilac
  static const Color borderGold = borderAccent;            // Redirect to plum-tinted border

  // Modern Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5C3373), Color(0xFF45245B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE55D85), Color(0xFFC72E5D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = primaryGradient; // Redirected to modern plum gradient

  static const LinearGradient darkLuxuryGradient = LinearGradient(
    colors: [Color(0xFF281C35), Color(0xFF150D1C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAF7FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}