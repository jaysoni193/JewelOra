import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/core/firebase/firebase_logger.dart';
import 'package:jewel_ora/models/wishlist_item_model.dart';

class WishlistService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) => _db
      .collection(FirestorePaths.users)
      .doc(uid)
      .collection(FirestorePaths.wishlist);

  /// Live list, newest first (sorted on the device, so no index is needed).
  Stream<List<WishlistItemModel>> watch(String uid) {
    FirebaseLogger.request(
      collection: '${FirestorePaths.users}/$uid/${FirestorePaths.wishlist}',
      operation: 'watchWishlist (stream)',
    );

    return _col(uid).snapshots().map((snap) {
      FirebaseLogger.response(
        collection: '${FirestorePaths.users}/$uid/${FirestorePaths.wishlist}',
        operation: 'watchWishlist (snapshot)',
        data: '${snap.docs.length} wishlist items',
      );
      final list = snap.docs
          .map((d) => WishlistItemModel.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) {
        final ad = a.addedAt;
        final bd = b.addedAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return -1; // just added, server time not set yet
        if (bd == null) return 1;
        return bd.compareTo(ad);
      });
      return list;
    });
  }

  Future<void> add(String uid, String productId) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: '${FirestorePaths.users}/$uid/${FirestorePaths.wishlist}',
      operation: 'add',
      documentId: productId,
    );
    try {
      await _col(uid).doc(productId).set(
            WishlistItemModel(productId: productId).toMap(),
          );
      FirebaseLogger.response(
        collection: '${FirestorePaths.users}/$uid/${FirestorePaths.wishlist}',
        operation: 'add',
        documentId: productId,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: '${FirestorePaths.users}/$uid/${FirestorePaths.wishlist}',
        operation: 'add',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> remove(String uid, String productId) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: '${FirestorePaths.users}/$uid/${FirestorePaths.wishlist}',
      operation: 'remove',
      documentId: productId,
    );
    try {
      await _col(uid).doc(productId).delete();
      FirebaseLogger.response(
        collection: '${FirestorePaths.users}/$uid/${FirestorePaths.wishlist}',
        operation: 'remove',
        documentId: productId,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: '${FirestorePaths.users}/$uid/${FirestorePaths.wishlist}',
        operation: 'remove',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}