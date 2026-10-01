import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String productId; // also used as the document ID
  final int quantity;
  final DateTime? addedAt;

  const CartItemModel({
    required this.productId,
    this.quantity = 1,
    this.addedAt,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map, String id) {
    return CartItemModel(
      productId: id,
      quantity: (map['quantity'] ?? 1).toInt(),
      addedAt: (map['addedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'quantity': quantity,
    'addedAt': addedAt != null
        ? Timestamp.fromDate(addedAt!)
        : FieldValue.serverTimestamp(),
  };
}