import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/error/app_exception.dart';
import '../../core/network/firebase_config.dart';

class AuthRemoteService {
  FirebaseAuth? get _auth =>
      FirebaseConfig.isInitialized ? FirebaseAuth.instance : null;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges {
    if (_auth == null) {
      return Stream.value(null);
    }
    return _auth!.authStateChanges();
  }

  User? get currentUser => _auth?.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_auth == null) {
      throw const AuthException(
        'Firebase is not configured yet. Please follow README to add google-services.json / GoogleService-Info.plist, or continue in Offline/Guest mode.',
      );
    }
    try {
      return await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (_auth == null) {
      throw const AuthException(
        'Firebase is not configured yet. Please follow README to add google-services.json / GoogleService-Info.plist, or continue in Offline/Guest mode.',
      );
    }
    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (_auth == null) {
      throw const AuthException(
        'Firebase is not configured yet. Please configure Firebase Google Sign-In or continue in Offline/Guest mode.',
      );
    }
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User cancelled
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth!.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException('Google Sign In failed: ${e.toString()}');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (_auth == null) {
      throw const AuthException(
        'Firebase is not configured. Password reset requires active Firebase project.',
      );
    }
    try {
      await _auth!.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException('Failed to send reset email: ${e.toString()}');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    if (_auth == null || currentUser == null) {
      throw const AuthException('No active user logged in.');
    }
    try {
      await currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException('Failed to update password: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    if (_auth != null) {
      await Future.wait([
        _auth!.signOut(),
        _googleSignIn.signOut(),
      ]);
    }
  }

  Future<void> deleteAccount() async {
    if (_auth == null || currentUser == null) {
      throw const AuthException('No active user logged in.');
    }
    try {
      await currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException('Failed to delete account: ${e.toString()}');
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few moments and try again.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet.';
      case 'requires-recent-login':
        return 'This operation is sensitive and requires recent authentication. Please log in again.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
