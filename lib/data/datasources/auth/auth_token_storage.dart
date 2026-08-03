import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  const AuthTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _accessTokenKey = 'pozit_access_token';
  static const String _tokenTypeKey = 'pozit_token_type';
  static const String _userIdKey = 'pozit_user_id';

  final FlutterSecureStorage _storage;

  Future<void> save({
    required String accessToken,
    required String tokenType,
    required int userId,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _tokenTypeKey, value: tokenType),
      _storage.write(key: _userIdKey, value: userId.toString()),
    ]);
  }

  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<int?> readUserId() async {
    final raw = await _storage.read(key: _userIdKey);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _tokenTypeKey),
      _storage.delete(key: _userIdKey),
    ]);
  }
}
