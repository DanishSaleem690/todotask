import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/firebase_error_mapper.dart';
import 'providers.dart';
import 'task_provider.dart';

/// Authentication state exposed to the UI layer.
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  final AppUser? user;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    bool? isInitialized,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService, this._ref) : super(const AuthState()) {
    _initialize();
  }

  final AuthService _authService;
  final Ref _ref;
  StreamSubscription<AppUser?>? _authSubscription;

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    _authSubscription = _authService.authStateChanges.listen(
      (user) async {
        if (user != null) {
          try {
            await _ref.read(taskRepositoryProvider).seedDummyData(user.id);
          } catch (_) {
            // Todos sync may fail if Firestore rules are not published yet.
          }
          state = state.copyWith(
            user: user,
            isLoading: false,
            isInitialized: true,
            clearError: true,
          );
        } else {
          _ref.read(taskListProvider.notifier).clear();
          state = state.copyWith(
            clearUser: true,
            isLoading: false,
            isInitialized: true,
            clearError: true,
          );
        }
      },
      onError: (_) {
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
          error: 'Failed to restore session.',
        );
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<String?> getRememberedEmail() => _authService.getRememberedEmail();

  Future<bool> isRememberMeEnabled() => _authService.isRememberMeEnabled();

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.login(email: email, password: password);
      await _authService.saveRememberedEmail(
        user.email,
        rememberMe: rememberMe,
      );
      state = state.copyWith(user: user, isLoading: false, clearError: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: FirebaseErrorMapper.authMessage(e),
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );
      await _authService.saveRememberedEmail(
        user.email,
        rememberMe: rememberMe,
      );
      state = state.copyWith(user: user, isLoading: false, clearError: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: FirebaseErrorMapper.authMessage(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.logout();
      _ref.read(taskListProvider.notifier).clear();
      state = state.copyWith(
        clearUser: true,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: FirebaseErrorMapper.authMessage(e),
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider), ref);
});
