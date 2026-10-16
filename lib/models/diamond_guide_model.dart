import 'dart:math';

/// Representation of the 4Cs of Diamond Grading (Cut, Color, Clarity, Carat Weight)
/// Provides gemological educational insights and dynamic pricing / diameter estimators.
class DiamondCut {
  final String id;
  final String label;
  final int sparkleScore;
  final String description;
  final double multiplier;

  const DiamondCut({
    required this.id,
    required this.label,
    required this.sparkleScore,
    required this.description,
    required this.multiplier,
  });

  static const List<DiamondCut> all = [
    DiamondCut(
      id: 'excellent',
      label: 'Excellent / Ideal Cut',
      sparkleScore: 99,
      description:
          'Reflects nearly 99% of entering light back through the table. Delivers maximum fire, brilliance, and scintillation.',
      multiplier: 1.25,
    ),
    DiamondCut(
      id: 'very_good',
      label: 'Very Good Cut',
      sparkleScore: 88,
      description:
          'Reflects almost as much light as an ideal cut at a significantly lower price point. Exceptional sparkle to the naked eye.',
      multiplier: 1.05,
    ),
    DiamondCut(
      id: 'good',
      label: 'Good Cut',
      sparkleScore: 75,
      description:
          'Reflects most light inward; excellent budget option allowing customers to prioritize a larger carat weight.',
      multiplier: 0.90,
    ),
  ];

  static DiamondCut getById(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.first);
}

class DiamondColor {
  final String id;
  final String grade;
  final String label;
  final int colorHex;
  final String description;
  final double multiplier;

  const DiamondColor({
    required this.id,
    required this.grade,
    required this.label,
    required this.colorHex,
    required this.description,
    required this.multiplier,
  });

  static const List<DiamondColor> all = [
    DiamondColor(
      id: 'd_f',
      grade: 'D - F',
      label: 'Colorless (D - F)',
      colorHex: 0xFFF4F9FF,
      description:
          'Completely icy white and devoid of any visible body color. The rarest, purest, and most prestigious diamond color tier.',
      multiplier: 1.40,
    ),
    DiamondColor(
      id: 'g_h',
      grade: 'G - H',
      label: 'Near Colorless (G - H)',
      colorHex: 0xFFFAF9F2,
      description:
          'Appears totally white to the naked eye once mounted in gold or platinum. Highest value tier offering maximum beauty per rupee.',
      multiplier: 1.10,
    ),
    DiamondColor(
      id: 'i_j',
      grade: 'I - J',
      label: 'Faint Warmth (I - J)',
      colorHex: 0xFFFFF6E5,
      description:
          'Subtle warm white undertone that pairs magnificently with yellow gold and vintage settings at outstanding affordability.',
      multiplier: 0.85,
    ),
  ];

  static DiamondColor getById(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.first);
}

class DiamondClarity {
  final String id;
  final String grade;
  final String label;
  final String description;
  final double multiplier;

  const DiamondClarity({
    required this.id,
    required this.grade,
    required this.label,
    required this.description,
    required this.multiplier,
  });

  static const List<DiamondClarity> all = [
    DiamondClarity(
      id: 'fl_if',
      grade: 'FL / IF',
      label: 'Flawless (FL / IF)',
      description:
          'Zero internal inclusions or surface blemishes visible even under 10x gemological microscope. Ultra-rare collector grade.',
      multiplier: 1.45,
    ),
    DiamondClarity(
      id: 'vvs',
      grade: 'VVS1 - VVS2',
      label: 'Very Very Slightly Included (VVS)',
      description:
          'Inclusions are so microscopic that they are extremely difficult for even trained gemologists to detect under 10x magnification.',
      multiplier: 1.20,
    ),
    DiamondClarity(
      id: 'vs',
      grade: 'VS1 - VS2',
      label: 'Very Slightly Included (VS)',
      description:
          '100% Eye-clean! Minor inclusions invisible to the naked eye. The industry sweet spot for luxury engagement rings.',
      multiplier: 1.00,
    ),
    DiamondClarity(
      id: 'si',
      grade: 'SI1 - SI2',
      label: 'Slightly Included (SI)',
      description:
          'Inclusions are visible under 10x loupe but generally difficult to spot without magnification. Great budget-friendly pick.',
      multiplier: 0.80,
    ),
  ];

  static DiamondClarity getById(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.first);
}

class DiamondGuideCalculator {
  static const List<double> popularCarats = [
    0.30,
    0.50,
    0.75,
    1.00,
    1.50,
    2.00,
    3.00,
  ];

  /// Calculates the visual millimeter diameter of a standard Round Brilliant solitaire
  /// Formula: 6.5 * (carat ^ 0.333)
  static double calculateDiameterMm(double carat) {
    if (carat <= 0) return 0.0;
    return 6.5 * pow(carat, 1.0 / 3.0);
  }

  /// Estimates standard benchmark diamond price in INR
  static double estimateBenchmarkPrice({
    required double carat,
    required String cutId,
    required String colorId,
    required String clarityId,
  }) {
    if (carat <= 0) return 0.0;
    final cut = DiamondCut.getById(cutId);
    final color = DiamondColor.getById(colorId);
    final clarity = DiamondClarity.getById(clarityId);

    // Natural diamond base curve grows exponentially with carat weight
    final basePricePerCarat = 60000.0 * pow(carat, 1.25);
    final calculated = basePricePerCarat *
        carat *
        cut.multiplier *
        color.multiplier *
        clarity.multiplier;

    // Round to nearest 500 for clean pricing
    return (calculated / 500).round() * 500.0;
  }

  /// Calculates overall visual brilliance rating (0 - 100%)
  static int calculateSparkleRating(String cutId, String clarityId) {
    final cut = DiamondCut.getById(cutId);
    final clarity = DiamondClarity.getById(clarityId);

    final cutWeight = cut.sparkleScore * 0.70;
    final clarityScore = clarity.id == 'fl_if'
        ? 100
        : clarity.id == 'vvs'
            ? 95
            : clarity.id == 'vs'
                ? 90
                : 80;
    final clarityWeight = clarityScore * 0.30;

    return (cutWeight + clarityWeight).round().clamp(60, 99);
  }
}
