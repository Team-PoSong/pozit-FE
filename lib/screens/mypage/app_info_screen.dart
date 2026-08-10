import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../data/models/support/support_info_model.dart';
import 'term_detail_screen.dart';
import 'widgets/mypage_menu_row.dart';

const double _kContentHorizontalPadding = 24.0;
const double _kLogoTopSpacing = 31.0;
const double _kPolicyTopSpacing = 70.0;
const double _kFooterBottomSpacing = 46.0;

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key, required this.version, required this.info});

  final String version;
  final SupportInfoModel info;

  void _openTerm(BuildContext context, TermModel term) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => TermDetailScreen(term: term)),
    );
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
              Expanded(
                child: CustomScrollView(
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
                                border: Border.all(
                                  color: AppColors.purple1,
                                  width: 0.5,
                                ),
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
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gray5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '여행의 순간을 기록하는 가장 쉬운 방법',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.gray5,
                            ),
                          ),
                          const SizedBox(height: _kPolicyTopSpacing),
                          Text(
                            '약관 및 정책',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.gray5,
                            ),
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
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gray5,
                            ),
                          ),
                          const SizedBox(height: _kFooterBottomSpacing),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: '앱 정보', size: Size(393, 852))
Widget appInfoScreenPreview() => MaterialApp(
  home: AppInfoScreen(
    version: '1.0.0',
    info: SupportInfoModel(
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
