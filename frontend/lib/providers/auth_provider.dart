import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  Future<void> checkAuth() async {
    try {
      final user = await _authService.getSavedUser();
      final token = user?.token ?? await _authService.getSavedToken();
      if (user != null && token != null && token.isNotEmpty) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else if (token != null && token.isNotEmpty) {
        // Legacy token-only sessions: treat as logged out so role routing works.
        await _authService.logout();
        state = const AuthState(status: AuthStatus.unauthenticated);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password, UserRole role) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.login(email, password, role);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<String?> applyForRegistration({
    required String type,
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final message = await _authService.applyForRegistration(
        type: type,
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      state = state.copyWith(isLoading: false);
      return message;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {
      // Storage failures should not block sign-out.
    }
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void markUnauthenticated() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService());
});
