import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? mrp; // Maximum Retail Price (strikethrough price)
  final String? offerTag; // e.g. "Diwali Sale", "Festive Offer", "Special Deal"
  final String categoryId;
  final String categoryName;
  final List<String> images;
  final String material;
  final String weight;
  final String? metalType; // 'gold_24k', 'gold_22k', 'gold_18k', 'silver', or null
  final double? metalWeight; // weight in grams for metal rate dynamic pricing
  final double? makingCharges; // making charges in INR
  final bool useDynamicRate; // calculate price based on live daily rate
  final bool isAvailable;
  final bool isFeatured;
  final List<String> availableSizes; // Custom sizes set by admin
  final DateTime? createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    this.mrp,
    this.offerTag,
    required this.categoryId,
    this.categoryName = '',
    this.images = const [],
    this.material = '',
    this.weight = '',
    this.metalType,
    this.metalWeight,
    this.makingCharges,
    this.useDynamicRate = false,
    this.isAvailable = true,
    this.isFeatured = false,
    this.availableSizes = const [],
    this.createdAt,
  });

  String get firstImage => images.isNotEmpty ? images.first : '';

  bool get hasDiscount => mrp != null && mrp! > price;

  int get discountPercent =>
      hasDiscount ? (((mrp! - price) / mrp!) * 100).round() : 0;

  double get savings => hasDiscount ? (mrp! - price) : 0;

  /// Returns custom sizes if configured, or smart default jewellery sizes based on category/name
  List<String> get effectiveSizes {
    if (availableSizes.isNotEmpty) return availableSizes;
    final lowerName = '$name $categoryName'.toLowerCase();
    if (lowerName.contains('ring')) {
      return const ['10', '12', '14', '16', '18', '20', 'Custom Size'];
    }
    if (lowerName.contains('bangle') || lowerName.contains('bracelet') || lowerName.contains('kada')) {
      return const ['2.2', '2.4', '2.6', '2.8', 'Adjustable'];
    }
    if (lowerName.contains('chain') || lowerName.contains('necklace') || lowerName.contains('mangalsutra') || lowerName.contains('choker')) {
      return const ['16 inch', '18 inch', '20 inch', '22 inch', 'Adjustable'];
    }
    return const ['Standard / Free Size'];
  }

  double getEffectivePrice(MetalRateModel? rates) {
    if (useDynamicRate && rates != null && metalType != null && metalWeight != null) {
      double ratePerGram = 0.0;
      switch (metalType) {
        case 'gold_24k':
          ratePerGram = rates.gold24k;
          break;
        case 'gold_22k':
          ratePerGram = rates.gold22k;
          break;
        case 'gold_18k':
          ratePerGram = rates.gold18k;
          break;
        case 'silver':
          ratePerGram = rates.silver1g;
          break;
        default:
          ratePerGram = 0.0;
      }
      if (ratePerGram > 0) {
        final metalCost = ratePerGram * metalWeight!;
        return metalCost + (makingCharges ?? 0.0);
      }
    }
    return price;
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      mrp: (map['mrp'] as num?)?.toDouble(),
      offerTag: map['offerTag'] as String?,
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      material: map['material'] ?? '',
      weight: map['weight'] ?? '',
      metalType: map['metalType'] as String?,
      metalWeight: (map['metalWeight'] as num?)?.toDouble(),
      makingCharges: (map['makingCharges'] as num?)?.toDouble(),
      useDynamicRate: map['useDynamicRate'] ?? false,
      isAvailable: map['isAvailable'] ?? true,
      isFeatured: map['isFeatured'] ?? false,
      availableSizes: List<String>.from(map['availableSizes'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'price': price,
    if (mrp != null) 'mrp': mrp,
    if (offerTag != null && offerTag!.isNotEmpty) 'offerTag': offerTag,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'images': images,
    'material': material,
    'weight': weight,
    if (metalType != null) 'metalType': metalType,
    if (metalWeight != null) 'metalWeight': metalWeight,
    if (makingCharges != null) 'makingCharges': makingCharges,
    'useDynamicRate': useDynamicRate,
    'isAvailable': isAvailable,
    'isFeatured': isFeatured,
    if (availableSizes.isNotEmpty) 'availableSizes': availableSizes,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };

  ProductModel copyWith({
    String? name,
    String? description,
    double? price,
    double? mrp,
    String? offerTag,
    String? categoryId,
    String? categoryName,
    List<String>? images,
    String? material,
    String? weight,
    String? metalType,
    double? metalWeight,
    double? makingCharges,
    bool? useDynamicRate,
    bool? isAvailable,
    bool? isFeatured,
    List<String>? availableSizes,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      offerTag: offerTag ?? this.offerTag,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      images: images ?? this.images,
      material: material ?? this.material,
      weight: weight ?? this.weight,
      metalType: metalType ?? this.metalType,
      metalWeight: metalWeight ?? this.metalWeight,
      makingCharges: makingCharges ?? this.makingCharges,
      useDynamicRate: useDynamicRate ?? this.useDynamicRate,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      availableSizes: availableSizes ?? this.availableSizes,
      createdAt: createdAt,
    );
  }
}