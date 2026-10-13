import 'package:cloud_firestore/cloud_firestore.dart';

class MetalRateModel {
  final double gold24k; // per gram
  final double gold22k; // per gram
  final double gold18k; // per gram
  final double silver1g; // per gram
  final double gold24kChange; // e.g. +35 or -20 vs yesterday
  final double silverChange; // e.g. +1.5 or -1.0
  final DateTime? updatedAt;
  final bool isEnabled;

  const MetalRateModel({
    this.gold24k = 7650.0,
    this.gold22k = 7015.0,
    this.gold18k = 5740.0,
    this.silver1g = 92.0,
    this.gold24kChange = 15.0,
    this.silverChange = -0.5,
    this.updatedAt,
    this.isEnabled = true,
  });

  double get silver10g => silver1g * 10;
  double get silver1kg => silver1g * 1000;

  double getRateForType(String metalType) {
    switch (metalType) {
      case 'gold_24k':
        return gold24k;
      case 'gold_22k':
        return gold22k;
      case 'gold_18k':
        return gold18k;
      case 'silver':
        return silver1g;
      default:
        return 0.0;
    }
  }

  factory MetalRateModel.fromMap(Map<String, dynamic> map) {
    return MetalRateModel(
      gold24k: (map['gold24k'] ?? 7650.0).toDouble(),
      gold22k: (map['gold22k'] ?? 7015.0).toDouble(),
      gold18k: (map['gold18k'] ?? 5740.0).toDouble(),
      silver1g: (map['silver1g'] ?? 92.0).toDouble(),
      gold24kChange: (map['gold24kChange'] ?? 0.0).toDouble(),
      silverChange: (map['silverChange'] ?? 0.0).toDouble(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      isEnabled: map['isEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'gold24k': gold24k,
    'gold22k': gold22k,
    'gold18k': gold18k,
    'silver1g': silver1g,
    'gold24kChange': gold24kChange,
    'silverChange': silverChange,
    'updatedAt': updatedAt != null
        ? Timestamp.fromDate(updatedAt!)
        : FieldValue.serverTimestamp(),
    'isEnabled': isEnabled,
  };

  MetalRateModel copyWith({
    double? gold24k,
    double? gold22k,
    double? gold18k,
    double? silver1g,
    double? gold24kChange,
    double? silverChange,
    DateTime? updatedAt,
    bool? isEnabled,
  }) {
    return MetalRateModel(
      gold24k: gold24k ?? this.gold24k,
      gold22k: gold22k ?? this.gold22k,
      gold18k: gold18k ?? this.gold18k,
      silver1g: silver1g ?? this.silver1g,
      gold24kChange: gold24kChange ?? this.gold24kChange,
      silverChange: silverChange ?? this.silverChange,
      updatedAt: updatedAt ?? this.updatedAt,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
