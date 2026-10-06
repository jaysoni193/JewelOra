import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/core/errors/auth_exception.dart';
import 'package:jewel_ora/models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(FirestorePaths.users);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------- REGISTER ----------
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e));
    }

    final firebaseUser = cred.user!;
    final appUser = AppUser(
      uid: firebaseUser.uid,
      name: name,
      email: email,
      phone: phone,
      role: AppStrings.roleUser, // everyone starts as a normal user
    );

    try {
      await _users.doc(firebaseUser.uid).set(appUser.toMap());
      await firebaseUser.updateDisplayName(name);
    } catch (_) {
      // Roll back, so we never keep an account without a profile document.
      await firebaseUser.delete();
      throw const AuthException(
          'Could not create your profile. Please try again.');
    }
    return appUser;
  }

  // ---------- LOGIN ----------
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await getUserProfile(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e));
    }
  }

  // ---------- PROFILE ----------
  /// Reads users/{uid}. If the document is missing (for example an account
  /// created manually in the console), a default profile is created.
  Future<AppUser> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromMap(doc.data()!, uid);
    }

    final fbUser = _auth.currentUser;
    final fallback = AppUser(
      uid: uid,
      name: fbUser?.displayName ?? 'User',
      email: fbUser?.email ?? '',
      role: AppStrings.roleUser,
    );
    await _users.doc(uid).set(fallback.toMap());
    return fallback;
  }

  // ---------- PASSWORD RESET ----------
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e));
    }
  }

  // ---------- UPDATE PROFILE ----------
  Future<AppUser> updateProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    try {
      await _users.doc(uid).update({'name': name, 'phone': phone});
      await _auth.currentUser?.updateDisplayName(name);
      return await getUserProfile(uid);
    } catch (_) {
      throw const AuthException(AppStrings.somethingWentWrong);
    }
  }

  // ---------- CHANGE PASSWORD ----------
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw const AuthException('Please login again.');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw const AuthException('Current password is incorrect.');
      }
      throw AuthException(_mapError(e));
    }
  }
  // ---------- LOGOUT ----------
  Future<void> logout() => _auth.signOut();

  // ---------- ERROR MESSAGES ----------
  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'requires-recent-login':
        return 'Please logout and login again, then retry.';
      default:
        return AppStrings.somethingWentWrong;
    }
  }
}