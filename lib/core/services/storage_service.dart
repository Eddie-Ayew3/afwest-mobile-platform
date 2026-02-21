import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Token Management
  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> removeToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  // User Data Management
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: AppConstants.userKey, value: jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final userDataString = await _storage.read(key: AppConstants.userKey);
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> removeUserData() async {
    await _storage.delete(key: AppConstants.userKey);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Generic storage methods
  Future<void> saveString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<bool?> getBool(String key) async {
    final value = await _storage.read(key: key);
    if (value != null) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }

  Future<void> saveInt(String key, int value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<int?> getInt(String key) async {
    final value = await _storage.read(key: key);
    if (value != null) {
      return int.tryParse(value);
    }
    return null;
  }

  Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  Future<bool> containsKey(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }
}
