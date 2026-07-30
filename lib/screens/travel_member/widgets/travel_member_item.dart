import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_icons.dart';
import '../../../core/design_system/app_text_styles.dart';
import '../../../core/design_system/widgets/app_confirm_dialog.dart';
import '../../../core/design_system/widgets/app_delete_popover.dart';

const double _kLeaderIconStartPadding = 11.0;
const double _kLeaderIconSize = 24.0;
const double _kLeaderIconToTextGap = 23.0;

const double _kLeadingSpacerWidth =
    _kLeaderIconStartPadding + _kLeaderIconSize + _kLeaderIconToTextGap;
const double _kMoreIconEndPadding = 10.0;
const double _kMoreIconSize = 24.0;

class TravelMemberItem extends StatefulWidget {
  const TravelMemberItem({
    super.key,
    required this.nickname,
    required this.isLeader,
    this.canManage = false,
    this.onDelete,
    this.assetPackage,
  });

  final String nickname;
  final bool isLeader;
  final bool canManage;
  final VoidCallback? onDelete;
  final String? assetPackage;

  @override
  State<TravelMemberItem> createState() => _TravelMemberItemState();
}

class _TravelMemberItemState extends State<TravelMemberItem> {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.isLeader) ...[
            Padding(
              padding: const EdgeInsets.only(left: _kLeaderIconStartPadding),
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
            child: Text(
              widget.nickname,
              style: AppTextStyles.subTitle.copyWith(
                color: AppColors.text,
                package: widget.assetPackage,
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
        isLeader: false,
        canManage: false,
      ),
    ),
  );
}
