import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String productId; // also used as the document ID
  final int quantity;
  final String? size;
  final DateTime? addedAt;

  const CartItemModel({
    required this.productId,
    this.quantity = 1,
    this.size,
    this.addedAt,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map, String id) {
    return CartItemModel(
      productId: id,
      quantity: (map['quantity'] ?? 1).toInt(),
      size: map['size'] as String?,
      addedAt: (map['addedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'quantity': quantity,
    if (size != null && size!.isNotEmpty) 'size': size,
    'addedAt': addedAt != null
        ? Timestamp.fromDate(addedAt!)
        : FieldValue.serverTimestamp(),
  };

  CartItemModel copyWith({
    int? quantity,
    String? size,
  }) {
    return CartItemModel(
      productId: productId,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      addedAt: addedAt,
    );
  }
}