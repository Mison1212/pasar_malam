import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pasar_malam/core/services/secure_storage.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailNotVerified,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  String? _backendToken;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  String? get backendToken => _backendToken;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  /// Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      // Create user with Firebase
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = userCredential.user;

      // Update user profile with name
      await _firebaseUser?.updateDisplayName(name);

      // Send verification email
      await _firebaseUser?.sendEmailVerification();

      _status = AuthStatus.emailNotVerified;
      _errorMessage = null;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getFirebaseErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login({required String email, required String password}) async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = userCredential.user;

      // Check if email is verified
      await _firebaseUser?.reload();
      if (!(_firebaseUser?.emailVerified ?? false)) {
        _status = AuthStatus.emailNotVerified;
        notifyListeners();
        return false;
      }

      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getFirebaseErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _firebaseUser = userCredential.user;

      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Google Sign-In gagal: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await SecureStorageService.clearAll();

      _firebaseUser = null;
      _backendToken = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Sign out gagal: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Resend verification email
  Future<bool> resendVerificationEmail() async {
    try {
      if (_firebaseUser == null) {
        _errorMessage = 'User tidak ditemukan';
        return false;
      }

      await _firebaseUser!.sendEmailVerification();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengirim email verifikasi: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Check if email has been verified
  Future<bool> checkEmailVerified() async {
    try {
      if (_firebaseUser == null) {
        return false;
      }

      await _firebaseUser!.reload();
      _firebaseUser = _auth.currentUser;

      if (_firebaseUser?.emailVerified ?? false) {
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage = 'Gagal memeriksa verifikasi email: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get Firebase error message in Indonesian
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 8 karakter.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Password salah.';
      default:
        return 'Terjadi kesalahan authentication: $code';
    }
  }
}
