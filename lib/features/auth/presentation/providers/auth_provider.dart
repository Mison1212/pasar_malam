import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pasar_malam/core/services/secure_storage.dart';
import 'package:pasar_malam/core/services/dio_client.dart';
import 'package:pasar_malam/core/constants/api_constants.dart';

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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  String? _backendToken;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  String? get backendToken => _backendToken;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = userCredential.user;

      await _firebaseUser?.updateDisplayName(name);
      await _firebaseUser?.sendEmailVerification();

      _status = AuthStatus.emailNotVerified;
      _errorMessage = null;
      notifyListeners();

      
      await _syncUserToMySQL(_firebaseUser!);

      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = userCredential.user;

      await _firebaseUser?.reload();

      if (!(_firebaseUser?.emailVerified ?? false)) {
        _status = AuthStatus.emailNotVerified;
        notifyListeners();
        return false;
      }

      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();

      
      await _syncUserToMySQL(_firebaseUser!);

      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading();

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        final userCredential = await _auth.signInWithPopup(googleProvider);
        _firebaseUser = userCredential.user;
      } else {
        GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
        googleUser ??= await _googleSignIn.signIn();

        if (googleUser == null) {
          _status = AuthStatus.unauthenticated;
          notifyListeners();
          return false;
        }

        final googleAuth = await googleUser.authentication;
        if (googleAuth.accessToken == null) {
          throw Exception('Access token null');
        }

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        _firebaseUser = userCredential.user;
      }

      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();

      await _syncUserToMySQL(_firebaseUser!);

      return true;
    } catch (e) {
      _setError('Google Sign-In gagal: $e');
      return false;
    }
  }

  Future<void> _syncUserToMySQL(User user) async {
    try {
      final response = await DioClient.instance.post(
        ApiConstants.saveUser,
        data: {
          'firebase_uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photo_url': user.photoURL ?? '',
          'provider': user.providerData.isNotEmpty
              ? user.providerData.first.providerId
              : 'password',
        },
      );
      debugPrint('[SYNC] Berhasil: ${response.data}');
    } catch (e) {
      debugPrint('[SYNC ERROR] Detail: $e');
    }
  }

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
      _setError('Sign out gagal: $e');
    }
  }

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
      _setError('Gagal kirim email verifikasi: $e');
      return false;
    }
  }

  Future<bool> checkEmailVerified() async {
    try {
      if (_firebaseUser == null) return false;

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
      _setError('Gagal cek verifikasi: $e');
      return false;
    }
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Password salah.';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }
}