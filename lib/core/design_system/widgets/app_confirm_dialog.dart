import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String? description;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final double gapToButtons;
  final TextStyle? descriptionStyle;
  final double? descriptionMaxWidth;

  const AppConfirmDialog({
    super.key,
    required this.title,
    this.description,
    this.cancelText = '취소',
    required this.confirmText,
    this.onCancel,
    this.onConfirm,
    this.gapToButtons = 35.0,
    this.descriptionStyle,
    this.descriptionMaxWidth,
  });

  const AppConfirmDialog.twoLine({
    super.key,
    required this.title,
    required String description,
    this.cancelText = '취소',
    required this.confirmText,
    this.onCancel,
    this.onConfirm,
  })  : description = description, // ignore: prefer_initializing_formals
        gapToButtons = 15.0,
        descriptionMaxWidth = 274.0,
        descriptionStyle = const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w300,
          height: 17 / 12,
        );

  @override
  Widget build(BuildContext context) {
    Widget descriptionText = Text(
      description ?? '',
      textAlign: TextAlign.center,
      style: (descriptionStyle ?? AppTextStyles.caption).copyWith(color: AppColors.gray5),
    );
    if (descriptionMaxWidth != null) {
      descriptionText = SizedBox(width: descriptionMaxWidth, child: descriptionText);
    }

    return Container(
      width: 345.0,
      constraints: const BoxConstraints(minHeight: 180.0),
      padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 20.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.text),
          ),
          if (description != null) ...[
            const SizedBox(height: 9.0),
            descriptionText,
          ],
          SizedBox(height: gapToButtons),
          Row(
            children: [
              Expanded(
                child: _DialogButton(
                  text: cancelText,
                  backgroundColor: AppColors.gray2,
                  textColor: AppColors.gray5,
                  onPressed: onCancel,
                ),
              ),
              const SizedBox(width: 13.0),
              Expanded(
                child: _DialogButton(
                  text: confirmText,
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                  onPressed: onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;

  const _DialogButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        alignment: Alignment.center,
        child: Text(text, style: AppTextStyles.body.copyWith(color: textColor)),
      ),
    );
  }
}

Future<void> showAppConfirmDialog(
    BuildContext context, {
      required String title,
      String? description,
      String cancelText = '취소',
      required String confirmText,
      VoidCallback? onCancel,
      VoidCallback? onConfirm,
      double gapToButtons = 35.0,
      TextStyle? descriptionStyle,
      double? descriptionMaxWidth,
    }) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: AppConfirmDialog(
        title: title,
        description: description,
        cancelText: cancelText,
        confirmText: confirmText,
        gapToButtons: gapToButtons,
        descriptionStyle: descriptionStyle,
        descriptionMaxWidth: descriptionMaxWidth,
        onCancel: () {
          Navigator.of(context).pop();
          onCancel?.call();
        },
        onConfirm: () {
          Navigator.of(context).pop();
          onConfirm?.call();
        },
      ),
    ),
  );
}

Future<void> showTwoLineConfirmDialog(
    BuildContext context, {
      required String title,
      required String description,
      String cancelText = '취소',
      required String confirmText,
      VoidCallback? onCancel,
      VoidCallback? onConfirm,
    }) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: AppConfirmDialog.twoLine(
        title: title,
        description: description,
        cancelText: cancelText,
        confirmText: confirmText,
        onCancel: () {
          Navigator.of(context).pop();
          onCancel?.call();
        },
        onConfirm: () {
          Navigator.of(context).pop();
          onConfirm?.call();
        },
      ),
    ),
  );
}

@Preview(group: 'haerim', name: 'AppConfirmDialog - 멤버삭제')
Widget appConfirmDialogRemoveMemberPreview() => const AppConfirmDialog(
  title: '김윤지님을 멤버에서 삭제하시겠습니까?',
  description: '해당 작업은 돌릴 수 없습니다.',
  confirmText: '삭제하기',
);

@Preview(group: 'haerim', name: 'AppConfirmDialog - 로그아웃')
Widget appConfirmDialogLogoutPreview() => const AppConfirmDialog(
  title: '로그아웃 하시겠습니까?',
  description: '현재 기기에서 로그아웃됩니다.',
  confirmText: '로그아웃',
);

@Preview(group: 'haerim', name: 'AppConfirmDialog - 위치 권한')
Widget appConfirmDialogLocationPermissionPreview() => const AppConfirmDialog.twoLine(
  title: '위치 권한이 꺼져있어요!',
  description:
  '지금 위치를 확인할 수 없어 경주 여행 코스 안내와\nPozing 촬영 알림을 받을 수 없습니다.',
  cancelText: '나중에 하기',
  confirmText: '설정으로 이동',
);

@Preview(group: 'haerim', name: 'AppConfirmDialog - 카메라 권한')
Widget appConfirmDialogCameraPermissionPreview() => const AppConfirmDialog.twoLine(
  title: '카메라 및 사진 권한이 꺼져있어요!',
  description:
  '사진 촬영과 여행 로그 사진 업로드와\n저장 기능을 사용할 수 없습니다.',
  cancelText: '나중에 하기',
  confirmText: '설정으로 이동',
);