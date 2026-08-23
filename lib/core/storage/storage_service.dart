import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'revola_auth_token';
  static const String _activeRoleKey = 'revola_active_role';
  static const String _userCacheKey = 'revola_cached_user';
  static const String _favoritesKey = 'revola_favorites';
  static const String _themeModeKey = 'revola_theme_mode';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Appearance / Theme Mode persistence
  Future<void> saveThemeMode(String mode) async {
    try {
      await _prefs.setString(_themeModeKey, mode);
    } catch (_) {}
  }

  String getThemeMode() {
    try {
      return _prefs.getString(_themeModeKey) ?? 'system';
    } catch (_) {
      return 'system';
    }
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // Active role persistence
  Future<void> saveActiveRole(String role) async {
    try {
      await _prefs.setString(_activeRoleKey, role);
    } catch (_) {}
  }

  String? getActiveRole() {
    try {
      return _prefs.getString(_activeRoleKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearActiveRole() async {
    try {
      await _prefs.remove(_activeRoleKey);
    } catch (_) {}
  }

  // User Profile Cache (for immediate offline hydration)
  Future<void> saveUserCache(String userJson) async {
    try {
      await _prefs.setString(_userCacheKey, userJson);
    } catch (_) {}
  }

  String? getUserCache() {
    try {
      return _prefs.getString(_userCacheKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUserCache() async {
    try {
      await _prefs.remove(_userCacheKey);
    } catch (_) {}
  }

  // Favorites persistence
  List<String> getFavoriteIds() {
    try {
      return _prefs.getStringList(_favoritesKey) ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<void> toggleFavorite(String productId) async {
    try {
      final list = getFavoriteIds().toList();
      if (list.contains(productId)) {
        list.remove(productId);
      } else {
        list.add(productId);
      }
      await _prefs.setStringList(_favoritesKey, list);
    } catch (_) {}
  }

  // Session Cleanup: clears user auth, role, and cache while keeping theme settings intact
  Future<void> clearSession() async {
    await clearToken();
    await clearActiveRole();
    await clearUserCache();
  }

  // Full storage reset
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    try {
      await _prefs.clear();
    } catch (_) {}
  }
}

