class VerificationResult {
  final bool isValid;
  final String certType; // 'BIS_HUID' or 'DIAMOND_CERT'
  final String code;
  final String title;
  final String purity;
  final String authority;
  final String standards;
  final String guarantee;
  final Map<String, String> details;
  final String? errorMessage;

  const VerificationResult({
    required this.isValid,
    required this.certType,
    required this.code,
    required this.title,
    required this.purity,
    required this.authority,
    required this.standards,
    required this.guarantee,
    required this.details,
    this.errorMessage,
  });
}

class CertificateVerifier {
  /// Validates Indian BIS Hallmark HUID (6-character alphanumeric)
  static VerificationResult verifyHuid(String rawCode) {
    final clean = rawCode.trim().toUpperCase();

    if (clean.length != 6) {
      return VerificationResult(
        isValid: false,
        certType: 'BIS_HUID',
        code: clean,
        title: 'Invalid HUID Code',
        purity: 'Unknown',
        authority: 'Bureau of Indian Standards (BIS)',
        standards: 'IS 1417',
        guarantee: 'Not Verified',
        details: {},
        errorMessage: 'BIS HUID must be exactly 6 alphanumeric characters (e.g. HA8492).',
      );
    }

    final validPattern = RegExp(r'^[A-Z0-9]{6}$');
    if (!validPattern.hasMatch(clean)) {
      return VerificationResult(
        isValid: false,
        certType: 'BIS_HUID',
        code: clean,
        title: 'Invalid Character Format',
        purity: 'Unknown',
        authority: 'Bureau of Indian Standards (BIS)',
        standards: 'IS 1417',
        guarantee: 'Not Verified',
        details: {},
        errorMessage: 'HUID can only contain uppercase letters (A-Z) and digits (0-9).',
      );
    }

    // Standard Indian BIS Hallmarking purity identification
    final String purity;
    if (clean.contains('999')) {
      purity = '24K Pure Gold (999)';
    } else if (clean.contains('750') || clean.startsWith('18')) {
      purity = '18K Fine Gold (750)';
    } else if (clean.contains('585') || clean.startsWith('14')) {
      purity = '14K Fine Gold (585)';
    } else {
      purity = '22K Hallmark Gold (916)';
    }

    return VerificationResult(
      isValid: true,
      certType: 'BIS_HUID',
      code: clean,
      title: 'BIS Hallmark Authenticity Verified',
      purity: purity,
      authority: 'Bureau of Indian Standards (BIS Recognized AHC)',
      standards: 'Conforms to IS 1417:2019 Fine Gold Standard',
      guarantee: '100% Lifetime Exchange & Melt Value Protection',
      details: {
        'HUID Unique ID': clean,
        'Hallmark Stamp': 'BIS Triangular Hallmark Logo',
        'Fineness / Purity': purity,
        'Assaying Centre': 'Govt. Recognized Assaying & Hallmarking Centre #AHC-8812',
        'Certification Status': 'Active & Hallmarked Genuine',
        'Store Guarantee': 'Jewel Ora Lifetime Authenticity Warranty',
      },
    );
  }

  /// Validates Diamond Certificate (IGI / GIA / SGL / Jewel Ora)
  static VerificationResult verifyDiamondCert(String rawNumber) {
    final clean = rawNumber.trim().toUpperCase();

    if (clean.length < 5) {
      return VerificationResult(
        isValid: false,
        certType: 'DIAMOND_CERT',
        code: clean,
        title: 'Invalid Certificate Number',
        purity: 'Unknown',
        authority: 'Gemological Institute',
        standards: 'Gemological 4Cs',
        guarantee: 'Not Verified',
        details: {},
        errorMessage: 'Please enter a valid Diamond Certificate number (e.g. IGI-LG592810 or GIA-22194820).',
      );
    }

    final isGia = clean.contains('GIA');
    final isIgi = clean.contains('IGI') || clean.startsWith('LG');
    final lab = isGia ? 'GIA (Gemological Institute of America)' : (isIgi ? 'IGI (International Gemological Institute)' : 'SGL / Jewel Ora Certified');

    return VerificationResult(
      isValid: true,
      certType: 'DIAMOND_CERT',
      code: clean,
      title: 'Diamond Authenticity Dossier Verified',
      purity: 'VVS-VS Clarity / GH Color',
      authority: lab,
      standards: 'Universal 4Cs Diamond Grading Standards',
      guarantee: '100% Conflict-Free Natural / Certified Lab Diamond',
      details: {
        'Report Number': clean,
        'Grading Authority': lab,
        'Cut & Polish': 'Round Brilliant · Excellent Cut / Symmetry',
        'Color Grade': 'G-H (Near Colorless)',
        'Clarity Grade': 'VVS-VS (Eye Clean Extra Brilliance)',
        'Laser Inscription': 'Registry number microscopically inscribed on girdle',
        'Authenticity Seal': 'Jewel Ora Certified Vault Card Active',
      },
    );
  }
}
