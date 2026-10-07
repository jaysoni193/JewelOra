import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItemModel {
  final String productId; // also the document ID
  final DateTime? addedAt;

  const WishlistItemModel({required this.productId, this.addedAt});

  factory WishlistItemModel.fromMap(Map<String, dynamic> map, String id) {
    return WishlistItemModel(
      productId: id,
      addedAt: (map['addedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'addedAt': FieldValue.serverTimestamp(),
  };
}