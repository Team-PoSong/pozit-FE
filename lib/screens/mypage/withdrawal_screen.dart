import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_confirm_dialog.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../core/design_system/widgets/button/app_button.dart';

class WithdrawalScreen extends StatelessWidget {
  const WithdrawalScreen({super.key, this.onWithdrawTap});

  final VoidCallback? onWithdrawTap;

  Future<void> _confirm(BuildContext context) {
    return showAppConfirmDialog(
      context,
      title: '정말 탈퇴하시겠습니까?',
      description: '탈퇴 후에는 계정을 복구할 수 없습니다.',
      confirmText: '탈퇴하기',
      onConfirm: onWithdrawTap,
    );
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
              const AppDetailHeader(title: '회원 탈퇴'),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          100,
                          24,
                          MediaQuery.viewPaddingOf(context).bottom +
                              AppDimensions.bottomNavigationSpacing,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                AppImages.posongCrying,
                                width: 88,
                                height: 88,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 26),
                            Text(
                              '정말로 회원 탈퇴를 진행할까요?',
                              style: AppTextStyles.headline.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 56),
                            Text(
                              '탈퇴 후에는 서비스를 이용할 수 없으며, 계정을 다시 복구하기 어려울 수 있습니다. 회원 정보는 개인정보 처리방침과 관련 법령에 따라 일정 기간 보관된 후 파기됩니다.',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                            const Spacer(),
                            AppButton(
                              text: '탈퇴하기',
                              onPressed: () => _confirm(context),
                            ),
                          ],
                        ),
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

@Preview(group: 'haerim', name: '회원 탈퇴', size: Size(393, 852))
Widget withdrawalScreenPreview() => const MaterialApp(home: WithdrawalScreen());
