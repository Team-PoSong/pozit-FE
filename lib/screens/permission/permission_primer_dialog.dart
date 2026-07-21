import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_button.dart';

const TextStyle _cardDescriptionStyle = TextStyle(
  fontFamily: 'Pretendard',
  fontSize: 12,
  fontWeight: FontWeight.w300,
  height: 16 / 12,
  color: Colors.black,
);

const TextStyle _footerStyle = TextStyle(
  fontFamily: 'Pretendard',
  fontSize: 12,
  fontWeight: FontWeight.w300,
  height: 17 / 12,
  color: AppColors.gray5,
);

class PermissionPrimerDialog extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onConfirm;

  const PermissionPrimerDialog({
    super.key,
    required this.onClose,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345.0,
      constraints: const BoxConstraints(minHeight: 636.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0, bottom: 33.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '원활한 여행을 위해 권한을 허용해주세요.',
                  style: AppTextStyles.subTitle.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 35.0),
                const _PermissionCard(
                  title: '위치정보',
                  bulletLines: [
                    '주변 여행 코스 추천 제공',
                    '여행 방문 및 진행 상태 확인',
                    '여행 기록 자동 저장',
                  ],
                  isRequired: true,
                ),
                const SizedBox(height: 12.0),
                const _PermissionCard(
                  title: '알림',
                  bulletLines: [
                    '여행 시작 / 종료 안내',
                    '팀 여행 진행 상황 알림',
                    '코스 단계별 알림 제공',
                  ],
                  isRequired: true,
                ),
                const SizedBox(height: 12.0),
                const _PermissionCard(
                  title: '카메라 및 사진',
                  bulletLines: [
                    'Pozing 촬영',
                    '여행 로그 사진 업로드',
                    '사진 저장',
                  ],
                  isRequired: false,
                ),
                const SizedBox(height: 12.0),
                const Text(
                  "'확인'을 누르면 위치 → 알림 → 카메라 권한 요청이 순서대로\n진행됩니다.",
                  style: _footerStyle,
                ),
                const SizedBox(height: 64.0),
                AppButton(
                  text: '확인',
                  onPressed: onConfirm,
                ),
              ],
            ),
          ),
          Positioned(
            top: 12.0,
            right: 8.0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: SizedBox(
                width: 48.0,
                height: 48.0,
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.x,
                    width: 24.0,
                    height: 24.0,
                    colorFilter: const ColorFilter.mode(AppColors.text, BlendMode.srcIn),
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

class _PermissionCard extends StatelessWidget {
  final String title;
  final List<String> bulletLines;
  final bool isRequired;

  const _PermissionCard({
    required this.title,
    required this.bulletLines,
    required this.isRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 101.0),
      padding: const EdgeInsets.only(left: 26.0, right: 16.0, top: 14.0, bottom: 14.0),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: AppColors.gray3, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.caption2.copyWith(color: Colors.black)),
                const SizedBox(height: 11.0),
                Text(
                  bulletLines.map((line) => '• $line').join('\n'),
                  style: _cardDescriptionStyle,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          _PermissionBadge(isRequired: isRequired),
        ],
      ),
    );
  }
}

class _PermissionBadge extends StatelessWidget {
  final bool isRequired;

  const _PermissionBadge({required this.isRequired});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11.0, 3.0, 12.0, 3.0),
      decoration: BoxDecoration(
        color: isRequired ? AppColors.primary : AppColors.purple1,
        borderRadius: BorderRadius.circular(999.0),
        border: Border.all(color: AppColors.purple3, width: 0.5),
      ),
      child: Text(
        isRequired ? '필수' : '선택',
        style: AppTextStyles.caption.copyWith(
          color: isRequired ? AppColors.white : AppColors.primary,
        ),
      ),
    );
  }
}

Future<void> showPermissionPrimerDialog(
    BuildContext context, {
      required VoidCallback onClose,
      required VoidCallback onConfirm,
    }) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: SingleChildScrollView(
        child: PermissionPrimerDialog(
          onClose: () {
            Navigator.of(dialogContext).pop();
            onClose();
          },
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            onConfirm();
          },
        ),
      ),
    ),
  );
}

@Preview(group: 'haerim', name: 'PermissionPrimerDialog')
Widget permissionPrimerDialogPreview() {
  return PermissionPrimerDialog(
    onClose: () {},
    onConfirm: () {},
  );
}