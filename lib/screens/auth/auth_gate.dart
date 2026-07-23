import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../data/datasources/auth/auth_token_storage.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

enum _AuthGateStatus { checking, signedOut, signedIn }

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    this.readAccessToken,
    this.clearToken,
    this.validateSession,
    this.retryDelay = const Duration(milliseconds: 300),
  });

  final Future<String?> Function()? readAccessToken;
  final Future<void> Function()? clearToken;
  final Future<void> Function()? validateSession;
  final Duration retryDelay;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  static const int _maxRetryCount = 2;
  static const String _sessionCheckFailureMessage =
      '로그인 상태를 확인하지 못했어요. 다시 로그인해 주세요.';

  _AuthGateStatus _status = _AuthGateStatus.checking;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    if (mounted && _status != _AuthGateStatus.checking) {
      setState(() => _status = _AuthGateStatus.checking);
    }

    final tokenStorage = const AuthTokenStorage();
    final readAccessToken =
        widget.readAccessToken ?? tokenStorage.readAccessToken;
    final clearToken = widget.clearToken ?? tokenStorage.clear;
    final validateSession = widget.validateSession ?? _validateSession;

    try {
      final accessToken = await readAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        _setStatus(_AuthGateStatus.signedOut);
        return;
      }

      await _validateSessionWithRetry(validateSession);
      _setStatus(_AuthGateStatus.signedIn);
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await clearToken();
        _setStatus(_AuthGateStatus.signedOut);
        return;
      }

      await _clearTokenAndReturnToLogin(clearToken);
    } catch (_) {
      await _clearTokenAndReturnToLogin(clearToken);
    }
  }

  Future<void> _validateSessionWithRetry(
    Future<void> Function() validateSession,
  ) async {
    for (var attempt = 0; ; attempt++) {
      try {
        await validateSession();
        return;
      } on ApiException catch (error) {
        if (error.statusCode == 401 || error.statusCode == 403) rethrow;
        if (attempt >= _maxRetryCount) rethrow;
      } catch (_) {
        if (attempt >= _maxRetryCount) rethrow;
      }

      await Future<void>.delayed(widget.retryDelay);
    }
  }

  Future<void> _clearTokenAndReturnToLogin(
    Future<void> Function() clearToken,
  ) async {
    await clearToken();
    _setStatus(_AuthGateStatus.signedOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(_sessionCheckFailureMessage)),
      );
    });
  }

  Future<void> _validateSession() async {
    await DioClient.instance.get('/api/users/me');
  }

  void _setStatus(_AuthGateStatus status) {
    if (!mounted) return;
    setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_status) {
      _AuthGateStatus.checking => const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      _AuthGateStatus.signedOut => const LoginScreen(),
      _AuthGateStatus.signedIn => const HomeScreen(),
    };
  }
}
