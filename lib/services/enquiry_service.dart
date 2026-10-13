import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/core/firebase/firebase_logger.dart';
import 'package:jewel_ora/models/enquiry_model.dart';

class EnquiryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection(FirestorePaths.enquiries);

  Future<String> createEnquiry(EnquiryModel enquiry) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.enquiries,
      operation: 'createEnquiry',
      parameters: {
        'userId': enquiry.userId,
        'itemCount': enquiry.items.length,
        'totalAmount': enquiry.totalAmount,
      },
    );

    try {
      final docRef = await _collection.add(enquiry.toMap());
      FirebaseLogger.response(
        collection: FirestorePaths.enquiries,
        operation: 'createEnquiry',
        documentId: docRef.id,
        duration: DateTime.now().difference(startTime),
      );
      return docRef.id;
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.enquiries,
        operation: 'createEnquiry',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Stream<List<EnquiryModel>> streamUserEnquiries(String userId) {
    FirebaseLogger.request(
      collection: FirestorePaths.enquiries,
      operation: 'streamUserEnquiries',
      parameters: {'userId': userId},
    );

    return _collection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((doc) => EnquiryModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));
      return list;
    });
  }

  Stream<List<EnquiryModel>> streamAllEnquiries() {
    FirebaseLogger.request(
      collection: FirestorePaths.enquiries,
      operation: 'streamAllEnquiries',
    );

    return _collection.snapshots().map((snap) {
      final list = snap.docs
          .map((doc) => EnquiryModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));
      return list;
    });
  }

  Future<void> updateStatus(String enquiryId, String status) async {
    final startTime = DateTime.now();
    FirebaseLogger.request(
      collection: FirestorePaths.enquiries,
      operation: 'updateStatus',
      documentId: enquiryId,
      parameters: {'status': status},
    );

    try {
      await _collection.doc(enquiryId).update({'status': status});
      FirebaseLogger.response(
        collection: FirestorePaths.enquiries,
        operation: 'updateStatus',
        documentId: enquiryId,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, st) {
      FirebaseLogger.error(
        collection: FirestorePaths.enquiries,
        operation: 'updateStatus',
        documentId: enquiryId,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
