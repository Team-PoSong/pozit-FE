import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  const AuthTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _accessTokenKey = 'pozit_access_token';
  static const String _tokenTypeKey = 'pozit_token_type';

  final FlutterSecureStorage _storage;

  Future<void> save({
    required String accessToken,
    required String tokenType,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _tokenTypeKey, value: tokenType),
    ]);
  }

  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _tokenTypeKey),
    ]);
  }
}
