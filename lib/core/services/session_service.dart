import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyLoggedIn = 'is_logged_in';
  static const _keyUserEmail = 'user_email';
  static const _keyUserId = 'user_id';

  Future<void> saveSession(int userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setInt(_keyUserId, userId);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserId);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  Future<String?> getLoggedUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  Future<int?> getLoggedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }
}
