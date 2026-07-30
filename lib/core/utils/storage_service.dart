import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  // Token Sakla
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Token Oku
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Token Sil (Logout için)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}