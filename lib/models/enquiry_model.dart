import 'package:cloud_firestore/cloud_firestore.dart';

class EnquiryItemModel {
  final String productId;
  final String productName;
  final double productPrice;
  final String productImage;
  final int quantity;
  final String? size;

  const EnquiryItemModel({
    required this.productId,
    required this.productName,
    required this.productPrice,
    this.productImage = '',
    this.quantity = 1,
    this.size,
  });

  factory EnquiryItemModel.fromMap(Map<String, dynamic> map) {
    return EnquiryItemModel(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productPrice: (map['productPrice'] ?? 0).toDouble(),
      productImage: map['productImage'] ?? '',
      quantity: (map['quantity'] ?? 1) as int,
      size: map['size'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'productPrice': productPrice,
    'productImage': productImage,
    'quantity': quantity,
    if (size != null && size!.isNotEmpty) 'size': size,
  };
}

class EnquiryModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String userEmail;
  final List<EnquiryItemModel> items;
  final double totalAmount;
  final String status; // 'submitted', 'in_discussion', 'quote_shared', 'completed'
  final String message;
  final DateTime? createdAt;

  const EnquiryModel({
    required this.id,
    required this.userId,
    this.userName = '',
    this.userPhone = '',
    this.userEmail = '',
    this.items = const [],
    this.totalAmount = 0.0,
    this.status = 'submitted',
    this.message = '',
    this.createdAt,
  });

  String get statusDisplay {
    switch (status) {
      case 'in_discussion':
        return 'In Discussion';
      case 'quote_shared':
        return 'Quote Shared';
      case 'completed':
        return 'Order Confirmed';
      case 'submitted':
      default:
        return 'Enquiry Sent';
    }
  }

  factory EnquiryModel.fromMap(Map<String, dynamic> map, String id) {
    return EnquiryModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      userEmail: map['userEmail'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) =>
                  EnquiryItemModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'submitted',
      message: map['message'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userName': userName,
    'userPhone': userPhone,
    'userEmail': userEmail,
    'items': items.map((i) => i.toMap()).toList(),
    'totalAmount': totalAmount,
    'status': status,
    'message': message,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };

  EnquiryModel copyWith({
    String? status,
    String? message,
  }) {
    return EnquiryModel(
      id: id,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      userEmail: userEmail,
      items: items,
      totalAmount: totalAmount,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt,
    );
  }
}
