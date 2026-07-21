import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'login_token.dart';

class AuthTokenStorage {
  const AuthTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _accessTokenKey = 'pozit_access_token';
  static const String _tokenTypeKey = 'pozit_token_type';

  final FlutterSecureStorage _storage;

  Future<void> save(LoginToken token) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: token.accessToken),
      _storage.write(key: _tokenTypeKey, value: token.tokenType),
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
