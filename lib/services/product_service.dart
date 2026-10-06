import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.products);

  /// Live list of all products, newest first (sorted on the device).
  Stream<List<ProductModel>> watchProducts() {
    return _col.snapshots().map((snap) {
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
    await _col.add(product.toMap());
  }

  /// createdAt is deliberately NOT updated.
  Future<void> update(ProductModel product) async {
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
  }

  Future<void> setAvailable(String id, bool value) =>
      _col.doc(id).update({'isAvailable': value});

  Future<void> setFeatured(String id, bool value) =>
      _col.doc(id).update({'isFeatured': value});

  Future<void> delete(String id) => _col.doc(id).delete();
}