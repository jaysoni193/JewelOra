import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/core/errors/app_exception.dart';
import 'package:jewel_ora/models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _cart(String uid) => _db
      .collection(FirestorePaths.users)
      .doc(uid)
      .collection(FirestorePaths.cart);

  /// Live cart, newest first (sorted on the device, so no index is needed).
  Stream<List<CartItemModel>> watchCart(String uid) {
    return _cart(uid).snapshots().map((snap) {
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
    final ref = _cart(uid).doc(productId);

    return _db.runTransaction<int>((tx) async {
      final snap = await tx.get(ref);

      if (snap.exists) {
        final current = ((snap.data()?['quantity'] ?? 1) as num).toInt();
        if (current >= maxQuantity) {
          throw AppException('You can order at most $maxQuantity of one item.');
        }
        tx.update(ref, {'quantity': current + 1});
        return current + 1;
      }

      tx.set(ref, CartItemModel(productId: productId).toMap());
      return 1;
    });
  }

  Future<void> setQuantity(String uid, String productId, int quantity) {
    return _cart(uid).doc(productId).update({'quantity': quantity});
  }

  Future<void> remove(String uid, String productId) {
    return _cart(uid).doc(productId).delete();
  }

  /// Puts a removed item back (used by the Undo button).
  Future<void> restore(String uid, CartItemModel item) {
    return _cart(uid).doc(item.productId).set(item.toMap());
  }

  Future<void> clear(String uid) async {
    final snap = await _cart(uid).get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch(); // the cart never exceeds 20 documents
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}