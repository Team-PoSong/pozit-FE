import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/widgets/app_confirm_dialog.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../data/models/user/nickname_validation_model.dart';
import '../../data/models/support/support_info_model.dart';
import '../../data/models/user/notification_settings_model.dart';
import '../../data/models/user/user_profile_model.dart';
import 'app_info_screen.dart';
import 'mypage_content.dart';
import 'nickname_edit_screen.dart';
import 'notification_settings_screen.dart';
import 'withdrawal_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({
    super.key,
    required this.initialProfile,
    required this.supportInfo,
    this.appVersion = '1.0.0',
    this.onNicknameChanged,
    this.validateNickname,
    this.onNotificationSettingsChanged,
    this.onLogout,
    this.onWithdrawal,
  });

  final UserProfileModel initialProfile;
  final String appVersion;
  final SupportInfoModel supportInfo;
  final ValueChanged<String>? onNicknameChanged;
  final NicknameAvailabilityValidator? validateNickname;
  final ValueChanged<NotificationSettingsModel>? onNotificationSettingsChanged;
  final VoidCallback? onLogout;
  final VoidCallback? onWithdrawal;

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  late UserProfileModel _profile = widget.initialProfile;

  Future<void> _openNickname() async {
    final nickname = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => NicknameEditScreen(
          initialNickname: _profile.nickname,
          validateNickname: widget.validateNickname,
        ),
      ),
    );
    if (!mounted || nickname == null) return;
    setState(() => _profile = _profile.copyWith(nickname: nickname));
    widget.onNicknameChanged?.call(nickname);
  }

  void _openNotificationSettings() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationSettingsScreen(
          initialSettings: NotificationSettingsModel.fromProfile(_profile),
          onChanged: (settings) {
            if (!mounted) return;
            setState(
              () => _profile = _profile.copyWith(
                pushEnabled: settings.pushEnabled,
                notiTravelEnabled: settings.travelEnabled,
                notiGroupEnabled: settings.groupEnabled,
                notiPozingEnabled: settings.pozingEnabled,
                notiCourseEnabled: settings.courseEnabled,
                notiNoticeEnabled: settings.noticeEnabled,
              ),
            );
            widget.onNotificationSettingsChanged?.call(settings);
          },
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog() {
    return showAppConfirmDialog(
      context,
      title: '로그아웃 하시겠습니까?',
      description: '현재 기기에서 로그아웃됩니다.',
      confirmText: '로그아웃',
      onConfirm: widget.onLogout,
    );
  }

  void _openAppInfo() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AppInfoScreen(version: widget.appVersion, info: widget.supportInfo),
      ),
    );
  }

  void _openWithdrawal() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => WithdrawalScreen(onWithdrawTap: widget.onWithdrawal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray2,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            children: [
              Container(
                color: AppColors.white,
                child: const AppDetailHeader(title: '내 정보'),
              ),
              Expanded(
                child: MyPageContent(
                  profile: _profile,
                  onNicknameTap: _openNickname,
                  onNotificationSettingsTap: _openNotificationSettings,
                  onAppInfoTap: _openAppInfo,
                  onFeedbackTap: () {},
                  onLogoutTap: _showLogoutDialog,
                  onWithdrawalTap: _openWithdrawal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: '내 정보', size: Size(393, 852))
Widget myPageScreenPreview() => MaterialApp(
  home: MyPageScreen(
    initialProfile: _previewProfile,
    supportInfo: _previewSupportInfo,
  ),
);

const _previewProfile = UserProfileModel(
  userId: 1,
  nickname: '조현영',
  socialProvider: SocialProvider.kakao,
  pushEnabled: true,
  notiTravelEnabled: true,
  notiGroupEnabled: true,
  notiPozingEnabled: true,
  notiCourseEnabled: true,
  notiNoticeEnabled: true,
);

const _previewSupportInfo = SupportInfoModel(
  serviceTerm: TermModel(
    title: '서비스 이용약관',
    version: '1.0',
    sections: [TermSectionModel(title: '제1조 (목적)', content: '서비스 이용약관 본문입니다.')],
  ),
  privacyPolicy: TermModel(
    title: '개인정보처리방침',
    version: '1.0',
    sections: [
      TermSectionModel(title: '1. 수집하는 개인정보', content: '개인정보처리방침 본문입니다.'),
    ],
  ),
);
