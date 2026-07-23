import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../data/datasources/auth/auth_token_storage.dart';
import '../home/temporary_home_screen.dart';
import 'login_screen.dart';

enum _AuthGateStatus { checking, signedOut, signedIn, error }

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    this.readAccessToken,
    this.clearToken,
    this.validateSession,
  });

  final Future<String?> Function()? readAccessToken;
  final Future<void> Function()? clearToken;
  final Future<void> Function()? validateSession;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  _AuthGateStatus _status = _AuthGateStatus.checking;
  String _errorMessage = '로그인 상태를 확인하지 못했어요.';

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

      await validateSession();
      _setStatus(_AuthGateStatus.signedIn);
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await clearToken();
        _setStatus(_AuthGateStatus.signedOut);
        return;
      }
      _setError(error.message);
    } catch (_) {
      _setError('로그인 상태를 확인하지 못했어요. 다시 시도해 주세요.');
    }
  }

  Future<void> _validateSession() async {
    await DioClient.instance.get('/api/users/me');
  }

  void _setStatus(_AuthGateStatus status) {
    if (!mounted) return;
    setState(() => _status = status);
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _status = _AuthGateStatus.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_status) {
      _AuthGateStatus.checking => const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      _AuthGateStatus.signedOut => const LoginScreen(),
      _AuthGateStatus.signedIn => const TemporaryHomeScreen(),
      _AuthGateStatus.error => Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.text),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: '다시 시도',
                  width: 160,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: AppTextStyles.body,
                  onPressed: _checkSession,
                ),
              ],
            ),
          ),
        ),
      ),
    };
  }
}

@Preview(group: 'hycho', name: 'Auth Gate Error', size: Size(393, 852))
Widget authGateErrorPreview() {
  return MaterialApp(
    home: AuthGate(
      readAccessToken: () async => 'preview-token',
      validateSession: () async {
        throw const ApiException('네트워크 연결을 확인해 주세요.');
      },
    ),
  );
}
