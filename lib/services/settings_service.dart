import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/core/firebase/firebase_logger.dart';
import 'package:jewel_ora/core/storage/local_storage.dart';
import 'package:jewel_ora/models/app_settings_model.dart';

class SettingsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _doc => _db
      .collection(FirestorePaths.appSettings)
      .doc(FirestorePaths.settingsDocId);

  /// Reads cached branding settings immediately from local storage for fast startup.
  Future<AppSettingsModel> getCachedSettings() =>
      LocalStorage.instance.getCachedAppSettings();

  /// If the document does not exist yet, defaults are returned.
  Stream<AppSettingsModel> watchSettings() {
    FirebaseLogger.request(
      collection: FirestorePaths.appSettings,
      operation: 'watchSettings',
      documentId: FirestorePaths.settingsDocId,
    );

    return _doc.snapshots().map((snap) {
      final data = snap.data();
      final settings = data == null
          ? const AppSettingsModel()
          : AppSettingsModel.fromMap(data);

      FirebaseLogger.response(
        collection: FirestorePaths.appSettings,
        operation: 'watchSettings (snapshot)',
        documentId: FirestorePaths.settingsDocId,
        data: {'appName': settings.appName, 'hasLogo': settings.logoUrl.isNotEmpty},
      );

      // Cache locally for offline and quick startup
      LocalStorage.instance.cacheAppSettings(settings);

      return settings;
    });
  }

  /// `set` with merge creates the document on the first save.
  Future<void> save(AppSettingsModel settings) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.appSettings,
      operation: 'save',
      documentId: FirestorePaths.settingsDocId,
      parameters: {
        'appName': settings.appName,
        'hasLogo': settings.logoUrl.isNotEmpty,
        'appIcon': settings.appIcon,
      },
    );

    try {
      await _doc.set(settings.toMap(), SetOptions(merge: true));
      await LocalStorage.instance.cacheAppSettings(settings);
      FirebaseLogger.response(
        collection: FirestorePaths.appSettings,
        operation: 'save',
        documentId: FirestorePaths.settingsDocId,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.appSettings,
        operation: 'save',
        documentId: FirestorePaths.settingsDocId,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}