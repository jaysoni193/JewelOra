import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/models/app_settings_model.dart';

class SettingsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _doc => _db
      .collection(FirestorePaths.appSettings)
      .doc(FirestorePaths.settingsDocId);

  /// If the document does not exist yet, defaults are returned.
  Stream<AppSettingsModel> watchSettings() {
    return _doc.snapshots().map((snap) {
      final data = snap.data();
      return data == null
          ? const AppSettingsModel()
          : AppSettingsModel.fromMap(data);
    });
  }

  /// `set` with merge creates the document on the first save.
  Future<void> save(AppSettingsModel settings) async {
    await _doc.set(settings.toMap(), SetOptions(merge: true));
  }
}