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
      await _col.doc(product.id).update({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'categoryId': product.categoryId,
        'categoryName': product.categoryName,
        'images': product.images,
        'material': product.material,
        'weight': product.weight,
        'isAvailable': product.isAvailable,
        'isFeatured': product.isFeatured,
      });
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
}