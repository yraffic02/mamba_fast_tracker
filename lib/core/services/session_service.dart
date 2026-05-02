import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyLoggedIn = 'is_logged_in';
  static const _keyUserEmail = 'user_email';
  static const _keyUserId = 'user_id';
  static const _keyFastingProtocol = 'fasting_protocol';
  static const _keyScheduledStartTime = 'scheduled_start_time';

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

  Future<void> saveFastingProtocol(String protocolName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFastingProtocol, protocolName);
  }

  Future<String> getFastingProtocol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFastingProtocol) ?? '16:8';
  }

  Future<void> saveScheduledStartTime(DateTime startTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyScheduledStartTime, startTime.toIso8601String());
  }

  Future<DateTime?> getScheduledStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyScheduledStartTime);
    if (str != null) {
      return DateTime.parse(str);
    }
    return null;
  }

  Future<void> clearScheduledStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyScheduledStartTime);
  }
}
