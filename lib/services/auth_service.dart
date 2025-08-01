import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final SharedPreferences sharedPreferences;

  AuthService({required this.sharedPreferences});

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  Future<bool> isLoggedIn() async {
    return sharedPreferences.getString(_tokenKey) != null;
  }

  Future<void> saveAuthData(String token, String userId) async {
    await sharedPreferences.setString(_tokenKey, token);
    await sharedPreferences.setString(_userIdKey, userId);
  }

  Future<void> clearAuthData() async {
    await sharedPreferences.remove(_tokenKey);
    await sharedPreferences.remove(_userIdKey);
  }

  String? getToken() {
    return sharedPreferences.getString(_tokenKey);
  }

  String? getUserId() {
    return sharedPreferences.getString(_userIdKey);
  }
}
