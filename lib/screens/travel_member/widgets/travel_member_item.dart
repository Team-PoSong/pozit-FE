import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_icons.dart';
import '../../../core/design_system/app_text_styles.dart';
import '../../../core/design_system/widgets/app_confirm_dialog.dart';
import '../../../core/design_system/widgets/app_delete_popover.dart';

const double _kLeaderIconStartPadding = 11.0;
const double _kLeaderIconTopPadding = 14.0;
const double _kLeaderIconSize = 24.0;
const double _kLeaderIconToTextGap = 23.0;
// 팀장 아이콘이 없는 행도 닉네임/아이디가 같은 위치에서 시작하도록, 팀장
// 아이콘이 차지하는 폭(시작 패딩 + 아이콘 + 간격)만큼을 그대로 비워둡니다.
const double _kLeadingSpacerWidth =
    _kLeaderIconStartPadding + _kLeaderIconSize + _kLeaderIconToTextGap;
const double _kNicknameToIdGap = 4.0;
const double _kMoreIconEndPadding = 10.0;
const double _kMoreIconSize = 24.0;

/// 여행 멤버 한 명을 표시하는 행입니다.
///
/// [isLeader]는 이 행이 표시하는 멤버가 팀장인지(왕관 아이콘 노출 여부),
/// [canManage]는 이 화면을 보는 사용자가 팀장이라 멤버 관리(더보기 → 삭제)가
/// 가능한지를 나타냅니다. 더보기를 누르면 [AppLocation]과 동일한 모양의
/// 삭제 팝오버가 뜨고, 거기서 "삭제하기"를 누르면 팝오버가 닫히고
/// [AppConfirmDialog]로 한 번 더 확인한 뒤에만 [onDelete]가 호출됩니다.
class TravelMemberItem extends StatefulWidget {
  const TravelMemberItem({
    super.key,
    required this.nickname,
    required this.userId,
    required this.isLeader,
    this.canManage = false,
    this.onDelete,
    this.assetPackage,
  });

  final String nickname;
  final String userId;
  final bool isLeader;
  final bool canManage;
  final VoidCallback? onDelete;
  final String? assetPackage;

  @override
  State<TravelMemberItem> createState() => _TravelMemberItemState();
}

class _TravelMemberItemState extends State<TravelMemberItem> {
  // 더보기 아이콘 바로 아래에 삭제 팝오버를 띄우기 위한 앵커입니다. 매
  // build마다 새로 만들면 CompositedTransformTarget/Follower가 서로 다른
  // 링크를 참조하게 되므로, State 필드로 두어 위젯 생애주기 동안 유지합니다.
  final LayerLink _anchorLink = LayerLink();

  void _handleMorePressed() {
    showAppDeletePopover(
      context,
      anchorLink: _anchorLink,
      assetPackage: widget.assetPackage,
      onDelete: _handleDeleteConfirm,
    );
  }

  void _handleDeleteConfirm() {
    showAppConfirmDialog(
      context,
      title: '${widget.nickname}님을 멤버에서 삭제하시겠습니까?',
      description: '해당 작업은 돌릴 수 없습니다.',
      confirmText: '삭제하기',
      onConfirm: widget.onDelete,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isLeader) ...[
            Padding(
              padding: const EdgeInsets.only(
                left: _kLeaderIconStartPadding,
                top: _kLeaderIconTopPadding,
              ),
              child: SvgPicture.asset(
                AppIcons.leader,
                package: widget.assetPackage,
                width: _kLeaderIconSize,
                height: _kLeaderIconSize,
              ),
            ),
            const SizedBox(width: _kLeaderIconToTextGap),
          ] else
            const SizedBox(width: _kLeadingSpacerWidth),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nickname,
                    style: AppTextStyles.subTitle.copyWith(
                      color: AppColors.text,
                      package: widget.assetPackage,
                    ),
                  ),
                  const SizedBox(height: _kNicknameToIdGap),
                  Text(
                    widget.userId,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.text,
                      package: widget.assetPackage,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.canManage)
            CompositedTransformTarget(
              link: _anchorLink,
              child: Semantics(
                button: true,
                label: '더보기',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _handleMorePressed,
                  child: Padding(
                    padding: const EdgeInsets.only(right: _kMoreIconEndPadding),
                    child: SvgPicture.asset(
                      AppIcons.more,
                      package: widget.assetPackage,
                      width: _kMoreIconSize,
                      height: _kMoreIconSize,
                      colorFilter: const ColorFilter.mode(
                        AppColors.gray5,
                        BlendMode.srcIn,
                      ),
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

@Preview(group: 'travel_member', name: 'TravelMemberItem - 팀장, 관리 가능')
Widget travelMemberItemLeaderManageablePreview() {
  return const Material(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: TravelMemberItem(
        nickname: '김윤지',
        userId: 'yoonji_kim',
        isLeader: true,
        canManage: true,
      ),
    ),
  );
}

@Preview(group: 'travel_member', name: 'TravelMemberItem - 팀원, 관리 가능')
Widget travelMemberItemMemberManageablePreview() {
  return const Material(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: TravelMemberItem(
        nickname: '박서현',
        userId: 'seohyun_park',
        isLeader: false,
        canManage: true,
      ),
    ),
  );
}

@Preview(group: 'travel_member', name: 'TravelMemberItem - 팀원, 관리 불가')
Widget travelMemberItemMemberReadOnlyPreview() {
  return const Material(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: TravelMemberItem(
        nickname: '이하림',
        userId: 'harim_lee',
        isLeader: false,
        canManage: false,
      ),
    ),
  );
}
