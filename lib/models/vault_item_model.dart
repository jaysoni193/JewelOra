import 'dart:convert';
import 'package:jewel_ora/models/metal_rate_model.dart';

class VaultItemModel {
  final String id;
  final String name;
  final String category; // 'Ring', 'Necklace', 'Earrings', 'Bangles', 'Chain', 'Coin', 'Other'
  final String metalType; // 'gold_24k', 'gold_22k', 'gold_18k', 'gold_14k', 'silver'
  final double grossWeight;
  final double stoneWeight;
  final double purchasePrice;
  final DateTime purchaseDate;
  final String? huidOrCert;
  final String? notes;

  const VaultItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.metalType,
    required this.grossWeight,
    this.stoneWeight = 0.0,
    required this.purchasePrice,
    required this.purchaseDate,
    this.huidOrCert,
    this.notes,
  });

  double get netWeight {
    final net = grossWeight - stoneWeight;
    return net > 0 ? (net * 100).round() / 100.0 : 0.0;
  }

  String get metalLabel {
    switch (metalType) {
      case 'gold_24k':
        return '24K Pure Gold (999)';
      case 'gold_22k':
        return '22K Hallmark Gold (916)';
      case 'gold_18k':
        return '18K Diamond Gold (750)';
      case 'gold_14k':
        return '14K Fine Gold (585)';
      case 'silver':
        return '925 Fine Silver';
      default:
        return '22K Gold';
    }
  }

  double getRatePerGram(MetalRateModel rates) {
    switch (metalType) {
      case 'gold_24k':
        return rates.gold24k;
      case 'gold_22k':
        return rates.gold22k;
      case 'gold_18k':
        return rates.gold18k;
      case 'gold_14k':
        return (rates.gold24k * 0.5833 * 100).round() / 100.0;
      case 'silver':
        return rates.silver1g;
      default:
        return rates.gold22k;
    }
  }

  /// Calculates today's replacement / scrap market portfolio value based on net weight
  double getCurrentValuation(MetalRateModel rates) {
    final rate = getRatePerGram(rates);
    final val = netWeight * rate;
    return (val * 100).round() / 100.0;
  }

  /// Profit/appreciation compared to original purchase price
  double getGain(MetalRateModel rates) {
    final currentVal = getCurrentValuation(rates);
    final gain = currentVal - purchasePrice;
    return (gain * 100).round() / 100.0;
  }

  /// Percentage gain or loss
  double getGainPercent(MetalRateModel rates) {
    if (purchasePrice <= 0) return 0.0;
    final diff = getGain(rates);
    final pct = (diff / purchasePrice) * 100.0;
    return (pct * 10).round() / 10.0;
  }

  VaultItemModel copyWith({
    String? id,
    String? name,
    String? category,
    String? metalType,
    double? grossWeight,
    double? stoneWeight,
    double? purchasePrice,
    DateTime? purchaseDate,
    String? huidOrCert,
    String? notes,
  }) {
    return VaultItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      metalType: metalType ?? this.metalType,
      grossWeight: grossWeight ?? this.grossWeight,
      stoneWeight: stoneWeight ?? this.stoneWeight,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      huidOrCert: huidOrCert ?? this.huidOrCert,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'metalType': metalType,
      'grossWeight': grossWeight,
      'stoneWeight': stoneWeight,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate.toIso8601String(),
      'huidOrCert': huidOrCert,
      'notes': notes,
    };
  }

  factory VaultItemModel.fromMap(Map<String, dynamic> map) {
    return VaultItemModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'Jewellery',
      metalType: map['metalType'] as String? ?? 'gold_22k',
      grossWeight: (map['grossWeight'] as num?)?.toDouble() ?? 0.0,
      stoneWeight: (map['stoneWeight'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (map['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: map['purchaseDate'] != null
          ? DateTime.tryParse(map['purchaseDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      huidOrCert: map['huidOrCert'] as String?,
      notes: map['notes'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory VaultItemModel.fromJson(String source) =>
      VaultItemModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
