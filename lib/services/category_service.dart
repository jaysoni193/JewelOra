import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/core/errors/app_exception.dart';
import 'package:jewel_ora/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.categories);

  /// Live list of all categories, sorted by name.
  /// Categories are few, so sorting on the device avoids needing an index.
  Stream<List<CategoryModel>> watchCategories() {
    return _col.snapshots().map((snap) {
      final list =
      snap.docs.map((d) => CategoryModel.fromMap(d.data(), d.id)).toList();
      list.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  Future<void> add(CategoryModel category) async {
    await _col.add(category.toMap());
  }

  /// Updates a category. If the name changed, the copy of the name stored
  /// in every product of this category is updated too.
  Future<void> update(CategoryModel category, {required bool nameChanged}) async {
    await _col.doc(category.id).update({
      'name': category.name,
      'imageUrl': category.imageUrl,
      'isActive': category.isActive,
    });

    if (nameChanged) {
      await _syncProductCategoryName(category.id, category.name);
    }
  }

  Future<void> setActive(String id, bool value) {
    return _col.doc(id).update({'isActive': value});
  }

  /// Deletes a category only if no product uses it.
  Future<void> delete(String id) async {
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
  }

  Future<void> _syncProductCategoryName(String categoryId, String name) async {
    final snap = await _db
        .collection(FirestorePaths.products)
        .where('categoryId', isEqualTo: categoryId)
        .get();

    // A Firestore batch holds at most 500 writes, so we work in chunks.
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