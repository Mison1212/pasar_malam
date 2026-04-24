import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataStorage {
  static String _cartKey(String userId) => 'cart_$userId';
  static String _likesKey(String userId) => 'likes_$userId';


  static Future<void> saveCart(
      String userId, List<Map<String, dynamic>> cartJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartKey(userId), jsonEncode(cartJson));
  }

  static Future<List<Map<String, dynamic>>> loadCart(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartKey(userId));
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }


  static Future<void> saveLikes(String userId, List<int> likedIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_likesKey(userId), jsonEncode(likedIds));
  }

  static Future<Set<int>> loadLikes(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_likesKey(userId));
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map<int>((e) => e as int).toSet();
    } catch (_) {
      return {};
    }
  }
}
