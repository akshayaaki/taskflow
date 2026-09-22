import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../remote/auth_remote_service.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  bool get isGuestMode;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signInWithGoogle();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updatePassword(String newPassword);
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<void> setGuestMode(bool isGuest);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteService _remoteService;
  final SharedPreferences _prefs;

  static const String _keyGuestMode = 'is_guest_mode';

  AuthRepositoryImpl(this._remoteService, this._prefs);

  @override
  Stream<User?> get authStateChanges => _remoteService.authStateChanges;

  @override
  User? get currentUser => _remoteService.currentUser;

  @override
  bool get isGuestMode => _prefs.getBool(_keyGuestMode) ?? false;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _remoteService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await setGuestMode(false);
  }

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await _remoteService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
    await setGuestMode(false);
  }

  @override
  Future<void> signInWithGoogle() async {
    final result = await _remoteService.signInWithGoogle();
    if (result != null) {
      await setGuestMode(false);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _remoteService.sendPasswordResetEmail(email);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _remoteService.updatePassword(newPassword);
  }

  @override
  Future<void> signOut() async {
    await _remoteService.signOut();
    await setGuestMode(false);
  }

  @override
  Future<void> deleteAccount() async {
    await _remoteService.deleteAccount();
    await setGuestMode(false);
  }

  @override
  Future<void> setGuestMode(bool isGuest) async {
    await _prefs.setBool(_keyGuestMode, isGuest);
  }
}
