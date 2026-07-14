import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';
import '../app_icons.dart';
import '../app_text_styles.dart';

/// 여행지의 이름과 주소를 표시하는 공통 카드입니다.
///
/// [showReorderHandle]을 활성화하면 왼쪽에 정렬 핸들이 표시되고,
/// [onMorePressed]를 전달하면 오른쪽에 더보기 버튼이 표시됩니다.
class AppLocation extends StatelessWidget {
  const AppLocation({
    super.key,
    required this.name,
    required this.address,
    this.showReorderHandle = false,
    this.onMorePressed,
    this.width = 345,
  });

  final String name;
  final String address;
  final bool showReorderHandle;
  final VoidCallback? onMorePressed;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 77,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.gray1,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.5, color: AppColors.gray3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        children: [
          if (showReorderHandle) ...[
            const SizedBox(width: 16),
            SvgPicture.asset(AppIcons.reorderHandle, width: 24, height: 24),
            const SizedBox(width: 17),
          ] else
            const SizedBox(width: 30),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subTitle.copyWith(color: AppColors.text),
                ),
                const SizedBox(height: 3),
                Text(
                  address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(color: AppColors.text),
                ),
              ],
            ),
          ),
          if (onMorePressed != null)
            Semantics(
              button: true,
              label: '더보기',
              child: InkWell(
                onTap: onMorePressed,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 26,
                  ),
                  child: SvgPicture.asset(
                    AppIcons.more,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.gray5,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 30),
        ],
      ),
    );
  }
}
