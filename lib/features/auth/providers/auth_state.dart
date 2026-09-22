import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  guest,
  error;

  bool get isAuthenticated => this == AuthStatus.authenticated;
  bool get isGuest => this == AuthStatus.guest;
  bool get hasAccess => isAuthenticated || isGuest;
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(User user) =>
      AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.guest() => const AuthState(status: AuthStatus.guest);
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.error(String message) =>
      AuthState(status: AuthStatus.error, errorMessage: message);

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
