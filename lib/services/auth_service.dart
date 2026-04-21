import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userKey);
    
    if (userJson != null) {
      final user = UserModel.fromJson(json.decode(userJson));
      if (user.email == email) {
        // In a real app, you'd check password too. Since it's local/mock:
        await prefs.setBool(AppConstants.isLoggedInKey, true);
        return true;
      }
    }
    return false;
  }

  Future<void> signup(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
    );
    
    await prefs.setString(AppConstants.userKey, json.encode(user.toJson()));
    await prefs.setBool(AppConstants.isLoggedInKey, true);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isLoggedInKey, false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }
    return null;
  }
}
