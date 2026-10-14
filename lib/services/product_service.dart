import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/core/firebase/firebase_logger.dart';
import 'package:jewel_ora/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.products);

  /// Live list of all products, newest first (sorted on the device).
  Stream<List<ProductModel>> watchProducts() {
    FirebaseLogger.request(
      collection: FirestorePaths.products,
      operation: 'watchProducts (stream)',
    );

    return _col.snapshots().map((snap) {
      FirebaseLogger.response(
        collection: FirestorePaths.products,
        operation: 'watchProducts (snapshot)',
        data: '${snap.docs.length} products loaded',
      );
      final list =
          snap.docs.map((d) => ProductModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) {
        final ad = a.createdAt;
        final bd = b.createdAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return -1; // just added, server time not set yet
        if (bd == null) return 1;
        return bd.compareTo(ad);
      });
      return list;
    });
  }

  Future<void> add(ProductModel product) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.products,
      operation: 'add',
      parameters: {'name': product.name, 'categoryId': product.categoryId},
    );
    try {
      final docRef = await _col.add(product.toMap());
      FirebaseLogger.response(
        collection: FirestorePaths.products,
        operation: 'add',
        documentId: docRef.id,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.products,
        operation: 'add',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// createdAt is deliberately NOT updated.
  Future<void> update(ProductModel product) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.products,
      operation: 'update',
      documentId: product.id,
      parameters: {'name': product.name},
    );
    try {
      final data = product.toMap();
      data.remove('createdAt');
      await _col.doc(product.id).update(data);
      FirebaseLogger.response(
        collection: FirestorePaths.products,
        operation: 'update',
        documentId: product.id,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.products,
        operation: 'update',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> setAvailable(String id, bool value) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.products,
      operation: 'setAvailable',
      documentId: id,
      parameters: {'isAvailable': value},
    );
    try {
      await _col.doc(id).update({'isAvailable': value});
      FirebaseLogger.response(
        collection: FirestorePaths.products,
        operation: 'setAvailable',
        documentId: id,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.products,
        operation: 'setAvailable',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> setFeatured(String id, bool value) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.products,
      operation: 'setFeatured',
      documentId: id,
      parameters: {'isFeatured': value},
    );
    try {
      await _col.doc(id).update({'isFeatured': value});
      FirebaseLogger.response(
        collection: FirestorePaths.products,
        operation: 'setFeatured',
        documentId: id,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.products,
        operation: 'setFeatured',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.products,
      operation: 'delete',
      documentId: id,
    );
    try {
      await _col.doc(id).delete();
      FirebaseLogger.response(
        collection: FirestorePaths.products,
        operation: 'delete',
        documentId: id,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.products,
        operation: 'delete',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Admin Tool: Duplicates a product piece in 1 tap
  Future<String> duplicate(ProductModel p) async {
    final copy = p.copyWith(
      name: '${p.name} (Copy)',
    );
    final docRef = await _col.add(copy.toMap());
    return docRef.id;
  }

  /// Admin Tool: Bulk price change by percentage
  Future<int> bulkUpdatePrices({
    required List<ProductModel> products,
    required double percentage,
    String? categoryId,
    String? metalType,
  }) async {
    final batch = _db.batch();
    int count = 0;
    final factor = 1.0 + (percentage / 100.0);

    for (final p in products) {
      if (categoryId != null && categoryId.isNotEmpty && p.categoryId != categoryId) {
        continue;
      }
      if (metalType != null && metalType.isNotEmpty && p.metalType != metalType) {
        continue;
      }
      final newPrice = (p.price * factor).roundToDouble();
      final newMrp = p.mrp != null ? (p.mrp! * factor).roundToDouble() : null;

      final ref = _col.doc(p.id);
      batch.update(ref, {
        'price': newPrice,
        'mrp': ?newMrp,
      });
      count++;
      if (count >= 490) break;
    }

    if (count > 0) {
      await batch.commit();
    }
    return count;
  }
}