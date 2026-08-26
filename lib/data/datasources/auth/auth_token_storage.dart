import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class AuthTokenStorage {
  const AuthTokenStorage({FlutterSecureStorage? storage, Uuid? uuid})
    : _storage = storage ?? const FlutterSecureStorage(),
      _uuid = uuid ?? const Uuid();

  static const String _accessTokenKey = 'pozit_access_token';
  static const String _refreshTokenKey = 'pozit_refresh_token';
  static const String _tokenTypeKey = 'pozit_token_type';
  static const String _userIdKey = 'pozit_user_id';
  static const String _deviceIdKey = 'pozit_device_id';
  static Future<void> _mutationQueue = Future<void>.value();

  final FlutterSecureStorage _storage;
  final Uuid _uuid;

  Future<void> save({
    required String accessToken,
    String? refreshToken,
    required String tokenType,
    required int userId,
  }) async {
    await _mutate(() async {
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        refreshToken == null
            ? _storage.delete(key: _refreshTokenKey)
            : _storage.write(key: _refreshTokenKey, value: refreshToken),
        _storage.write(key: _tokenTypeKey, value: tokenType),
        _storage.write(key: _userIdKey, value: userId.toString()),
      ]);
    });
  }

  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> readRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<bool> saveReissuedTokens({
    required String expectedRefreshToken,
    required String accessToken,
    required String refreshToken,
  }) async {
    return _mutate(() async {
      final currentRefreshToken = await _storage.read(key: _refreshTokenKey);
      if (currentRefreshToken != expectedRefreshToken) return false;
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
      ]);
      return true;
    });
  }

  Future<int?> readUserId() async {
    final raw = await _storage.read(key: _userIdKey);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  Future<String> readOrCreateDeviceId() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final generated = _uuid.v4();
    await _storage.write(key: _deviceIdKey, value: generated);
    return generated;
  }

  Future<void> clear() async {
    await _mutate(() async {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _tokenTypeKey),
        _storage.delete(key: _userIdKey),
      ]);
    });
  }

  Future<T> _mutate<T>(Future<T> Function() action) {
    final operation = _mutationQueue.then((_) => action());
    _mutationQueue = operation.then<void>((_) {}, onError: (_, _) {});
    return operation;
  }
}
