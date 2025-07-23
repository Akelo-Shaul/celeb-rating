import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static StorageService? _instance;
  final FlutterSecureStorage _storage;

  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  StorageService._() : _storage = const FlutterSecureStorage();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  Future<void> storeAuthData({
    required String token,
    required String userId,
    required String role,
  }) async {
    await Future.wait([
      _storage.write(key: _authTokenKey, value: token),
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _userRoleKey, value: role),
    ]);
  }

  Future<Map<String, String?>> getAuthData() async {
    return {
      'token': await _storage.read(key: _authTokenKey),
      'userId': await _storage.read(key: _userIdKey),
      'role': await _storage.read(key: _userRoleKey),
    };
  }

  Future<void> clearAuthData() async {
    await Future.wait([
      _storage.delete(key: _authTokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _userRoleKey),
    ]);
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: _authTokenKey);
    return token != null;
  }
}
