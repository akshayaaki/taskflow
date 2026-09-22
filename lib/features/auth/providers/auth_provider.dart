import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/remote/auth_remote_service.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

final authRemoteServiceProvider = Provider<AuthRemoteService>((ref) {
  return AuthRemoteService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthRepositoryImpl(remote, prefs);
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  StreamSubscription? _authSubscription;

  AuthNotifier(this._repository) : super(AuthState.initial()) {
    _init();
  }

  void _init() {
    _authSubscription = _repository.authStateChanges.listen((user) {
      if (user != null) {
        state = AuthState.authenticated(user);
      } else if (_repository.isGuestMode) {
        state = AuthState.guest();
      } else {
        state = AuthState.unauthenticated();
      }
    });
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();
    try {
      await _repository.signInWithEmail(email: email, password: password);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = AuthState.loading();
    try {
      await _repository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = AuthState.loading();
    try {
      await _repository.signInWithGoogle();
      if (_repository.currentUser == null && !_repository.isGuestMode) {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> continueAsGuest() async {
    await _repository.setGuestMode(true);
    state = AuthState.guest();
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _repository.updatePassword(newPassword);
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = AuthState.loading();
    await _repository.signOut();
    state = AuthState.unauthenticated();
  }

  Future<void> deleteAccount() async {
    state = AuthState.loading();
    try {
      await _repository.deleteAccount();
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
