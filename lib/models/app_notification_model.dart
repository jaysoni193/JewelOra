import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationModel {
  final String id;
  final String title;
  final String body;
  final String topic; // 'gold_price_drops', 'new_collections', 'festive_offers', 'general'
  final String type;  // 'rate_drop', 'new_product', 'offer', 'announcement'
  final DateTime timestamp;
  final String? imageUrl;
  final Map<String, dynamic> payload;
  final bool isRead;

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.topic = 'general',
    this.type = 'announcement',
    required this.timestamp,
    this.imageUrl,
    this.payload = const {},
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'topic': topic,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
      'payload': payload,
      'isRead': isRead,
    };
  }

  factory AppNotificationModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parsedDate;
    final rawTs = map['timestamp'];
    if (rawTs is Timestamp) {
      parsedDate = rawTs.toDate();
    } else if (rawTs is String) {
      parsedDate = DateTime.tryParse(rawTs) ?? DateTime.now();
    } else if (rawTs is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawTs);
    } else {
      parsedDate = DateTime.now();
    }

    return AppNotificationModel(
      id: docId ?? (map['id'] as String? ?? ''),
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      topic: map['topic'] as String? ?? 'general',
      type: map['type'] as String? ?? 'announcement',
      timestamp: parsedDate,
      imageUrl: map['imageUrl'] as String?,
      payload: (map['payload'] as Map<String, dynamic>?) ?? const {},
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? topic,
    String? type,
    DateTime? timestamp,
    String? imageUrl,
    Map<String, dynamic>? payload,
    bool? isRead,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      topic: topic ?? this.topic,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      payload: payload ?? this.payload,
      isRead: isRead ?? this.isRead,
    );
  }
}
