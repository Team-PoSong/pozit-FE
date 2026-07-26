import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';
import '../app_icons.dart';
import '../app_text_styles.dart';

/// '더보기' 아이콘을 눌렀을 때 뜨는 "삭제하기" 팝오버입니다.
///
/// [AppLocation]에서 쓰던 것을 다른 곳(멤버 목록 등)에서도 동일하게 쓸 수
/// 있도록 공통 위젯으로 뺐습니다.
class AppDeletePopover extends StatelessWidget {
  const AppDeletePopover({super.key, required this.onTap, this.assetPackage});

  final VoidCallback onTap;
  final String? assetPackage;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '삭제하기',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            shadows: const [
              BoxShadow(
                color: AppColors.popoverShadow,
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppIcons.trashBlack,
                package: assetPackage,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '삭제하기',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.text,
                  package: assetPackage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// [AppDeletePopover]를 [anchorLink]가 붙은 트리거(보통 더보기 아이콘) 바로
/// 왼쪽 옆에, 오버레이 레이어에 직접 띄웁니다.
///
/// 트리거를 감싼 부모(예: 좁은 Row 한 줄)의 높이보다 팝오버가 커도, 오버레이에
/// 그려지므로 잘리지 않습니다. 호출하는 쪽에서는 트리거를
/// `CompositedTransformTarget(link: anchorLink, ...)`로 감싸두면 됩니다.
Future<void> showAppDeletePopover(
  BuildContext context, {
  required LayerLink anchorLink,
  required VoidCallback onDelete,
  String? assetPackage,
}) {
  final overlay = Overlay.of(context);
  final completer = Completer<void>();
  late final OverlayEntry entry;

  void close() {
    entry.remove();
    completer.complete();
  }

  entry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: close),
        ),
        CompositedTransformFollower(
          link: anchorLink,
          // 트리거(더보기 아이콘)의 왼쪽 가운데에 팝오버의 오른쪽 가운데를
          // 붙여서, 아래가 아니라 왼쪽 옆에 나타나도록 합니다.
          targetAnchor: Alignment.centerLeft,
          followerAnchor: Alignment.centerRight,
          offset: const Offset(-8, 0),
          // 이 팝오버는 Overlay에 직접 그려져 Scaffold의 Material 밖에
          // 있으므로, Material 조상이 없으면 디버그 빌드에서 텍스트에
          // 노란 밑줄 경고가 붙습니다. transparency 타입 Material로 감싸
          // 해결합니다.
          child: Material(
            type: MaterialType.transparency,
            child: AppDeletePopover(
              assetPackage: assetPackage,
              onTap: () {
                close();
                onDelete();
              },
            ),
          ),
        ),
      ],
    ),
  );

  overlay.insert(entry);
  return completer.future;
}
