import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'revola_auth_token';
  static const String _activeRoleKey = 'revola_active_role';
  static const String _favoritesKey = 'revola_favorites';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
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
    await _prefs.setString(_activeRoleKey, role);
  }

  String? getActiveRole() {
    return _prefs.getString(_activeRoleKey);
  }

  // Favorites persistence
  List<String> getFavoriteIds() {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> toggleFavorite(String productId) async {
    final list = getFavoriteIds().toList();
    if (list.contains(productId)) {
      list.remove(productId);
    } else {
      list.add(productId);
    }
    await _prefs.setStringList(_favoritesKey, list);
  }
}
