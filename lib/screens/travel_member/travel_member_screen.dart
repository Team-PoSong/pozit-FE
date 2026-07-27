import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../data/models/travel_member_model.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';
import 'widgets/travel_member_item.dart';

const double _kHorizontalPadding = 24.0;
// TravelDetailTopBar가 자체적으로 위에 4px을 더 내려가므로(_kTopOffset),
// 탑 바 다음 요소의 위치가 그대로 유지되도록 이 간격을 8px 줄였습니다.
const double _kTopBarToFirstGap = 24.0;
const double _kTitleToDescGap = 12.0;
const double _kDescToCodeBoxesGap = 21.0;
const double _kCodeBoxesToCopyGap = 12.0;
const double _kCopyToShareButtonGap = 22.0;
const double _kShareButtonToDividerGap = 18.0;
const double _kDividerThickness = 8.0;
const double _kDividerToMembersTitleGap = 27.0;
const double _kMembersTitleToListGap = 24.0;
// 멤버 행 사이 간격은 디자인 명세에 없어 목록 내 다른 항목들과 비슷한
// 값으로 임의 지정했습니다. 실제 디자인이 나오면 조정해주세요.
const double _kMemberItemGap = 16.0;

const double _kCodeBoxHeight = 67.0;
const double _kCodeBoxRadius = 4.0;
const double _kCodeBoxGap = 10.0;

/// 여행 상세의 설정 팝업에서 '멤버'를 눌렀을 때 뜨는 화면입니다.
///
/// [isLeader]가 true(팀장)면 위쪽에 초대 코드 섹션이 추가로 표시되고,
/// 아래 멤버 목록에서도 다른 멤버를 삭제할 수 있는 더보기 버튼이 함께
/// 표시됩니다. 팀원은 참여한 팀원 목록만 볼 수 있습니다.
class TravelMemberScreen extends StatelessWidget {
  const TravelMemberScreen({
    super.key,
    required this.isLeader,
    required this.members,
    this.inviteCode,
    this.onBackTap,
    this.onCopyCode,
    this.onShareTap,
    this.onDeleteMember,
  }) : assert(
         !isLeader || inviteCode != null,
         '팀장 화면에서는 inviteCode가 필요합니다.',
       );

  final bool isLeader;
  final List<TravelMemberModel> members;

  /// 초대 코드입니다. [isLeader]가 true이면 필수입니다.
  final String? inviteCode;

  final VoidCallback? onBackTap;

  /// '코드 복사'를 눌러 클립보드 복사가 끝난 뒤 호출됩니다.
  final VoidCallback? onCopyCode;

  /// '링크 공유하기' 버튼을 눌렀을 때 호출됩니다.
  final VoidCallback? onShareTap;

  /// 멤버 삭제 확인 다이얼로그에서 '삭제하기'를 눌렀을 때, 삭제 대상 멤버와
  /// 함께 호출됩니다.
  final ValueChanged<TravelMemberModel>? onDeleteMember;

  void _handleBack(BuildContext context) {
    onBackTap?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TravelDetailTopBar(
                title: '멤버',
                onBackTap: () => _handleBack(context),
              ),
              const SizedBox(height: _kTopBarToFirstGap),
              if (isLeader) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kHorizontalPadding,
                  ),
                  child: _InviteCodeSection(
                    code: inviteCode!,
                    onCopyTap: onCopyCode,
                    onShareTap: onShareTap,
                  ),
                ),
                const SizedBox(height: _kShareButtonToDividerGap),
                const _FullWidthDivider(),
                const SizedBox(height: _kDividerToMembersTitleGap),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _kHorizontalPadding,
                ),
                child: Text(
                  '참여한 팀원(${members.length}명)',
                  style: AppTextStyles.headline.copyWith(color: AppColors.text),
                ),
              ),
              const SizedBox(height: _kMembersTitleToListGap),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _kHorizontalPadding,
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < members.length; i++) ...[
                      if (i > 0) const SizedBox(height: _kMemberItemGap),
                      TravelMemberItem(
                        nickname: members[i].nickname,
                        userId: members[i].userId,
                        isLeader: members[i].isLeader,
                        canManage: isLeader,
                        onDelete: onDeleteMember == null
                            ? null
                            : () => onDeleteMember!(members[i]),
                      ),
                    ],
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

class _FullWidthDivider extends StatelessWidget {
  const _FullWidthDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: _kDividerThickness,
      child: ColoredBox(color: AppColors.gray2),
    );
  }
}

class _InviteCodeSection extends StatelessWidget {
  const _InviteCodeSection({
    required this.code,
    this.onCopyTap,
    this.onShareTap,
  });

  final String code;
  final VoidCallback? onCopyTap;
  final VoidCallback? onShareTap;

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: code));
    onCopyTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final characters = code.split('');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '초대 코드',
          textAlign: TextAlign.center,
          style: AppTextStyles.headline.copyWith(color: AppColors.text),
        ),
        const SizedBox(height: _kTitleToDescGap),
        Text(
          '최대 4명까지 함께 여행할 수 있어요.',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(color: Colors.black),
        ),
        const SizedBox(height: _kDescToCodeBoxesGap),
        Row(
          children: [
            for (var i = 0; i < characters.length; i++) ...[
              if (i > 0) const SizedBox(width: _kCodeBoxGap),
              Expanded(child: _CodeBox(character: characters[i])),
            ],
          ],
        ),
        const SizedBox(height: _kCodeBoxesToCopyGap),
        GestureDetector(
          onTap: _handleCopy,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(AppIcons.copy, width: 24, height: 24),
              const SizedBox(width: 12),
              Text(
                '코드 복사',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.text,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _kCopyToShareButtonGap),
        AppButton(
          text: '링크 공유하기',
          iconAsset: AppIcons.shareWhite,
          iconWidth: 24,
          iconHeight: 24,
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          onPressed: onShareTap,
        ),
      ],
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({required this.character});

  final String character;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kCodeBoxHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.gray2,
        borderRadius: BorderRadius.circular(_kCodeBoxRadius),
      ),
      child: Text(
        character,
        style: AppTextStyles.headline.copyWith(color: AppColors.text),
      ),
    );
  }
}

List<TravelMemberModel> _previewMembers() {
  return const [
    TravelMemberModel(nickname: '김윤지', userId: 'yoonji_kim', isLeader: true),
    TravelMemberModel(nickname: '박서현', userId: 'seohyun_park', isLeader: false),
    TravelMemberModel(nickname: '이하림', userId: 'harim_lee', isLeader: false),
  ];
}

@Preview(group: 'travel_member', name: 'TravelMemberScreen - 팀장', size: Size(390, 844))
Widget travelMemberScreenLeaderPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelMemberScreen(
      isLeader: true,
      inviteCode: 'AB12C',
      members: _previewMembers(),
    ),
  );
}

@Preview(group: 'travel_member', name: 'TravelMemberScreen - 팀원', size: Size(390, 844))
Widget travelMemberScreenMemberPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelMemberScreen(isLeader: false, members: _previewMembers()),
  );
}
