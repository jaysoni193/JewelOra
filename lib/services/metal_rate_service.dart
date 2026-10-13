import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/core/firebase/firebase_logger.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';

class MetalRateService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _doc => _db
      .collection(FirestorePaths.metalRates)
      .doc(FirestorePaths.metalRatesDocId);

  Stream<MetalRateModel> watchRates() {
    FirebaseLogger.request(
      collection: FirestorePaths.metalRates,
      operation: 'watchRates',
      documentId: FirestorePaths.metalRatesDocId,
    );

    return _doc.snapshots().map((snap) {
      final data = snap.data();
      final rates = data == null
          ? const MetalRateModel()
          : MetalRateModel.fromMap(data);

      FirebaseLogger.response(
        collection: FirestorePaths.metalRates,
        operation: 'watchRates (snapshot)',
        documentId: FirestorePaths.metalRatesDocId,
        data: {
          'gold24k': rates.gold24k,
          'gold22k': rates.gold22k,
          'silver1g': rates.silver1g,
        },
      );

      return rates;
    });
  }

  Future<MetalRateModel> getRates() async {
    try {
      final snap = await _doc.get();
      if (!snap.exists || snap.data() == null) {
        return const MetalRateModel();
      }
      return MetalRateModel.fromMap(snap.data()!);
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.metalRates,
        operation: 'getRates',
        documentId: FirestorePaths.metalRatesDocId,
        error: e,
        stackTrace: st,
      );
      return const MetalRateModel();
    }
  }

  Future<void> save(MetalRateModel rates) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.metalRates,
      operation: 'save',
      documentId: FirestorePaths.metalRatesDocId,
      parameters: rates.toMap(),
    );

    try {
      await _doc.set(rates.toMap(), SetOptions(merge: true));
      FirebaseLogger.response(
        collection: FirestorePaths.metalRates,
        operation: 'save',
        documentId: FirestorePaths.metalRatesDocId,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.metalRates,
        operation: 'save',
        documentId: FirestorePaths.metalRatesDocId,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
