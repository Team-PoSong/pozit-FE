import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/button/app_button.dart';

class TermsAgreementScreen extends StatefulWidget {
  const TermsAgreementScreen({
    super.key,
    this.onNext,
    this.onServiceTermsTap,
    this.onPrivacyTermsTap,
    this.onLocationTermsTap,
    this.assetPackage,
  });

  final VoidCallback? onNext;
  final VoidCallback? onServiceTermsTap;
  final VoidCallback? onPrivacyTermsTap;
  final VoidCallback? onLocationTermsTap;
  final String? assetPackage;

  @override
  State<TermsAgreementScreen> createState() => _TermsAgreementScreenState();
}

class _TermsAgreementScreenState extends State<TermsAgreementScreen> {
  final List<bool> _agreements = List<bool>.filled(4, false);

  bool get _areAllAgreed => _agreements.every((isAgreed) => isAgreed);

  void _toggleAllAgreements() {
    final nextValue = !_areAllAgreed;
    setState(() {
      for (var index = 0; index < _agreements.length; index++) {
        _agreements[index] = nextValue;
      }
    });
  }

  void _toggleAgreement(int index) {
    setState(() => _agreements[index] = !_agreements[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 34),
              FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  '서비스 이용을 위해 약관에 동의해주세요.',
                  maxLines: 1,
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.text,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 46),
              _AgreementRow(
                label: '모두 동의합니다',
                isChecked: _areAllAgreed,
                isAll: true,
                assetPackage: widget.assetPackage,
                onTap: _toggleAllAgreements,
              ),
              const SizedBox(height: 25),
              _AgreementRow(
                label: '서비스 이용약관 동의 (필수)',
                isChecked: _agreements[0],
                showView: true,
                assetPackage: widget.assetPackage,
                onTap: () => _toggleAgreement(0),
                onViewTap: widget.onServiceTermsTap,
              ),
              const SizedBox(height: 10),
              _AgreementRow(
                label: '개인 정보 수집 및 이용 동의 (필수)',
                isChecked: _agreements[1],
                showView: true,
                assetPackage: widget.assetPackage,
                onTap: () => _toggleAgreement(1),
                onViewTap: widget.onPrivacyTermsTap,
              ),
              const SizedBox(height: 10),
              _AgreementRow(
                label: '위치 기반 서비스 동의 (필수)',
                isChecked: _agreements[2],
                showView: true,
                assetPackage: widget.assetPackage,
                onTap: () => _toggleAgreement(2),
                onViewTap: widget.onLocationTermsTap,
              ),
              const SizedBox(height: 10),
              _AgreementRow(
                label: '만 14세 이상입니다 (필수)',
                isChecked: _agreements[3],
                assetPackage: widget.assetPackage,
                onTap: () => _toggleAgreement(3),
              ),
              const Spacer(),
              AppButton(
                text: '다음',
                isEnabled: _areAllAgreed,
                onPressed: widget.onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgreementRow extends StatelessWidget {
  const _AgreementRow({
    required this.label,
    required this.isChecked,
    required this.assetPackage,
    required this.onTap,
    this.isAll = false,
    this.showView = false,
    this.onViewTap,
  });

  final String label;
  final bool isChecked;
  final String? assetPackage;
  final VoidCallback onTap;
  final bool isAll;
  final bool showView;
  final VoidCallback? onViewTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          checked: isChecked,
          label: label,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: 24,
                    child: Center(
                      child: SvgPicture.asset(
                        isChecked ? AppIcons.check : AppIcons.checkUnactive,
                        package: assetPackage,
                        width: isAll ? 24 : 22,
                        height: isAll ? 24 : 22,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    label,
                    style: (isAll ? AppTextStyles.subTitle : AppTextStyles.body)
                        .copyWith(
                          color: isAll ? AppColors.text : AppColors.gray5,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        if (showView)
          Semantics(
            button: true,
            label: '$label 보기',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onViewTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '보기',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.gray4,
                      ),
                    ),
                    const SizedBox(
                      width: 28,
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.gray4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
