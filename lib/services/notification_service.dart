import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/core/firebase/firebase_logger.dart';

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

      // 5. Listen to foreground messages
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

      // 6. Handle notification click
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
}
