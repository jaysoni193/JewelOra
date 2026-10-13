import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:jewel_ora/models/enquiry_model.dart';
import 'package:jewel_ora/services/enquiry_service.dart';

class EnquiryProvider extends ChangeNotifier {
  final EnquiryService _service;
  StreamSubscription<List<EnquiryModel>>? _sub;

  List<EnquiryModel> _userEnquiries = [];
  List<EnquiryModel> _allEnquiries = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;
  bool _isAdmin = false;

  EnquiryProvider(this._service);

  List<EnquiryModel> get userEnquiries => _userEnquiries;
  List<EnquiryModel> get allEnquiries => _allEnquiries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateUser(String? uid, {bool isAdmin = false}) {
    if (_currentUserId == uid && _isAdmin == isAdmin) return;
    _currentUserId = uid;
    _isAdmin = isAdmin;
    _sub?.cancel();

    if (_isAdmin) {
      _listenAll();
    } else if (uid != null && uid.isNotEmpty) {
      _listenUser(uid);
    } else {
      _userEnquiries = [];
      _allEnquiries = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  void _listenUser(String uid) {
    _isLoading = true;
    notifyListeners();

    _sub = _service.streamUserEnquiries(uid).listen(
      (list) {
        _userEnquiries = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _isLoading = false;
        _errorMessage = 'Failed to load enquiries';
        notifyListeners();
      },
    );
  }

  void _listenAll() {
    _isLoading = true;
    notifyListeners();

    _sub = _service.streamAllEnquiries().listen(
      (list) {
        _allEnquiries = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _isLoading = false;
        _errorMessage = 'Failed to load enquiries';
        notifyListeners();
      },
    );
  }

  Future<String?> recordEnquiry(EnquiryModel enquiry) async {
    try {
      final id = await _service.createEnquiry(enquiry);
      return id;
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateStatus(String enquiryId, String status) async {
    try {
      await _service.updateStatus(enquiryId, status);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
