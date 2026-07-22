import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../data/datasources/auth/kakao_login_service.dart';
import '../../data/repositories/auth/auth_repository.dart';

class LoginScreen extends StatelessWidget {
  static const double _carrierWidth = 231.3;
  static const double _carrierAspectRatio = 257 / 176;

  const LoginScreen({
    super.key,
    this.onAppleLogin,
    this.onKakaoLogin,
    this.onKakaoAccessToken,
    this.assetPackage,
  });

  final VoidCallback? onAppleLogin;
  final VoidCallback? onKakaoLogin;
  final Future<void> Function(String accessToken)? onKakaoAccessToken;
  final String? assetPackage;

  Future<void> _handleKakaoLogin(BuildContext context) async {
    if (onKakaoLogin != null) {
      onKakaoLogin!();
      return;
    }

    try {
      final accessToken = await const KakaoLoginService().login();
      if (onKakaoAccessToken case final callback?) {
        await callback(accessToken);
      } else {
        await AuthRepository().loginWithKakaoAccessToken(accessToken);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('카카오 로그인에 성공했어요.')));
      }
    } on KakaoLoginCanceledException {
      return;
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Kakao Login',
          context: ErrorDescription('카카오 로그인 처리 중'),
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카카오 로그인에 실패했어요. 다시 시도해 주세요.')),
        );
      }
    }
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
                  SizedBox(height: 60 * verticalScale),
                  Column(
                    key: const Key('login-intro'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AppImages.miniLogo,
                        package: assetPackage,
                        width: 70 * verticalScale,
                        height: 32 * verticalScale,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 150 * verticalScale),
                      SizedBox(
                        width: _carrierWidth * verticalScale,
                        child: AspectRatio(
                          aspectRatio: _carrierAspectRatio,
                          child: Image.asset(
                            AppImages.posongCarrier,
                            package: assetPackage,
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
                          package: assetPackage,
                        ),
                      ),
                      SizedBox(height: 14 * verticalScale),
                      Text(
                        '여행의 순간을 남기는 가장 쉬운 방법',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray5,
                          fontWeight: FontWeight.w500,
                          package: assetPackage,
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
                        _LoginGuideBadge(assetPackage: assetPackage),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _SocialLoginButton(
                              semanticLabel: 'Apple로 로그인',
                              asset: AppImages.apple,
                              assetPackage: assetPackage,
                              onTap: onAppleLogin,
                            ),
                            const SizedBox(width: 50),
                            _SocialLoginButton(
                              semanticLabel: '카카오로 로그인',
                              asset: AppImages.kakao,
                              assetPackage: assetPackage,
                              onTap: () => _handleKakaoLogin(context),
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
      constraints: const BoxConstraints(minWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
      alignment: Alignment.center,
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
  });

  final String semanticLabel;
  final String asset;
  final String? assetPackage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.square(
          dimension: 60,
          child: DecoratedBox(
            decoration: const ShapeDecoration(
              shape: CircleBorder(),
              shadows: [
                BoxShadow(
                  color: AppColors.socialLoginShadow,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              asset,
              package: assetPackage,
              width: 60,
              height: 60,
            ),
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
    home: LoginScreen(assetPackage: 'pozit'),
  );
}
