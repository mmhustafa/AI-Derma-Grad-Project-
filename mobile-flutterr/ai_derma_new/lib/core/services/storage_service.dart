// lib/core/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';

/// Handles local persistence of the JWT token and the logged-in username.
/// All methods are static for convenience.
class StorageService {
  StorageService._();

  static const _keyToken = 'auth_token';
  static const _keyUsername = 'auth_username';

  // ─── Token ──────────────────────────────────────────────────────────────────

  /// Persists the JWT token returned from the login API.
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  /// Returns the stored JWT token, or null if the user is not logged in.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Removes the stored token (logout).
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  // ─── Username ────────────────────────────────────────────────────────────────

  /// Persists the username extracted from the login flow.
  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
  }

  /// Returns the stored username, or null if not set.
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  /// Removes the stored username (logout).
  static Future<void> clearUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
  }

  // ─── Auth State ──────────────────────────────────────────────────────────────

  /// Convenience method: returns true if a JWT token is stored.
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clears all auth-related data (full logout).
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUsername);
  }
}
