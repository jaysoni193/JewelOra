import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/models/banner_model.dart';

class BannerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.banners);

  /// Live list sorted by `order` (on the device, so no index is needed).
  Stream<List<BannerModel>> watchBanners() {
    return _col.snapshots().map((snap) {
      final list =
      snap.docs.map((d) => BannerModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  Future<void> add(BannerModel banner) async {
    await _col.add(banner.toMap());
  }

  /// `order` is deliberately not touched here; reordering has its own method.
  Future<void> update(BannerModel banner) async {
    await _col.doc(banner.id).update({
      'imageUrl': banner.imageUrl,
      'title': banner.title,
      'isActive': banner.isActive,
    });
  }

  Future<void> setActive(String id, bool value) =>
      _col.doc(id).update({'isActive': value});

  Future<void> delete(String id) => _col.doc(id).delete();

  /// Rewrites `order` as 0, 1, 2... in one atomic batch.
  Future<void> reorder(List<BannerModel> ordered) async {
    final batch = _db.batch();
    for (var i = 0; i < ordered.length; i++) {
      batch.update(_col.doc(ordered[i].id), {'order': i});
    }
    await batch.commit();
  }
}