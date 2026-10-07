import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/models/product_stats_model.dart';

class StatsService {
  // ---------- Recording (customer side) ----------

  // Products already counted since the app started.
  static final Set<String> _viewed = {};
  static final Set<String> _enquired = {};

  static CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection(FirestorePaths.productStats);

  /// Counts one view, at most once per product per app session.
  static void recordView(String productId) {
    if (productId.isEmpty || !_viewed.add(productId)) return;
    unawaited(_increment([productId], 'views'));
  }

  static void recordEnquiry(String productId) =>
      recordEnquiries([productId]);

  /// Counts one enquiry per product, at most once per app session.
  static void recordEnquiries(Iterable<String> productIds) {
    final fresh =
    productIds.where((id) => id.isNotEmpty && _enquired.add(id)).toList();
    if (fresh.isEmpty) return;
    unawaited(_increment(fresh, 'enquiries'));
  }

  /// Never throws: a statistics problem must not disturb the customer.
  static Future<void> _increment(List<String> ids, String field) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final id in ids) {
        batch.set(
          _col.doc(id),
          {field: FieldValue.increment(1)},
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Stats write failed: $e');
    }
  }

  // ---------- Reading (admin side) ----------

  Future<List<ProductStatsModel>> fetchProductStats() async {
    final snap = await _col.get();
    return snap.docs
        .map((d) => ProductStatsModel.fromMap(d.data(), d.id))
        .toList();
  }

  /// A count query is billed at about one read per 1,000 customers.
  Future<int> countCustomers() async {
    final result = await FirebaseFirestore.instance
        .collection(FirestorePaths.users)
        .where('role', isEqualTo: AppStrings.roleUser)
        .count()
        .get();
    return result.count ?? 0;
  }
}