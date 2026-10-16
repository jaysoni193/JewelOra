import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/core/firebase/firebase_logger.dart';
import 'package:jewel_ora/models/app_notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background isolate
  await Firebase.initializeApp();
  if (kDebugMode) {
    debugPrint('[FCM Background] Message received: ${message.messageId}');
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // FCM Topics
  static const String topicGoldDrop = 'gold_price_drops';
  static const String topicNewCollection = 'new_collections';
  static const String topicFestiveOffers = 'festive_offers';
  static const String topicGeneral = 'general';

  // Preference keys
  static const String _prefGoldDrop = 'notif_pref_gold_drop';
  static const String _prefNewCollection = 'notif_pref_new_collection';
  static const String _prefFestiveOffers = 'notif_pref_festive_offers';

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Callback triggered when a foreground message arrives to show an in-app banner
  static void Function(RemoteMessage message)? onForegroundMessage;

  Future<void> init() async {
    try {
      // 1. Request permission
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      FirebaseLogger.response(
        collection: 'notifications',
        operation: 'requestPermission',
        data: {'authorizationStatus': settings.authorizationStatus.toString()},
      );

      // 2. Register background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Fetch token
      try {
        _fcmToken = await _fcm.getToken();
        if (_fcmToken != null) {
          FirebaseLogger.response(
            collection: 'notifications',
            operation: 'getToken',
            data: {'token': _fcmToken},
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[FCM] Token fetch note: $e');
        }
      }

      // 4. Listen to token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
      });

      // 5. Sync default topic subscriptions based on preferences
      await _syncInitialTopicSubscriptions();

      // 6. Listen to foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        FirebaseLogger.response(
          collection: 'notifications',
          operation: 'onMessage (foreground)',
          data: {
            'title': message.notification?.title,
            'body': message.notification?.body,
            'data': message.data,
          },
        );
        onForegroundMessage?.call(message);
      });

      // 7. Handle notification click
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        FirebaseLogger.response(
          collection: 'notifications',
          operation: 'onMessageOpenedApp',
          data: {'data': message.data},
        );
      });
    } catch (e, st) {
      FirebaseLogger.error(
        collection: 'notifications',
        operation: 'init',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Sync default topics on first startup
  Future<void> _syncInitialTopicSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // General topic is always subscribed
      await _fcm.subscribeToTopic(topicGeneral);

      final goldDrop = prefs.getBool(_prefGoldDrop) ?? true;
      if (goldDrop) {
        await _fcm.subscribeToTopic(topicGoldDrop);
      }

      final newColl = prefs.getBool(_prefNewCollection) ?? true;
      if (newColl) {
        await _fcm.subscribeToTopic(topicNewCollection);
      }

      final festive = prefs.getBool(_prefFestiveOffers) ?? true;
      if (festive) {
        await _fcm.subscribeToTopic(topicFestiveOffers);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FCM] Topic sync note: $e');
      }
    }
  }

  /// Associate current user with this device's push token
  Future<void> syncUserToken(String? uid) async {
    if (uid == null || uid.isEmpty || _fcmToken == null) return;
    try {
      await _db.collection(FirestorePaths.users).doc(uid).set({
        'fcmToken': _fcmToken,
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  // -------------------------------------------------------------
  // USER NOTIFICATION PREFERENCES
  // -------------------------------------------------------------

  Future<Map<String, bool>> getNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        topicGoldDrop: prefs.getBool(_prefGoldDrop) ?? true,
        topicNewCollection: prefs.getBool(_prefNewCollection) ?? true,
        topicFestiveOffers: prefs.getBool(_prefFestiveOffers) ?? true,
      };
    } catch (_) {
      return {
        topicGoldDrop: true,
        topicNewCollection: true,
        topicFestiveOffers: true,
      };
    }
  }

  Future<void> setTopicPreference(String topic, bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (topic == topicGoldDrop) {
        await prefs.setBool(_prefGoldDrop, enabled);
      } else if (topic == topicNewCollection) {
        await prefs.setBool(_prefNewCollection, enabled);
      } else if (topic == topicFestiveOffers) {
        await prefs.setBool(_prefFestiveOffers, enabled);
      }

      if (enabled) {
        await _fcm.subscribeToTopic(topic);
      } else {
        await _fcm.unsubscribeFromTopic(topic);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FCM] Set topic preference error: $e');
      }
    }
  }

  // -------------------------------------------------------------
  // IN-APP NOTIFICATIONS INBOX (FIRESTORE)
  // -------------------------------------------------------------

  Stream<List<AppNotificationModel>> watchNotifications({int limit = 40}) {
    return _db
        .collection(FirestorePaths.notifications)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppNotificationModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> markAsRead(String id) async {
    try {
      await _db
          .collection(FirestorePaths.notifications)
          .doc(id)
          .update({'isRead': true});
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final snap = await _db
          .collection(FirestorePaths.notifications)
          .where('isRead', isEqualTo: false)
          .limit(30)
          .get();

      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (_) {}
  }

  // -------------------------------------------------------------
  // FCM SERVER KEY CONFIG & BROADCASTING
  // -------------------------------------------------------------

  Future<Map<String, dynamic>> getFcmConfig() async {
    try {
      final snap = await _db
          .collection(FirestorePaths.appSettings)
          .doc(FirestorePaths.fcmConfigDocId)
          .get();
      if (!snap.exists || snap.data() == null) {
        return {'serverKey': '', 'senderId': '', 'enabled': true};
      }
      return snap.data()!;
    } catch (_) {
      return {'serverKey': '', 'senderId': '', 'enabled': true};
    }
  }

  Future<void> saveFcmConfig({
    required String serverKey,
    String? senderId,
  }) async {
    await _db
        .collection(FirestorePaths.appSettings)
        .doc(FirestorePaths.fcmConfigDocId)
        .set({
      'serverKey': serverKey.trim(),
      'senderId': (senderId ?? '').trim(),
      'enabled': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Dispatches an FCM Push Notification over HTTP (if serverKey is configured)
  /// and writes to Firestore `notifications` collection so all clients have it in-app.
  Future<bool> broadcastNotification({
    required String title,
    required String body,
    required String topic,
    String type = 'announcement',
    String? imageUrl,
    Map<String, dynamic> payload = const {},
  }) async {
    try {
      final notificationId = 'notif_${DateTime.now().millisecondsSinceEpoch}';
      final notification = AppNotificationModel(
        id: notificationId,
        title: title,
        body: body,
        topic: topic,
        type: type,
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
        payload: payload,
        isRead: false,
      );

      // 1. Write to Firestore `notifications` (Zero cost in-app sync)
      await _db
          .collection(FirestorePaths.notifications)
          .doc(notificationId)
          .set(notification.toMap());

      // 2. Dispatch FCM HTTP push to topic if server key is present
      final config = await getFcmConfig();
      final serverKey = config['serverKey'] as String? ?? '';

      if (serverKey.isNotEmpty) {
        final fcmEndpoint = Uri.parse('https://fcm.googleapis.com/fcm/send');
        final target = topic == topicGeneral ? '/topics/$topicGeneral' : '/topics/$topic';

        final response = await http.post(
          fcmEndpoint,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey',
          },
          body: jsonEncode({
            'to': target,
            'priority': 'high',
            'notification': {
              'title': title,
              'body': body,
              'image': ?imageUrl,
            },
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'topic': topic,
              'type': type,
              'id': notificationId,
              ...payload,
            },
          }),
        );

        if (kDebugMode) {
          debugPrint('[FCM Dispatch] Status: ${response.statusCode}, Body: ${response.body}');
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FCM Dispatch Error]: $e');
      }
      return false;
    }
  }

  // -------------------------------------------------------------
  // AUTOMATED TRIGGERS
  // -------------------------------------------------------------

  /// Automated push trigger when daily gold rates drop
  Future<void> notifyGoldPriceDrop({
    required double oldRate,
    required double newRate,
    required String metalType, // e.g. "24K Gold", "22K Gold"
  }) async {
    final diff = oldRate - newRate;
    if (diff <= 0) return; // Only notify if price dropped

    final title = '⚡ Gold Rate Dropped! ₹${diff.toStringAsFixed(0)}/g Down Today';
    final body =
        'Today\'s $metalType rate dropped to ₹${newRate.toStringAsFixed(0)}/g. Lock your jewellery now before rates rise!';

    await broadcastNotification(
      title: title,
      body: body,
      topic: topicGoldDrop,
      type: 'rate_drop',
      payload: {
        'route': '/metal_rates',
        'metalType': metalType,
        'newRate': newRate,
      },
    );
  }

  /// Automated push trigger when new collection/product is published
  Future<void> notifyNewCollection({
    required String productName,
    required String categoryName,
    required double price,
    String? imageUrl,
  }) async {
    final title = '✨ New Arrival: $productName';
    final body =
        'Explore our latest exquisite $categoryName collection, handcrafted in hallmark gold & diamonds starting at ₹${price.toStringAsFixed(0)}.';

    await broadcastNotification(
      title: title,
      body: body,
      topic: topicNewCollection,
      type: 'new_product',
      imageUrl: imageUrl,
      payload: {
        'route': '/product',
        'productName': productName,
      },
    );
  }
}
