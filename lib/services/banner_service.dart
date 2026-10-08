import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/core/firebase/firebase_logger.dart';
import 'package:jewel_ora/models/banner_model.dart';

class BannerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.banners);

  /// Live list sorted by `order` (on the device, so no index is needed).
  Stream<List<BannerModel>> watchBanners() {
    FirebaseLogger.request(
      collection: FirestorePaths.banners,
      operation: 'watchBanners (stream)',
    );

    return _col.snapshots().map((snap) {
      FirebaseLogger.response(
        collection: FirestorePaths.banners,
        operation: 'watchBanners (snapshot)',
        data: '${snap.docs.length} banners loaded',
      );
      final list =
          snap.docs.map((d) => BannerModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  Future<void> add(BannerModel banner) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.banners,
      operation: 'add',
      parameters: {'title': banner.title, 'order': banner.order},
    );
    try {
      final docRef = await _col.add(banner.toMap());
      FirebaseLogger.response(
        collection: FirestorePaths.banners,
        operation: 'add',
        documentId: docRef.id,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.banners,
        operation: 'add',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// `order` is deliberately not touched here; reordering has its own method.
  Future<void> update(BannerModel banner) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.banners,
      operation: 'update',
      documentId: banner.id,
      parameters: {'title': banner.title},
    );
    try {
      await _col.doc(banner.id).update({
        'imageUrl': banner.imageUrl,
        'title': banner.title,
        'isActive': banner.isActive,
      });
      FirebaseLogger.response(
        collection: FirestorePaths.banners,
        operation: 'update',
        documentId: banner.id,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.banners,
        operation: 'update',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> setActive(String id, bool value) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.banners,
      operation: 'setActive',
      documentId: id,
      parameters: {'isActive': value},
    );
    try {
      await _col.doc(id).update({'isActive': value});
      FirebaseLogger.response(
        collection: FirestorePaths.banners,
        operation: 'setActive',
        documentId: id,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.banners,
        operation: 'setActive',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.banners,
      operation: 'delete',
      documentId: id,
    );
    try {
      await _col.doc(id).delete();
      FirebaseLogger.response(
        collection: FirestorePaths.banners,
        operation: 'delete',
        documentId: id,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.banners,
        operation: 'delete',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Rewrites `order` as 0, 1, 2... in one atomic batch.
  Future<void> reorder(List<BannerModel> ordered) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.banners,
      operation: 'reorder',
      parameters: {'count': ordered.length},
    );
    try {
      final batch = _db.batch();
      for (var i = 0; i < ordered.length; i++) {
        batch.update(_col.doc(ordered[i].id), {'order': i});
      }
      await batch.commit();
      FirebaseLogger.response(
        collection: FirestorePaths.banners,
        operation: 'reorder',
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.banners,
        operation: 'reorder',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}