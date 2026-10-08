import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/core/errors/app_exception.dart';
import 'package:jewel_ora/core/firebase/firebase_logger.dart';
import 'package:jewel_ora/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.categories);

  /// Live list of all categories, sorted by name.
  /// Categories are few, so sorting on the device avoids needing an index.
  Stream<List<CategoryModel>> watchCategories() {
    FirebaseLogger.request(
      collection: FirestorePaths.categories,
      operation: 'watchCategories (stream)',
    );

    return _col.snapshots().map((snap) {
      FirebaseLogger.response(
        collection: FirestorePaths.categories,
        operation: 'watchCategories (snapshot)',
        data: '${snap.docs.length} categories loaded',
      );
      final list =
          snap.docs.map((d) => CategoryModel.fromMap(d.data(), d.id)).toList();
      list.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  Future<void> add(CategoryModel category) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.categories,
      operation: 'add',
      parameters: {'name': category.name},
    );
    try {
      final docRef = await _col.add(category.toMap());
      FirebaseLogger.response(
        collection: FirestorePaths.categories,
        operation: 'add',
        documentId: docRef.id,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.categories,
        operation: 'add',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Updates a category. If the name changed, the copy of the name stored
  /// in every product of this category is updated too.
  Future<void> update(CategoryModel category,
      {required bool nameChanged}) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.categories,
      operation: 'update',
      documentId: category.id,
      parameters: {'name': category.name, 'nameChanged': nameChanged},
    );

    try {
      await _col.doc(category.id).update({
        'name': category.name,
        'imageUrl': category.imageUrl,
        'isActive': category.isActive,
      });

      if (nameChanged) {
        await _syncProductCategoryName(category.id, category.name);
      }
      FirebaseLogger.response(
        collection: FirestorePaths.categories,
        operation: 'update',
        documentId: category.id,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.categories,
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
      collection: FirestorePaths.categories,
      operation: 'setActive',
      documentId: id,
      parameters: {'isActive': value},
    );
    try {
      await _col.doc(id).update({'isActive': value});
      FirebaseLogger.response(
        collection: FirestorePaths.categories,
        operation: 'setActive',
        documentId: id,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.categories,
        operation: 'setActive',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Deletes a category only if no product uses it.
  Future<void> delete(String id) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.categories,
      operation: 'delete',
      documentId: id,
    );
    try {
      final used = await _db
          .collection(FirestorePaths.products)
          .where('categoryId', isEqualTo: id)
          .limit(1)
          .get();

      if (used.docs.isNotEmpty) {
        throw const AppException(
          'This category has products. Move or delete them first.',
        );
      }
      await _col.doc(id).delete();
      FirebaseLogger.response(
        collection: FirestorePaths.categories,
        operation: 'delete',
        documentId: id,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.categories,
        operation: 'delete',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> _syncProductCategoryName(String categoryId, String name) async {
    final snap = await _db
        .collection(FirestorePaths.products)
        .where('categoryId', isEqualTo: categoryId)
        .get();

    const chunkSize = 400;
    for (var i = 0; i < snap.docs.length; i += chunkSize) {
      final batch = _db.batch();
      final end =
          (i + chunkSize < snap.docs.length) ? i + chunkSize : snap.docs.length;
      for (final doc in snap.docs.sublist(i, end)) {
        batch.update(doc.reference, {'categoryName': name});
      }
      await batch.commit();
    }
  }
}