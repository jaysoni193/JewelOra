import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/core/errors/app_exception.dart';
import 'package:jewel_ora/core/firebase/firebase_logger.dart';
import 'package:jewel_ora/models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _cart(String uid) => _db
      .collection(FirestorePaths.users)
      .doc(uid)
      .collection(FirestorePaths.cart);

  /// Live cart, newest first (sorted on the device, so no index is needed).
  Stream<List<CartItemModel>> watchCart(String uid) {
    FirebaseLogger.request(
      collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
      operation: 'watchCart (stream)',
    );

    return _cart(uid).snapshots().map((snap) {
      FirebaseLogger.response(
        collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
        operation: 'watchCart (snapshot)',
        data: '${snap.docs.length} cart items',
      );
      final list = snap.docs
          .map((d) => CartItemModel.fromMap(d.data(), d.id))
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

  /// Adds the product, or adds one more of it. Returns the new quantity.
  /// A transaction makes sure two quick taps never overwrite each other.
  Future<int> addOrIncrement(
    String uid,
    String productId, {
    required int maxQuantity,
  }) {
    final startTime = DateTime.now();
    final ref = _cart(uid).doc(productId);

    FirebaseLogger.request(
      collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
      operation: 'addOrIncrement',
      documentId: productId,
    );

    return _db.runTransaction<int>((tx) async {
      final snap = await tx.get(ref);

      if (snap.exists) {
        final current = ((snap.data()?['quantity'] ?? 1) as num).toInt();
        if (current >= maxQuantity) {
          throw AppException('You can order at most $maxQuantity of one item.');
        }
        tx.update(ref, {'quantity': current + 1});
        FirebaseLogger.response(
          collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
          operation: 'addOrIncrement (incremented)',
          documentId: productId,
          data: {'newQuantity': current + 1},
          duration: DateTime.now().difference(startTime),
        );
        return current + 1;
      }

      tx.set(ref, CartItemModel(productId: productId).toMap());
      FirebaseLogger.response(
        collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
        operation: 'addOrIncrement (new item)',
        documentId: productId,
        data: {'newQuantity': 1},
        duration: DateTime.now().difference(startTime),
      );
      return 1;
    });
  }

  Future<void> setQuantity(String uid, String productId, int quantity) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
      operation: 'setQuantity',
      documentId: productId,
      parameters: {'quantity': quantity},
    );
    try {
      await _cart(uid).doc(productId).update({'quantity': quantity});
      FirebaseLogger.response(
        collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
        operation: 'setQuantity',
        documentId: productId,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
        operation: 'setQuantity',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> remove(String uid, String productId) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
      operation: 'remove',
      documentId: productId,
    );
    try {
      await _cart(uid).doc(productId).delete();
      FirebaseLogger.response(
        collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
        operation: 'remove',
        documentId: productId,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
        operation: 'remove',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Puts a removed item back (used by the Undo button).
  Future<void> restore(String uid, CartItemModel item) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
      operation: 'restore',
      documentId: item.productId,
    );
    try {
      await _cart(uid).doc(item.productId).set(item.toMap());
      FirebaseLogger.response(
        collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
        operation: 'restore',
        documentId: item.productId,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
        operation: 'restore',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> clear(String uid) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
      operation: 'clear',
    );
    try {
      final snap = await _cart(uid).get();
      if (snap.docs.isEmpty) return;
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      FirebaseLogger.response(
        collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
        operation: 'clear',
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: '${FirestorePaths.users}/$uid/${FirestorePaths.cart}',
        operation: 'clear',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}