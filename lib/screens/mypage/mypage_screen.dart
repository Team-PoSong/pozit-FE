import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/widgets/app_confirm_dialog.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../core/design_system/widgets/app_retry_error_view.dart';
import '../../core/network/api_exception.dart';
import '../../data/datasources/auth/apple_login_service.dart';
import '../../data/datasources/auth/auth_token_storage.dart';
import '../../data/models/support/support_info_model.dart';
import '../../data/models/user/notification_settings_model.dart';
import '../../data/models/user/user_profile_model.dart';
import '../../data/repositories/auth/auth_repository.dart';
import '../../data/repositories/support/support_repository.dart';
import '../../data/repositories/user/user_repository.dart';
import 'app_info_screen.dart';
import 'feedback_screen.dart';
import 'mypage_content.dart';
import 'nickname_edit_screen.dart';
import 'notification_settings_screen.dart';
import 'withdrawal_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({
    super.key,
    this.initialProfile,
    this.initialSupportInfo,
    this.initialAppVersion,
    this.onFeedbackTap,
    this.onSignedOut,
    UserRepository? userRepository,
    SupportRepository? supportRepository,
    AuthRepository? authRepository,
    AppleLoginService? appleLoginService,
    AuthTokenStorage? tokenStorage,
  }) : userRepository = userRepository ?? const UserRepository(),
       supportRepository = supportRepository ?? const SupportRepository(),
       authRepository = authRepository ?? const AuthRepository(),
       appleLoginService = appleLoginService ?? const AppleLoginService(),
       tokenStorage = tokenStorage ?? const AuthTokenStorage();

  final UserProfileModel? initialProfile;
  final SupportInfoModel? initialSupportInfo;
  final String? initialAppVersion;
  final VoidCallback? onFeedbackTap;
  final VoidCallback? onSignedOut;
  final UserRepository userRepository;
  final SupportRepository supportRepository;
  final AuthRepository authRepository;
  final AppleLoginService appleLoginService;
  final AuthTokenStorage tokenStorage;

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  UserProfileModel? _profile;
  Object? _error;
  bool _isLoadingProfile = false;
  bool _isAccountRequestRunning = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
    if (_profile == null) _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_isLoadingProfile) return;
    _isLoadingProfile = true;
    setState(() => _error = null);
    try {
      final profile = await widget.userRepository.getMe();
      if (!mounted) return;
      setState(() => _profile = profile);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      _isLoadingProfile = false;
    }
  }

  Future<void> _openNickname() async {
    final profile = _profile;
    if (profile == null) return;
    final nickname = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => NicknameEditScreen(
          initialNickname: profile.nickname,
          onSubmit: widget.userRepository.updateNickname,
        ),
      ),
    );
    if (!mounted || nickname == null) return;
    setState(() => _profile = profile.copyWith(nickname: nickname));
  }

  void _openNotificationSettings() {
    final profile = _profile;
    if (profile == null) return;
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationSettingsScreen(
          initialSettings: NotificationSettingsModel.fromProfile(profile),
          onChanged: (settings) async {
            await widget.userRepository.updateNotificationSettings(settings);
            if (!mounted) return;
            setState(
              () => _profile = _profile?.copyWith(
                pushEnabled: settings.pushEnabled,
                notiTravelEnabled: settings.travelEnabled,
                notiGroupEnabled: settings.groupEnabled,
                notiPozingEnabled: settings.pozingEnabled,
                notiCourseEnabled: settings.courseEnabled,
                notiNoticeEnabled: settings.noticeEnabled,
              ),
            );
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
      onConfirm: _logout,
    );
  }

  Future<void> _logout() async {
    if (_isAccountRequestRunning) return;
    setState(() => _isAccountRequestRunning = true);
    try {
      await widget.authRepository.logout();
      widget.onSignedOut?.call();
    } catch (error) {
      _showError(error, fallback: '로그아웃하지 못했습니다.');
    } finally {
      if (mounted) setState(() => _isAccountRequestRunning = false);
    }
  }

  void _openAppInfo() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AppInfoScreen(
          initialVersion: widget.initialAppVersion,
          initialInfo: widget.initialSupportInfo,
          repository: widget.supportRepository,
        ),
      ),
    );
  }

  Future<void> _openFeedback() async {
    final sent = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FeedbackScreen(repository: widget.supportRepository),
      ),
    );
    if (!mounted || sent != true) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('피드백을 보내주셔서 감사합니다.')));
  }

  void _openWithdrawal() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => WithdrawalScreen(onWithdrawTap: _withdraw),
      ),
    );
  }

  Future<void> _withdraw() async {
    if (_isAccountRequestRunning) return;
    final profile = _profile;
    if (profile == null) return;
    setState(() => _isAccountRequestRunning = true);
    try {
      if (profile.socialProvider == SocialProvider.apple) {
        final credential = await widget.appleLoginService.login();
        await widget.userRepository.withdraw(
          appleAuthorizationCode: credential.authorizationCode,
          applePlatform: credential.platform,
        );
      } else {
        await widget.userRepository.withdraw();
      }
      await widget.tokenStorage.clear();
      widget.onSignedOut?.call();
    } on AppleLoginCanceledException {
      return;
    } catch (error) {
      _showError(error, fallback: '회원 탈퇴를 처리하지 못했습니다.');
    } finally {
      if (mounted) setState(() => _isAccountRequestRunning = false);
    }
  }

  void _showError(Object error, {required String fallback}) {
    if (!mounted) return;
    final message = error is ApiException ? error.message : fallback;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
                child: ColoredBox(
                  color: AppColors.gray2,
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error case final error?) {
      final message = error is ApiException
          ? error.message
          : '내 정보를 불러오지 못했습니다.';
      return AppRetryErrorView(
        message: message,
        onRetry: _loadProfile,
        retrySemanticLabel: '내 정보 다시 불러오기',
      );
    }
    if (_profile case final profile?) {
      return MyPageContent(
        profile: profile,
        onNicknameTap: _openNickname,
        onNotificationSettingsTap: _openNotificationSettings,
        onAppInfoTap: _openAppInfo,
        onFeedbackTap: widget.onFeedbackTap ?? _openFeedback,
        onLogoutTap: _showLogoutDialog,
        onWithdrawalTap: _openWithdrawal,
      );
    }
    return const Center(
      child: CircularProgressIndicator(color: AppColors.purple3),
    );
  }
}

@Preview(group: 'haerim', name: '내 정보', size: Size(393, 852))
Widget myPageScreenPreview() => const MaterialApp(
  home: MyPageScreen(
    initialProfile: _previewProfile,
    initialSupportInfo: _previewSupportInfo,
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
  locationTerm: TermModel(
    title: '위치기반서비스 이용약관',
    version: '1.0',
    sections: [
      TermSectionModel(title: '제1조 (목적)', content: '위치기반서비스 이용약관 본문입니다.'),
    ],
  ),
);
