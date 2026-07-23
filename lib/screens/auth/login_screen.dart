import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/network/api_exception.dart';
import '../../data/datasources/auth/kakao_login_service.dart';
import '../../data/repositories/auth/auth_repository.dart';
import '../onboarding/onboarding_flow_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onAppleLogin,
    this.onKakaoLogin,
    this.onKakaoAccessToken,
    this.assetPackage,
  });

  final VoidCallback? onAppleLogin;
  final FutureOr<void> Function()? onKakaoLogin;
  final Future<void> Function(String accessToken)? onKakaoAccessToken;
  final String? assetPackage;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const double _carrierWidth = 231.3;
  static const double _carrierAspectRatio = 257 / 176;

  bool _isLoggingIn = false;

  Future<void> _handleKakaoLogin(BuildContext context) async {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    try {
      if (widget.onKakaoLogin case final callback?) {
        await callback();
        return;
      }

      final accessToken = await const KakaoLoginService().login();
      if (widget.onKakaoAccessToken case final callback?) {
        await callback(accessToken);
      } else {
        await AuthRepository().loginWithKakaoAccessToken(accessToken);
      }

      if (!context.mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const OnboardingFlowScreen()),
      );
    } on KakaoLoginCanceledException {
      return;
    } on ApiException catch (error, stackTrace) {
      _reportLoginError(error, stackTrace);
      if (context.mounted) {
        _showLoginError(context, error.message);
      }
    } catch (error, stackTrace) {
      _reportLoginError(error, stackTrace);
      if (context.mounted) {
        _showLoginError(context, '카카오 로그인에 실패했어요. 다시 시도해 주세요.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingIn = false);
      }
    }
  }

  void _reportLoginError(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Kakao Login',
        context: ErrorDescription('카카오 로그인 처리 중'),
      ),
    );
  }

  void _showLoginError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final contentHeight = screenHeight < 700 ? 700.0 : screenHeight;
          final panelHeight = contentHeight < 760 ? 196.0 : 211.0;
          final verticalScale = (contentHeight / 852).clamp(0.85, 1.15);

          return SingleChildScrollView(
            child: SizedBox(
              width: constraints.maxWidth,
              height: contentHeight,
              child: Column(
                children: [
                  Column(
                    key: const Key('login-intro'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SafeArea(
                        bottom: false,
                        child: SizedBox(
                          height: 44,
                          child: Center(
                            child: Image.asset(
                              AppImages.miniLogo,
                              package: widget.assetPackage,
                              width: 70,
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 150 * verticalScale),
                      SizedBox(
                        width: _carrierWidth * verticalScale,
                        child: AspectRatio(
                          aspectRatio: _carrierAspectRatio,
                          child: Image.asset(
                            AppImages.posongCarrier,
                            package: widget.assetPackage,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: 52.6 * verticalScale),
                      Text(
                        '지금 포짓과 함께 여행을 떠나볼까요?',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subTitle.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w500,
                          package: widget.assetPackage,
                        ),
                      ),
                      SizedBox(height: 14 * verticalScale),
                      Text(
                        '여행의 순간을 남기는 가장 쉬운 방법',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray5,
                          fontWeight: FontWeight.w500,
                          package: widget.assetPackage,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    height: panelHeight,
                    margin: const EdgeInsets.only(left: 17, right: 16),
                    decoration: const ShapeDecoration(
                      color: AppColors.loginPanelBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(50),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        _LoginGuideBadge(assetPackage: widget.assetPackage),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _SocialLoginButton(
                              semanticLabel: 'Apple로 로그인',
                              asset: AppImages.apple,
                              assetPackage: widget.assetPackage,
                              onTap: _isLoggingIn ? null : widget.onAppleLogin,
                            ),
                            const SizedBox(width: 50),
                            _SocialLoginButton(
                              semanticLabel: '카카오로 로그인',
                              asset: AppImages.kakao,
                              assetPackage: widget.assetPackage,
                              isLoading: _isLoggingIn,
                              onTap: _isLoggingIn
                                  ? null
                                  : () => _handleKakaoLogin(context),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoginGuideBadge extends StatelessWidget {
  const _LoginGuideBadge({required this.assetPackage});

  final String? assetPackage;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('login-guide-badge'),
      constraints: const BoxConstraints(minWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
      decoration: const ShapeDecoration(
        color: AppColors.white,
        shape: StadiumBorder(),
        shadows: [BoxShadow(color: AppColors.loginBadgeShadow, blurRadius: 4)],
      ),
      child: Text(
        '여행 기록 3초 만에 시작하기',
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.purple2,
          fontWeight: FontWeight.w500,
          package: assetPackage,
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.semanticLabel,
    required this.asset,
    required this.assetPackage,
    required this.onTap,
    this.isLoading = false,
  });

  final String semanticLabel;
  final String asset;
  final String? assetPackage;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: isLoading ? '$semanticLabel 처리 중' : semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.square(
          dimension: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(asset, package: assetPackage, width: 60, height: 60),
              if (isLoading)
                Positioned.fill(
                  child: Transform.translate(
                    offset: const Offset(0, -4),
                    child: Center(
                      child: SizedBox.square(
                        dimension: 52,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Positioned.fill(
                              child: DecoratedBox(
                                decoration: ShapeDecoration(
                                  color: AppColors.white20,
                                  shape: CircleBorder(),
                                ),
                              ),
                            ),
                            const SizedBox.square(
                              dimension: 24,
                              child: CircularProgressIndicator(
                                key: Key('social-login-progress'),
                                strokeWidth: 2.5,
                                color: AppColors.purple3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Login Screen', size: Size(393, 852))
Widget loginScreenPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(393, 852),
        padding: EdgeInsets.only(top: 59, bottom: 34),
      ),
      child: LoginScreen(assetPackage: 'pozit'),
    ),
  );
}

@Preview(group: 'hycho', name: 'Login Loading', size: Size(393, 852))
Widget loginLoadingPreview() {
  final pendingLogin = Completer<void>();

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(393, 852),
        padding: EdgeInsets.only(top: 59, bottom: 34),
      ),
      child: LoginScreen(
        assetPackage: 'pozit',
        onKakaoLogin: () => pendingLogin.future,
      ),
    ),
  );
}
