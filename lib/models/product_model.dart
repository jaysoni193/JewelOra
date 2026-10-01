import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String categoryName;
  final List<String> images;
  final String material;
  final String weight;
  final bool isAvailable;
  final bool isFeatured;
  final DateTime? createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.categoryId,
    this.categoryName = '',
    this.images = const [],
    this.material = '',
    this.weight = '',
    this.isAvailable = true,
    this.isFeatured = false,
    this.createdAt,
  });

  String get firstImage => images.isNotEmpty ? images.first : '';

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      material: map['material'] ?? '',
      weight: map['weight'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      isFeatured: map['isFeatured'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'price': price,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'images': images,
    'material': material,
    'weight': weight,
    'isAvailable': isAvailable,
    'isFeatured': isFeatured,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };

  ProductModel copyWith({
    String? name,
    String? description,
    double? price,
    String? categoryId,
    String? categoryName,
    List<String>? images,
    String? material,
    String? weight,
    bool? isAvailable,
    bool? isFeatured,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      images: images ?? this.images,
      material: material ?? this.material,
      weight: weight ?? this.weight,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt,
    );
  }
}