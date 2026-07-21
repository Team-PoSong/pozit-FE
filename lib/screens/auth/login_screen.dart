import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/auth/kakao_login_service.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';

class LoginScreen extends StatelessWidget {
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
      await onKakaoAccessToken?.call(accessToken);

      if (context.mounted && onKakaoAccessToken == null) {
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
          context: ErrorDescription('카카오 accessToken 발급 중'),
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
          final panelHeight = screenHeight < 760 ? 196.0 : 211.0;
          final verticalScale = (screenHeight / 852).clamp(0.85, 1.15);

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 60 * verticalScale,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    AppImages.miniLogo,
                    package: assetPackage,
                    width: 70 * verticalScale,
                    height: 32 * verticalScale,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 242 * verticalScale,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    AppImages.posongCarrier,
                    package: assetPackage,
                    width: 257 * 0.9 * verticalScale,
                    height: 176 * 0.9 * verticalScale,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 453 * verticalScale,
                left: 0,
                right: 0,
                child: Text(
                  '지금 포짓과 함께 여행을 떠나볼까요?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subTitle.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w500,
                    package: assetPackage,
                  ),
                ),
              ),
              Positioned(
                top: 487 * verticalScale,
                left: 0,
                right: 0,
                child: Text(
                  '여행의 순간을 남기는 가장 쉬운 방법',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray5,
                    fontWeight: FontWeight.w500,
                    package: assetPackage,
                  ),
                ),
              ),
              Positioned(
                left: 17,
                right: 16,
                bottom: 0,
                height: panelHeight,
                child: const DecoratedBox(
                  decoration: ShapeDecoration(
                    color: AppColors.loginPanelBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(50),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: panelHeight - 51,
                child: _LoginGuideBadge(assetPackage: assetPackage),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 70,
                child: Center(
                  child: Row(
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
                ),
              ),
            ],
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
      width: 170,
      height: 36,
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
          child: Center(
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
