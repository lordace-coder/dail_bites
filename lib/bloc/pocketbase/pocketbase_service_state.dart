import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackendService {
  static const String modelKey = 'models';
  static const String tokenKey = 'token';
  final PocketBase pb;
  final SharedPreferences prefs;

  BackendService({
    required this.pb,
    required this.prefs,
  });

  /// Initializes PocketBase AuthStore from SharedPreferences
  Future<void> initializeAuthStore() async {
    try {
      // Get stored auth data
      final storedAuth = prefs.getString(modelKey);
      final token = prefs.getString(tokenKey);

      if (storedAuth != null) {
        // Convert stored JSON string to AuthStore model
        final authStore = jsonDecode(storedAuth);

        // Set the auth store in PocketBase instance
        pb.authStore.save(token!, authStore);

        // Validate the token
        final valid = pb.authStore.isValid;

        if (!valid) {
          // Clear invalid auth data
          await clearAuthStore();
        }
      }
    } catch (e) {
      // Handle initialization errors
      await clearAuthStore();
      rethrow;
    }
  }

  /// Updates AuthStore in SharedPreferences whenever it changes
  Future<void> updateAuthStore(
      {required String token, required String model}) async {
    try {
      if (pb.authStore.isValid) {
        // Convert current AuthStore to JSON and save

        await prefs.setString(modelKey, model);
        await prefs.setString(tokenKey, token);
      } else {
        // Clear stored auth data if invalid
        await clearAuthStore();
      }
    } catch (e) {
      await clearAuthStore();
      rethrow;
    }
  }

  /// Helper method to clear auth data
  Future<void> clearAuthStore() async {
    await prefs.remove(modelKey);
    await prefs.remove(tokenKey);
    pb.authStore.clear();
  }
}
