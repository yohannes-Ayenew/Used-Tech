import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getLastToken(); // Changed to nullable String?
  Future<void> logout();
}

const CACHED_TOKEN = 'CACHED_TOKEN';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheToken(String token) {
    return sharedPreferences.setString(CACHED_TOKEN, token);
  }

  @override
  Future<String?> getLastToken() async {
    // Returns the token string or null if not found
    return sharedPreferences.getString(CACHED_TOKEN);
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.remove(CACHED_TOKEN);
  }
}
