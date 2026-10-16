import 'dart:convert';

/// Represents a Monthly Gold Savings Scheme (11+1 Plan / Swarna Nidhi)
/// Customer pays 11 monthly installments; Jewel Ora contributes the 12th month for free.
/// At month 12 maturity, the customer can redeem the total 12-month value in pure jewellery.
class GoldSavingsSchemeModel {
  final String id;
  final double monthlyDeposit;
  final int totalTenureMonths; // default 11 months
  final int monthsPaid;
  final DateTime startDate;
  final DateTime? lastPaymentDate;
  final String planName;
  final String customerName;
  final String customerPhone;

  const GoldSavingsSchemeModel({
    required this.id,
    required this.monthlyDeposit,
    this.totalTenureMonths = 11,
    this.monthsPaid = 1,
    required this.startDate,
    this.lastPaymentDate,
    this.planName = 'Swarna Nidhi 11+1 Plan',
    this.customerName = '',
    this.customerPhone = '',
  });

  /// Total amount the customer will pay over the full tenure (11 months)
  double get customerTotalContribution => monthlyDeposit * totalTenureMonths;

  /// Free bonus contributed by Jewel Ora (1 month free)
  double get storeBonusAmount => monthlyDeposit;

  /// Total jewellery redemption value at maturity (11 customer months + 1 bonus month = 12 months)
  double get totalMaturityValue => customerTotalContribution + storeBonusAmount;

  /// Amount paid so far by the customer
  double get amountPaidSoFar => monthlyDeposit * monthsPaid;

  /// Remaining amount customer needs to deposit
  double get remainingAmount =>
      monthlyDeposit * (totalTenureMonths - monthsPaid).clamp(0, totalTenureMonths);

  /// Whether all 11 installments have been completed
  bool get isMatured => monthsPaid >= totalTenureMonths;

  /// Estimated gold grams accumulated upon full maturity at a given rate per gram
  double calculateAccumulatedGrams(double ratePerGram) {
    if (ratePerGram <= 0) return 0.0;
    return totalMaturityValue / ratePerGram;
  }

  /// Estimated gold grams accumulated from installments paid so far
  double calculateGramsSoFar(double ratePerGram) {
    if (ratePerGram <= 0) return 0.0;
    return amountPaidSoFar / ratePerGram;
  }

  /// Projected next installment due date
  DateTime get nextDueDate {
    final targetMonth = startDate.month + monthsPaid;
    final yearOffset = (targetMonth - 1) ~/ 12;
    final normalizedMonth = ((targetMonth - 1) % 12) + 1;
    final targetYear = startDate.year + yearOffset;
    final safeDay = startDate.day.clamp(1, 28);
    return DateTime(targetYear, normalizedMonth, safeDay);
  }

  GoldSavingsSchemeModel copyWith({
    String? id,
    double? monthlyDeposit,
    int? totalTenureMonths,
    int? monthsPaid,
    DateTime? startDate,
    DateTime? lastPaymentDate,
    String? planName,
    String? customerName,
    String? customerPhone,
  }) {
    return GoldSavingsSchemeModel(
      id: id ?? this.id,
      monthlyDeposit: monthlyDeposit ?? this.monthlyDeposit,
      totalTenureMonths: totalTenureMonths ?? this.totalTenureMonths,
      monthsPaid: monthsPaid ?? this.monthsPaid,
      startDate: startDate ?? this.startDate,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      planName: planName ?? this.planName,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monthlyDeposit': monthlyDeposit,
      'totalTenureMonths': totalTenureMonths,
      'monthsPaid': monthsPaid,
      'startDate': startDate.toIso8601String(),
      'lastPaymentDate': lastPaymentDate?.toIso8601String(),
      'planName': planName,
      'customerName': customerName,
      'customerPhone': customerPhone,
    };
  }

  factory GoldSavingsSchemeModel.fromMap(Map<String, dynamic> map) {
    return GoldSavingsSchemeModel(
      id: map['id'] as String? ?? '',
      monthlyDeposit: (map['monthlyDeposit'] as num?)?.toDouble() ?? 5000.0,
      totalTenureMonths: (map['totalTenureMonths'] as num?)?.toInt() ?? 11,
      monthsPaid: (map['monthsPaid'] as num?)?.toInt() ?? 1,
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      lastPaymentDate: map['lastPaymentDate'] != null
          ? DateTime.tryParse(map['lastPaymentDate'] as String)
          : null,
      planName: map['planName'] as String? ?? 'Swarna Nidhi 11+1 Plan',
      customerName: map['customerName'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory GoldSavingsSchemeModel.fromJson(String source) =>
      GoldSavingsSchemeModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

/// Static helper for instant calculations without an active enrollment
class GoldSavingsCalculator {
  static const List<double> presetAmounts = [2000, 3000, 5000, 10000, 25000, 50000];

  static double calculateCustomerTotal(double monthlyAmount, [int tenure = 11]) =>
      monthlyAmount * tenure;

  static double calculateBonus(double monthlyAmount) => monthlyAmount;

  static double calculateTotalMaturity(double monthlyAmount, [int tenure = 11]) =>
      (monthlyAmount * tenure) + monthlyAmount;

  static double calculateEstGrams(double monthlyAmount, double ratePerGram, [int tenure = 11]) {
    if (ratePerGram <= 0) return 0.0;
    return calculateTotalMaturity(monthlyAmount, tenure) / ratePerGram;
  }
}
