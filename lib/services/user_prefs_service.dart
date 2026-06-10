import 'package:shared_preferences/shared_preferences.dart';

import '../storage/storage_keys.dart';

/// Local preferences for theme and remembered login email.
class UserPrefsService {
  UserPrefsService._();

  static final UserPrefsService instance = UserPrefsService._();

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs => _prefs;

  Future<void> saveRememberedEmail(String email, {required bool rememberMe}) async {
    await _prefs.setBool(StorageKeys.rememberMe, rememberMe);
    if (rememberMe) {
      await _prefs.setString(StorageKeys.rememberedEmail, email);
    } else {
      await _prefs.remove(StorageKeys.rememberedEmail);
    }
  }

  Future<String?> getRememberedEmail() async {
    final remember = _prefs.getBool(StorageKeys.rememberMe) ?? false;
    if (!remember) return null;
    return _prefs.getString(StorageKeys.rememberedEmail);
  }

  Future<bool> isRememberMeEnabled() async {
    return _prefs.getBool(StorageKeys.rememberMe) ?? false;
  }
}
