import 'dart:async';

import 'package:app_links/app_links.dart';

class AuthDeepLink {
  const AuthDeepLink._();

  static const String scheme = 'pozit';
  static const String host = 'auth';
  static const String callbackPath = '/callback';
  static const String callbackUri = '$scheme://$host$callbackPath';

  static String? loginCodeFrom(Uri uri) {
    if (uri.scheme != scheme || uri.host != host || uri.path != callbackPath) {
      return null;
    }

    final loginCode = uri.queryParameters['loginCode']?.trim();
    return loginCode == null || loginCode.isEmpty ? null : loginCode;
  }
}

class AuthDeepLinkListener {
  AuthDeepLinkListener({AppLinks? appLinks})
    : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;

  void listen({required void Function(String loginCode) onLoginCode}) {
    _subscription?.cancel();
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      final loginCode = AuthDeepLink.loginCodeFrom(uri);
      if (loginCode != null) {
        onLoginCode(loginCode);
      }
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}
