import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around FlutterSecureStorage with named helpers.
class SecureStorage {
  static const _storage = FlutterSecureStorage();

  // ── User identity ──────────────────────────────
  Future<void> saveUserId(String id) =>
      _storage.write(key: 'user_id', value: id);
  Future<String?> getUserId() => _storage.read(key: 'user_id');

  // ── Auth token ─────────────────────────────────
  Future<void> saveToken(String token) =>
      _storage.write(key: 'jwt_token', value: token);
  Future<String?> getToken() => _storage.read(key: 'jwt_token');
  Future<void> deleteToken() => _storage.delete(key: 'jwt_token');

  // ── Generic ────────────────────────────────────
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> delete(String key) => _storage.delete(key: key);
}
