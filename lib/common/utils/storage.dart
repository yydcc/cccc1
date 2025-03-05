import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  static Future<StorageService> get instance async {
    if (_instance == null) {
      _instance = StorageService();
      _preferences = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  Future<bool> setToken(String token) async {
    return await _preferences!.setString('token', token);
  }

  String? getToken() {
    return _preferences!.getString('token');
  }

  Future<bool> removeToken() async {
    return await _preferences!.remove('token');
  }

  Future<bool> setRole(String role) async {
    return await _preferences!.setString('role', role);
  }

  String? getRole() {
    return _preferences!.getString('role');
  }

  Future<bool> setUsername(String username) async {
    return await _preferences!.setString('username', username);
  }

  String? getUsername() {
    return _preferences!.getString('username');
  }
  String? getAvatarUrl(){
    return _preferences!.getString('avatar');
  }
  Future<bool> setAvaterUrl(String avatarUrl)async{
    return await _preferences!.setString('avatar', avatarUrl);
  }


} 