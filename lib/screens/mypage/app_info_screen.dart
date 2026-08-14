import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/support/support_info_model.dart';
import '../../data/repositories/support/support_repository.dart';
import 'term_detail_screen.dart';
import 'widgets/mypage_menu_row.dart';

const double _kContentHorizontalPadding = 24.0;
const double _kLogoTopSpacing = 31.0;
const double _kPolicyTopSpacing = 70.0;
const double _kFooterBottomSpacing = 46.0;

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({
    super.key,
    this.initialVersion,
    this.initialInfo,
    SupportRepository? repository,
  }) : repository = repository ?? const SupportRepository();

  final String? initialVersion;
  final SupportInfoModel? initialInfo;
  final SupportRepository repository;

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  SupportInfoModel? _info;
  String? _version;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _info = widget.initialInfo;
    _version = widget.initialVersion;
    if (_info == null) _loadInfo();
    if (_version == null) _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _version = packageInfo.version);
    } catch (_) {
      if (!mounted) return;
      setState(() => _version = '알 수 없음');
    }
  }

  Future<void> _loadInfo() async {
    setState(() => _error = null);
    try {
      final info = await widget.repository.getInfo();
      if (!mounted) return;
      setState(() => _info = info);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            children: [
              const AppDetailHeader(title: '앱 정보'),
              Expanded(child: _buildBody()),
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
          : '서비스 안내를 불러오지 못했습니다.';
      return _AppInfoError(message: message, onRetry: _loadInfo);
    }

    final info = _info;
    final version = _version;
    if (info != null && version != null) {
      return _AppInfoContent(version: version, info: info);
    }

    return const Center(
      child: CircularProgressIndicator(color: AppColors.purple3),
    );
  }
}

class _AppInfoContent extends StatelessWidget {
  const _AppInfoContent({required this.version, required this.info});

  final String version;
  final SupportInfoModel info;

  void _openTerm(BuildContext context, TermModel term) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => TermDetailScreen(term: term)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: _kContentHorizontalPadding,
          ),
          sliver: SliverList.list(
            children: [
              const SizedBox(height: _kLogoTopSpacing),
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.gray1,
                    border: Border.all(color: AppColors.purple1, width: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: 72,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        AppImages.appLogo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pozit',
                textAlign: TextAlign.center,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.text,
                  fontSize: 24,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '버전 $version',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(color: AppColors.gray5),
              ),
              const SizedBox(height: 18),
              Text(
                '여행의 순간을 기록하는 가장 쉬운 방법',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.gray5),
              ),
              const SizedBox(height: _kPolicyTopSpacing),
              Text(
                '약관 및 정책',
                style: AppTextStyles.body.copyWith(color: AppColors.gray5),
              ),
              const SizedBox(height: 8),
              MyPageMenuRow(
                label: '서비스 이용 약관',
                onTap: () => _openTerm(context, info.serviceTerm),
              ),
              MyPageMenuRow(
                label: '개인정보 처리 방침',
                onTap: () => _openTerm(context, info.privacyPolicy),
              ),
            ],
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                AppImages.posongPlainMini,
                width: 59,
                height: 54,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                '© 2026 Pozit. All rights reserved.',
                style: AppTextStyles.caption.copyWith(color: AppColors.gray5),
              ),
              const SizedBox(height: _kFooterBottomSpacing),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppInfoError extends StatelessWidget {
  const _AppInfoError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.gray5),
          ),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: '서비스 안내 다시 불러오기',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRetry,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: AppDimensions.minimumTapTargetSize,
                  minHeight: AppDimensions.minimumTapTargetSize,
                ),
                child: Center(
                  child: Text(
                    '다시 시도',
                    style: AppTextStyles.body.copyWith(color: AppColors.text),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(group: 'haerim', name: '앱 정보', size: Size(393, 852))
Widget appInfoScreenPreview() => MaterialApp(
  home: AppInfoScreen(
    initialVersion: '1.0.0',
    initialInfo: SupportInfoModel(
      serviceTerm: TermModel(
        title: '서비스 이용약관',
        version: '1.0',
        effectiveDate: DateTime(2026, 8, 1),
        sections: const [
          TermSectionModel(title: '제1조 (목적)', content: '서비스 이용약관 본문'),
        ],
      ),
      privacyPolicy: TermModel(
        title: '개인정보처리방침',
        version: '1.0',
        effectiveDate: DateTime(2026, 8, 1),
        sections: const [
          TermSectionModel(title: '1. 수집 항목', content: '개인정보처리방침 본문'),
        ],
      ),
    ),
  ),
);
