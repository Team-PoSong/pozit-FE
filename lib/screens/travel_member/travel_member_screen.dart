import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/app_travel_status.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../data/models/travel_member_model.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';
import 'widgets/travel_member_item.dart';

const double _kHorizontalPadding = 24.0;

const double _kTopBarToFirstGap = 24.0;
const double _kTitleToDescGap = 12.0;
const double _kDescToCodeBoxesGap = 21.0;
const double _kCodeBoxesToCopyGap = 12.0;
const double _kCopyToShareButtonGap = 22.0;
const double _kShareButtonToDividerGap = 18.0;
const double _kDividerThickness = 8.0;
const double _kDividerToMembersTitleGap = 27.0;
const double _kMembersTitleToListGap = 24.0;

const double _kMemberItemGap = 16.0;

const double _kCodeBoxHeight = 67.0;
const double _kCodeBoxRadius = 4.0;
const double _kCodeBoxGap = 10.0;

class TravelMemberScreen extends StatelessWidget {
  const TravelMemberScreen({
    super.key,
    required this.isLeader,
    required this.status,
    required this.members,
    this.inviteCode,
    this.onBackTap,
    this.onCopyCode,
    this.onShareTap,
    this.onDeleteMember,
  }) : assert(
         !isLeader || status == AppTravelStatus.completed || inviteCode != null,
         '팀장 화면에서는 inviteCode가 필요합니다.',
       );

  final bool isLeader;
  final AppTravelStatus status;
  final List<TravelMemberModel> members;

  final String? inviteCode;

  final VoidCallback? onBackTap;

  final VoidCallback? onCopyCode;

  final VoidCallback? onShareTap;

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
              if (isLeader &&
                  status != AppTravelStatus.completed &&
                  inviteCode != null) ...[
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
                        isLeader: members[i].isLeader,
                        canManage: isLeader && !members[i].isLeader,
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
    TravelMemberModel(nickname: '김윤지', isLeader: true),
    TravelMemberModel(nickname: '박서현', isLeader: false),
    TravelMemberModel(nickname: '이하림', isLeader: false),
  ];
}

@Preview(group: 'travel_member', name: 'TravelMemberScreen - 팀장', size: Size(390, 844))
Widget travelMemberScreenLeaderPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelMemberScreen(
      isLeader: true,
      status: AppTravelStatus.inProgress,
      inviteCode: 'AB12C',
      members: _previewMembers(),
    ),
  );
}

@Preview(group: 'travel_member', name: 'TravelMemberScreen - 팀원', size: Size(390, 844))
Widget travelMemberScreenMemberPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelMemberScreen(
      isLeader: false,
      status: AppTravelStatus.inProgress,
      members: _previewMembers(),
    ),
  );
}

@Preview(
  group: 'travel_member',
  name: 'TravelMemberScreen - 팀장, 여행 완료',
  size: Size(390, 844),
)
Widget travelMemberScreenLeaderCompletedPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelMemberScreen(
      isLeader: true,
      status: AppTravelStatus.completed,
      members: _previewMembers(),
    ),
  );
}
