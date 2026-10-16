import 'dart:convert';
import 'package:jewel_ora/models/metal_rate_model.dart';

class PriceAlertModel {
  final String id;
  final String metalType; // 'gold_24k', 'gold_22k', 'gold_18k', 'silver'
  final double targetRate;
  final DateTime createdAt;
  final bool isActive;
  final bool isTriggered;
  final DateTime? triggeredAt;

  const PriceAlertModel({
    required this.id,
    required this.metalType,
    required this.targetRate,
    required this.createdAt,
    this.isActive = true,
    this.isTriggered = false,
    this.triggeredAt,
  });

  String get metalLabel {
    switch (metalType) {
      case 'gold_24k':
        return '24K Pure Gold';
      case 'gold_22k':
        return '22K Hallmark Gold';
      case 'gold_18k':
        return '18K Diamond Gold';
      case 'silver':
        return '999 Fine Silver';
      default:
        return 'Gold';
    }
  }

  double getCurrentRate(MetalRateModel rates) {
    switch (metalType) {
      case 'gold_24k':
        return rates.gold24k;
      case 'gold_22k':
        return rates.gold22k;
      case 'gold_18k':
        return rates.gold18k;
      case 'silver':
        return rates.silver1g;
      default:
        return rates.gold22k;
    }
  }

  /// Returns true if benchmark rate is less than or equal to target rate
  bool checkHit(MetalRateModel rates) {
    if (!isActive) return false;
    final current = getCurrentRate(rates);
    if (current <= 0 || targetRate <= 0) return false;
    return current <= targetRate;
  }

  /// Returns the percentage drop needed from current rate to hit target.
  /// Negative value (e.g. -2.5%) means price still needs to drop.
  /// Zero or positive means target is met or exceeded.
  double percentageDiff(double currentRate) {
    if (currentRate <= 0) return 0.0;
    return ((targetRate - currentRate) / currentRate) * 100.0;
  }

  PriceAlertModel copyWith({
    String? id,
    String? metalType,
    double? targetRate,
    DateTime? createdAt,
    bool? isActive,
    bool? isTriggered,
    DateTime? triggeredAt,
  }) {
    return PriceAlertModel(
      id: id ?? this.id,
      metalType: metalType ?? this.metalType,
      targetRate: targetRate ?? this.targetRate,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      isTriggered: isTriggered ?? this.isTriggered,
      triggeredAt: triggeredAt ?? this.triggeredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'metalType': metalType,
      'targetRate': targetRate,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'isTriggered': isTriggered,
      'triggeredAt': triggeredAt?.toIso8601String(),
    };
  }

  factory PriceAlertModel.fromMap(Map<String, dynamic> map) {
    return PriceAlertModel(
      id: map['id'] as String? ?? '',
      metalType: map['metalType'] as String? ?? 'gold_22k',
      targetRate: (map['targetRate'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isActive: map['isActive'] as bool? ?? true,
      isTriggered: map['isTriggered'] as bool? ?? false,
      triggeredAt: map['triggeredAt'] != null
          ? DateTime.tryParse(map['triggeredAt'] as String)
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory PriceAlertModel.fromJson(String source) =>
      PriceAlertModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
