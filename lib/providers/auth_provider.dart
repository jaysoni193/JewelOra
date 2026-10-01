import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/errors/auth_exception.dart';
import 'package:jewel_ora/models/app_user.dart';
import 'package:jewel_ora/services/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  StreamSubscription<User?>? _sub;

  AuthStatus _status = AuthStatus.initial;
  AppUser? _user;
  bool _isLoading = false;
  bool _isRegistering = false;
  String? _errorMessage;

  AuthProvider(this._service) {
    _sub = _service.authStateChanges.listen(_onAuthChanged);
  }

  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _user?.isAdmin ?? false;

  // Runs at app start and whenever login state changes.
  Future<void> _onAuthChanged(User? firebaseUser) async {
    // During registration, register() sets the user itself.
    if (_isRegistering) return;

    if (firebaseUser == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
    } else {
      try {
        _user = await _service.getUserProfile(firebaseUser.uid);
        _status = AuthStatus.authenticated;
      } catch (_) {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      _user = await _service.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = AppStrings.somethingWentWrong;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    _errorMessage = null;
    _isRegistering = true;
    _setLoading(true);
    try {
      _user = await _service.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      _status = AuthStatus.authenticated;
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = AppStrings.somethingWentWrong;
      return false;
    } finally {
      _isRegistering = false;
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _errorMessage = null;
    try {
      await _service.sendPasswordReset(email);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = AppStrings.somethingWentWrong;
      return false;
    }
  }

  Future<void> logout() => _service.logout();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}