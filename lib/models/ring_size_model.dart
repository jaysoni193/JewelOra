/// Representation of standard Indian, US, and UK Ring Sizes
class RingSizeData {
  final String indiaSize;
  final String usSize;
  final String ukSize;
  final double diameterMm;
  final double circumferenceMm;

  const RingSizeData({
    required this.indiaSize,
    required this.usSize,
    required this.ukSize,
    required this.diameterMm,
    required this.circumferenceMm,
  });

  static const List<RingSizeData> all = [
    RingSizeData(indiaSize: '6', usSize: '3.5', ukSize: 'G', diameterMm: 14.5, circumferenceMm: 45.6),
    RingSizeData(indiaSize: '7', usSize: '4.0', ukSize: 'H', diameterMm: 14.9, circumferenceMm: 46.8),
    RingSizeData(indiaSize: '8', usSize: '4.5', ukSize: 'I', diameterMm: 15.3, circumferenceMm: 48.0),
    RingSizeData(indiaSize: '9', usSize: '5.0', ukSize: 'J', diameterMm: 15.7, circumferenceMm: 49.3),
    RingSizeData(indiaSize: '10', usSize: '5.5', ukSize: 'K', diameterMm: 16.1, circumferenceMm: 50.6),
    RingSizeData(indiaSize: '11', usSize: '5.75', ukSize: 'L', diameterMm: 16.5, circumferenceMm: 51.8),
    RingSizeData(indiaSize: '12', usSize: '6.0', ukSize: 'M', diameterMm: 16.9, circumferenceMm: 53.1),
    RingSizeData(indiaSize: '13', usSize: '6.5', ukSize: 'N', diameterMm: 17.1, circumferenceMm: 53.7),
    RingSizeData(indiaSize: '14', usSize: '7.0', ukSize: 'N 1/2', diameterMm: 17.3, circumferenceMm: 54.3),
    RingSizeData(indiaSize: '15', usSize: '7.25', ukSize: 'O', diameterMm: 17.5, circumferenceMm: 55.0),
    RingSizeData(indiaSize: '16', usSize: '7.5', ukSize: 'P', diameterMm: 17.7, circumferenceMm: 55.6),
    RingSizeData(indiaSize: '17', usSize: '8.0', ukSize: 'Q', diameterMm: 18.1, circumferenceMm: 56.9),
    RingSizeData(indiaSize: '18', usSize: '8.5', ukSize: 'R', diameterMm: 18.5, circumferenceMm: 58.1),
    RingSizeData(indiaSize: '19', usSize: '9.0', ukSize: 'S', diameterMm: 18.8, circumferenceMm: 59.1),
    RingSizeData(indiaSize: '20', usSize: '9.5', ukSize: 'T', diameterMm: 19.2, circumferenceMm: 60.3),
    RingSizeData(indiaSize: '21', usSize: '9.75', ukSize: 'U', diameterMm: 19.5, circumferenceMm: 61.3),
    RingSizeData(indiaSize: '22', usSize: '10.0', ukSize: 'V', diameterMm: 19.8, circumferenceMm: 62.2),
    RingSizeData(indiaSize: '23', usSize: '10.5', ukSize: 'W', diameterMm: 20.2, circumferenceMm: 63.5),
    RingSizeData(indiaSize: '24', usSize: '11.0', ukSize: 'X', diameterMm: 20.6, circumferenceMm: 64.7),
    RingSizeData(indiaSize: '25', usSize: '11.5', ukSize: 'Y', diameterMm: 21.0, circumferenceMm: 66.0),
    RingSizeData(indiaSize: '26', usSize: '12.0', ukSize: 'Z', diameterMm: 21.4, circumferenceMm: 67.2),
    RingSizeData(indiaSize: '28', usSize: '13.0', ukSize: 'Z+2', diameterMm: 22.2, circumferenceMm: 69.7),
  ];

  static RingSizeData findClosest(double diameterMm) {
    if (all.isEmpty) {
      return const RingSizeData(
        indiaSize: '14',
        usSize: '7.0',
        ukSize: 'N 1/2',
        diameterMm: 17.3,
        circumferenceMm: 54.3,
      );
    }

    RingSizeData closest = all.first;
    double minDiff = (closest.diameterMm - diameterMm).abs();

    for (final size in all) {
      final diff = (size.diameterMm - diameterMm).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = size;
      }
    }
    return closest;
  }
}

/// Representation of standard Indian Bangle Sizes
class BangleSizeData {
  final String notation;
  final String inches;
  final double diameterMm;
  final double circumferenceMm;
  final String fitDescription;

  const BangleSizeData({
    required this.notation,
    required this.inches,
    required this.diameterMm,
    required this.circumferenceMm,
    required this.fitDescription,
  });

  static const List<BangleSizeData> all = [
    BangleSizeData(
      notation: '2-2',
      inches: '2.125 in',
      diameterMm: 54.0,
      circumferenceMm: 169.6,
      fitDescription: 'Extra Small (Petite Wrists)',
    ),
    BangleSizeData(
      notation: '2-4',
      inches: '2.250 in',
      diameterMm: 57.2,
      circumferenceMm: 179.7,
      fitDescription: 'Small (Slender Wrists)',
    ),
    BangleSizeData(
      notation: '2-6',
      inches: '2.375 in',
      diameterMm: 60.3,
      circumferenceMm: 189.4,
      fitDescription: 'Medium / Standard',
    ),
    BangleSizeData(
      notation: '2-8',
      inches: '2.500 in',
      diameterMm: 63.5,
      circumferenceMm: 199.5,
      fitDescription: 'Large (Comfort Fit)',
    ),
    BangleSizeData(
      notation: '2-10',
      inches: '2.625 in',
      diameterMm: 66.7,
      circumferenceMm: 209.5,
      fitDescription: 'Extra Large (Broad Wrists)',
    ),
    BangleSizeData(
      notation: '2-12',
      inches: '2.750 in',
      diameterMm: 69.8,
      circumferenceMm: 219.3,
      fitDescription: 'Plus Size',
    ),
  ];

  static BangleSizeData findClosest(double diameterMm) {
    if (all.isEmpty) {
      return const BangleSizeData(
        notation: '2-6',
        inches: '2.375 in',
        diameterMm: 60.3,
        circumferenceMm: 189.4,
        fitDescription: 'Medium (Standard)',
      );
    }

    BangleSizeData closest = all.first;
    double minDiff = (closest.diameterMm - diameterMm).abs();

    for (final size in all) {
      final diff = (size.diameterMm - diameterMm).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = size;
      }
    }
    return closest;
  }
}

/// Physical Screen Calibration Standards
class ScreenCalibrationConstants {
  ScreenCalibrationConstants._();

  /// Standard Credit / Debit / PAN / Driving License card width (ISO/IEC 7810 ID-1)
  static const double creditCardWidthMm = 85.60;
  static const double creditCardHeightMm = 53.98;

  /// Standard Indian 5 Rupee Coin diameter
  static const double coin5RupeeDiameterMm = 23.00;

  /// Default baseline physical pixels per mm for typical modern smartphones (~380 to 420 ppi)
  static const double defaultPixelsPerMm = 6.30;
}
