import '../models/user.dart';
import '../repositories/auth_repository.dart';
import 'user_prefs_service.dart';

/// Handles authentication business logic via Firebase Auth.
class AuthService {
  AuthService(this._repository, this._prefsService);

  final AuthRepository _repository;
  final UserPrefsService _prefsService;

  Stream<AppUser?> get authStateChanges {
    return _repository.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _repository.getCurrentUser();
    });
  }

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.signUp(
      name: name,
      email: email,
      password: password,
    );
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }

  Future<void> logout() => _repository.logout();

  Future<AppUser?> getCurrentUser() => _repository.getCurrentUser();

  Future<void> saveRememberedEmail(String email, {required bool rememberMe}) {
    return _prefsService.saveRememberedEmail(email, rememberMe: rememberMe);
  }

  Future<String?> getRememberedEmail() => _prefsService.getRememberedEmail();

  Future<bool> isRememberMeEnabled() => _prefsService.isRememberMeEnabled();
}
