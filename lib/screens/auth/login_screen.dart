import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.onAppleLogin, this.onKakaoLogin});

  final VoidCallback? onAppleLogin;
  final VoidCallback? onKakaoLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final panelHeight = screenHeight < 760 ? 196.0 : 211.0;

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      Image.asset(
                        AppImages.miniLogo,
                        width: 105,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 42),
                      Image.asset(
                        AppImages.posongCarrier,
                        width: 282,
                        height: 194,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '지금 포짓과 함께 여행을 떠나볼까요?',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subTitle.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '여행의 순간을 남기는 가장 쉬운 방법',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(flex: 2),
                      SizedBox(height: panelHeight),
                    ],
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
                bottom: panelHeight - 50,
                child: const _LoginGuideBadge(),
              ),
              Positioned(
                bottom: 63,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SocialLoginButton(
                      semanticLabel: 'Apple로 로그인',
                      asset: AppIcons.apple,
                      onTap: onAppleLogin,
                    ),
                    const SizedBox(width: 32),
                    _SocialLoginButton(
                      semanticLabel: '카카오로 로그인',
                      asset: AppIcons.kakao,
                      onTap: onKakaoLogin,
                    ),
                  ],
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
  const _LoginGuideBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 169),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10.5),
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
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.semanticLabel,
    required this.asset,
    required this.onTap,
  });

  final String semanticLabel;
  final String asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SvgPicture.asset(asset, width: 68, height: 68),
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Login Screen')
Widget loginScreenPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  );
}
