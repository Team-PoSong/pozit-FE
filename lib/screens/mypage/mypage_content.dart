import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../data/models/user/user_profile_model.dart';
import 'widgets/mypage_menu_row.dart';

const double _kSectionGap = 6.0;
const double _kHorizontalPadding = 24.0;
const double _kBottomButtonGap = 11.0;
const double _kProfileSectionMinHeight = 95.0;
const EdgeInsets _kNotificationSectionPadding = EdgeInsets.fromLTRB(
  _kHorizontalPadding,
  22,
  12,
  10,
);

class MyPageContent extends StatelessWidget {
  const MyPageContent({
    super.key,
    required this.profile,
    required this.onNicknameTap,
    required this.onNotificationSettingsTap,
    required this.onAppInfoTap,
    required this.onFeedbackTap,
    required this.onLogoutTap,
    required this.onWithdrawalTap,
    this.assetPackage,
  });

  final UserProfileModel profile;
  final VoidCallback onNicknameTap;
  final VoidCallback onNotificationSettingsTap;
  final VoidCallback onAppInfoTap;
  final VoidCallback onFeedbackTap;
  final VoidCallback onLogoutTap;
  final VoidCallback onWithdrawalTap;
  final String? assetPackage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      color: AppColors.white,
                      constraints: const BoxConstraints(
                        minHeight: _kProfileSectionMinHeight,
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        _kHorizontalPadding,
                        14,
                        _kHorizontalPadding,
                        25,
                      ),
                      child: _NicknameButton(
                        nickname: profile.nickname,
                        onTap: onNicknameTap,
                        assetPackage: assetPackage,
                      ),
                    ),
                    const SizedBox(height: _kSectionGap),
                    _Section(
                      title: '알림',
                      padding: _kNotificationSectionPadding,
                      children: [
                        MyPageMenuRow(
                          label: '알림 설정',
                          onTap: onNotificationSettingsTap,
                          assetPackage: assetPackage,
                        ),
                      ],
                    ),
                    const SizedBox(height: _kSectionGap),
                  ],
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: _Section(
                  title: '정보',
                  children: [
                    MyPageMenuRow(
                      label: '앱 버전 정보',
                      onTap: onAppInfoTap,
                      assetPackage: assetPackage,
                    ),
                    MyPageMenuRow(
                      label: '피드백 보내기',
                      onTap: onFeedbackTap,
                      assetPackage: assetPackage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: AppColors.white,
          padding: EdgeInsets.fromLTRB(
            _kHorizontalPadding,
            12,
            _kHorizontalPadding,
            MediaQuery.viewPaddingOf(context).bottom +
                AppDimensions.bottomNavigationSpacing,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '로그아웃',
                  backgroundColor: AppColors.gray2,
                  contentColor: AppColors.gray5,
                  padding: const EdgeInsets.symmetric(vertical: 12.5),
                  textStyle: AppTextStyles.body,
                  onPressed: onLogoutTap,
                ),
              ),
              const SizedBox(width: _kBottomButtonGap),
              Expanded(
                child: AppButton(
                  text: '회원탈퇴',
                  backgroundColor: AppColors.gray2,
                  contentColor: AppColors.gray5,
                  padding: const EdgeInsets.symmetric(vertical: 12.5),
                  textStyle: AppTextStyles.body,
                  onPressed: onWithdrawalTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NicknameButton extends StatelessWidget {
  const _NicknameButton({
    required this.nickname,
    required this.onTap,
    required this.assetPackage,
  });

  final String nickname;
  final VoidCallback onTap;
  final String? assetPackage;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '닉네임 수정',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.minimumTapTargetSize,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    nickname,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  AppIcons.edit,
                  package: assetPackage,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.gray5,
                    BlendMode.srcIn,
                  ),
                  excludeFromSemantics: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(_kHorizontalPadding, 22, 12, 24),
  });

  final String title;
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(color: AppColors.gray5),
          ),
          const SizedBox(height: 1),
          ...children,
        ],
      ),
    );
  }
}

@Preview(group: 'haerim', name: '내 정보 콘텐츠', size: Size(393, 746))
Widget myPageContentPreview() => MaterialApp(
  home: Scaffold(
    body: MyPageContent(
      profile: const UserProfileModel(
        userId: 1,
        nickname: '조현영',
        socialProvider: SocialProvider.kakao,
        pushEnabled: true,
        notiTravelEnabled: true,
        notiGroupEnabled: true,
        notiPozingEnabled: true,
        notiCourseEnabled: true,
        notiNoticeEnabled: true,
      ),
      onNicknameTap: () {},
      onNotificationSettingsTap: () {},
      onAppInfoTap: () {},
      onFeedbackTap: () {},
      onLogoutTap: () {},
      onWithdrawalTap: () {},
    ),
  ),
);
