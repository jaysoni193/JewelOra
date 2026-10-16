import 'package:flutter/material.dart';

/// Ceremonies in Indian Weddings for Jewellery Planning
class BridalCeremony {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const BridalCeremony({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  static const List<BridalCeremony> all = [
    BridalCeremony(
      id: 'engagement',
      title: 'Engagement / Roka',
      subtitle: 'Diamond solitaire rings, bands & groom chains',
      icon: Icons.diamond_outlined,
    ),
    BridalCeremony(
      id: 'haldi_mehendi',
      title: 'Haldi & Mehendi',
      subtitle: 'Light floral gold, temple pendants & delicate bangles',
      icon: Icons.local_florist_outlined,
    ),
    BridalCeremony(
      id: 'sangeet',
      title: 'Sangeet & Cocktails',
      subtitle: 'Cocktail diamond necklace, chandelier jhumkas & statement rings',
      icon: Icons.nightlife_outlined,
    ),
    BridalCeremony(
      id: 'wedding_day',
      title: 'Wedding Day / Pheras',
      subtitle: 'Heavy bridal choker, rani haar, nath, maang tikka & kadas',
      icon: Icons.favorite_border_rounded,
    ),
    BridalCeremony(
      id: 'reception',
      title: 'Reception Gala',
      subtitle: 'Contemporary diamond collar, polki sets & white gold elegance',
      icon: Icons.celebration_outlined,
    ),
  ];

  static BridalCeremony getById(String id) {
    return all.firstWhere((c) => c.id == id, orElse: () => all.first);
  }
}

/// A single jewellery piece in the bridal trousseau plan
class BridalItem {
  final String id;
  final String ceremonyId;
  final String name;
  final String category;
  final double estimatedBudget;
  final double? actualSpend;
  final bool isPurchased;
  final double? targetGoldGrams;
  final String? notes;

  const BridalItem({
    required this.id,
    required this.ceremonyId,
    required this.name,
    required this.category,
    required this.estimatedBudget,
    this.actualSpend,
    this.isPurchased = false,
    this.targetGoldGrams,
    this.notes,
  });

  double get effectiveSpend => (isPurchased && actualSpend != null)
      ? actualSpend!
      : estimatedBudget;

  BridalItem copyWith({
    String? id,
    String? ceremonyId,
    String? name,
    String? category,
    double? estimatedBudget,
    double? actualSpend,
    bool? isPurchased,
    double? targetGoldGrams,
    String? notes,
  }) {
    return BridalItem(
      id: id ?? this.id,
      ceremonyId: ceremonyId ?? this.ceremonyId,
      name: name ?? this.name,
      category: category ?? this.category,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      actualSpend: actualSpend ?? this.actualSpend,
      isPurchased: isPurchased ?? this.isPurchased,
      targetGoldGrams: targetGoldGrams ?? this.targetGoldGrams,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ceremonyId': ceremonyId,
        'name': name,
        'category': category,
        'estimatedBudget': estimatedBudget,
        'actualSpend': actualSpend,
        'isPurchased': isPurchased,
        'targetGoldGrams': targetGoldGrams,
        'notes': notes,
      };

  factory BridalItem.fromJson(Map<String, dynamic> json) {
    return BridalItem(
      id: json['id'] as String? ?? 'item_${DateTime.now().millisecondsSinceEpoch}',
      ceremonyId: json['ceremonyId'] as String? ?? 'wedding_day',
      name: json['name'] as String? ?? 'Jewellery Piece',
      category: json['category'] as String? ?? 'Necklace',
      estimatedBudget: (json['estimatedBudget'] as num?)?.toDouble() ?? 50000.0,
      actualSpend: (json['actualSpend'] as num?)?.toDouble(),
      isPurchased: json['isPurchased'] as bool? ?? false,
      targetGoldGrams: (json['targetGoldGrams'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }
}

/// Profile holding customer's entire bridal jewellery plan & budget
class BridalPlannerProfile {
  final String brideName;
  final double totalBudget;
  final DateTime? weddingDate;
  final List<BridalItem> items;

  const BridalPlannerProfile({
    required this.brideName,
    required this.totalBudget,
    this.weddingDate,
    required this.items,
  });

  double get totalEstimatedSpend =>
      items.fold(0.0, (sum, item) => sum + item.estimatedBudget);

  double get totalPurchasedSpend => items
      .where((item) => item.isPurchased)
      .fold(0.0, (sum, item) => sum + item.effectiveSpend);

  double get remainingBudget => totalBudget - totalPurchasedSpend;

  bool get isOverBudget => totalPurchasedSpend > totalBudget;

  int get purchasedCount => items.where((item) => item.isPurchased).length;

  int get totalItemsCount => items.length;

  double get completionPercentage =>
      items.isEmpty ? 0.0 : (purchasedCount / items.length).clamp(0.0, 1.0);

  double get budgetUtilizationPercentage =>
      totalBudget <= 0 ? 0.0 : (totalPurchasedSpend / totalBudget).clamp(0.0, 1.0);

  double get totalGoldGrams =>
      items.fold(0.0, (sum, item) => sum + (item.targetGoldGrams ?? 0.0));

  double get purchasedGoldGrams => items
      .where((item) => item.isPurchased)
      .fold(0.0, (sum, item) => sum + (item.targetGoldGrams ?? 0.0));

  int? get daysUntilWedding {
    if (weddingDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(weddingDate!.year, weddingDate!.month, weddingDate!.day);
    return target.difference(today).inDays;
  }

  List<BridalItem> itemsForCeremony(String ceremonyId) =>
      items.where((i) => i.ceremonyId == ceremonyId).toList();

  BridalPlannerProfile copyWith({
    String? brideName,
    double? totalBudget,
    DateTime? weddingDate,
    List<BridalItem>? items,
  }) {
    return BridalPlannerProfile(
      brideName: brideName ?? this.brideName,
      totalBudget: totalBudget ?? this.totalBudget,
      weddingDate: weddingDate ?? this.weddingDate,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() => {
        'brideName': brideName,
        'totalBudget': totalBudget,
        'weddingDate': weddingDate?.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory BridalPlannerProfile.fromJson(Map<String, dynamic> json) {
    return BridalPlannerProfile(
      brideName: json['brideName'] as String? ?? 'Bride',
      totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 500000.0,
      weddingDate: json['weddingDate'] != null
          ? DateTime.tryParse(json['weddingDate'] as String)
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => BridalItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Curated Starter Heritage Trousseau Checklist
  static List<BridalItem> starterHeritageItems() => const [
        BridalItem(
          id: 'bi_eng_ring',
          ceremonyId: 'engagement',
          name: 'Solitaire Diamond Engagement Ring',
          category: 'Rings',
          estimatedBudget: 85000.0,
          targetGoldGrams: 4.5,
          notes: '18K White Gold with 0.75ct certified solitaire',
        ),
        BridalItem(
          id: 'bi_eng_chain',
          ceremonyId: 'engagement',
          name: "Groom's 22K Solid Gold Chain",
          category: 'Groom Jewellery',
          estimatedBudget: 75000.0,
          targetGoldGrams: 10.0,
        ),
        BridalItem(
          id: 'bi_haldi_choker',
          ceremonyId: 'haldi_mehendi',
          name: 'Floral Light Temple Gold Necklace',
          category: 'Necklace',
          estimatedBudget: 55000.0,
          targetGoldGrams: 7.5,
          notes: 'Comfortable light weight for haldi day',
        ),
        BridalItem(
          id: 'bi_haldi_bangles',
          ceremonyId: 'haldi_mehendi',
          name: 'Delicate Filigree Gold Bangles (Pair)',
          category: 'Bangles',
          estimatedBudget: 65000.0,
          targetGoldGrams: 9.0,
        ),
        BridalItem(
          id: 'bi_sangeet_earrings',
          ceremonyId: 'sangeet',
          name: 'Diamond Chandelier Cocktail Earrings',
          category: 'Earrings',
          estimatedBudget: 80000.0,
          targetGoldGrams: 7.0,
        ),
        BridalItem(
          id: 'bi_sangeet_ring',
          ceremonyId: 'sangeet',
          name: 'Statement Cocktail Diamond Ring',
          category: 'Rings',
          estimatedBudget: 45000.0,
          targetGoldGrams: 4.0,
        ),
        BridalItem(
          id: 'bi_wed_choker',
          ceremonyId: 'wedding_day',
          name: 'Royal Kundan & Polki Bridal Choker',
          category: 'Necklace',
          estimatedBudget: 220000.0,
          targetGoldGrams: 30.0,
          notes: 'Centerpiece wedding heirloom choker with emerald drops',
        ),
        BridalItem(
          id: 'bi_wed_ranihaar',
          ceremonyId: 'wedding_day',
          name: 'Traditional 22K Gold Bridal Rani Haar',
          category: 'Necklace',
          estimatedBudget: 175000.0,
          targetGoldGrams: 24.0,
        ),
        BridalItem(
          id: 'bi_wed_kadas',
          ceremonyId: 'wedding_day',
          name: 'Antique Temple Gold Kadas (Pair)',
          category: 'Bangles',
          estimatedBudget: 140000.0,
          targetGoldGrams: 19.0,
        ),
        BridalItem(
          id: 'bi_wed_tikka',
          ceremonyId: 'wedding_day',
          name: 'Bridal Maang Tikka & Matha Patti',
          category: 'Maang Tikka',
          estimatedBudget: 45000.0,
          targetGoldGrams: 6.0,
        ),
        BridalItem(
          id: 'bi_wed_nath',
          ceremonyId: 'wedding_day',
          name: 'Traditional Bridal Kundan Nath',
          category: 'Nath',
          estimatedBudget: 25000.0,
          targetGoldGrams: 3.5,
        ),
        BridalItem(
          id: 'bi_rec_collar',
          ceremonyId: 'reception',
          name: 'Modern Diamond Collar Necklace',
          category: 'Necklace',
          estimatedBudget: 150000.0,
          targetGoldGrams: 14.0,
        ),
      ];
}
