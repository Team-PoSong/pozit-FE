import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_images.dart';
import '../../../core/design_system/app_text_styles.dart';
import '../../../core/design_system/app_travel_status.dart';
import '../../../core/design_system/widgets/app_posing.dart';
import '../../../core/design_system/widgets/button/app_button.dart';
import '../../../data/models/travel/travel_member_model.dart';

const double _kHorizontalPadding = 24.0;
const double _kStatusToContentGap = 15.0;
const double _kPosingGap = 12.0;
const double _kPosingToButtonGap = 30.0;

const double _kTicketToTextGap = 21.0;

const double _kCarrierTicketWidth = 121.0;

const double _kBottomSafeGap = 7.0;
const double _kInProgressBottomGap = 10.0;

const Duration _kCourseSwipeCueDuration = Duration(milliseconds: 260);
const double _kCourseSwipeCueTranslateX = 24.0;
const double _kCourseSwipeCueBeginOpacity = 0.6;

const List<TravelMemberModel> _kPreviewMembers = [
  TravelMemberModel(userId: 1, nickname: '현영', isLeader: true),
  TravelMemberModel(userId: 2, nickname: '윤지', isLeader: false),
  TravelMemberModel(userId: 3, nickname: '해림', isLeader: false),
];

class TravelDetailBottomSection extends StatelessWidget {
  const TravelDetailBottomSection({
    super.key,
    required this.status,
    required this.members,
    this.myUserId,
    this.onSaveLogTap,
    this.cameraKey,
    this.courseTransitionKey,
    this.isCameraReady = false,
    this.onCameraTap,
    this.memberThumbnails = const {},
    this.isCameraThumbnailPending = false,
  });

  final AppTravelStatus status;

  final List<TravelMemberModel> members;
  final int? myUserId;
  final VoidCallback? onSaveLogTap;
  final Key? cameraKey;

  final Object? courseTransitionKey;

  final bool isCameraReady;

  final VoidCallback? onCameraTap;

  final Map<int, String> memberThumbnails;

  final bool isCameraThumbnailPending;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AppTravelStatus.upcoming:
        return Padding(
          padding: EdgeInsets.fromLTRB(
            _kHorizontalPadding,
            _kStatusToContentGap,
            _kHorizontalPadding,
            _kBottomSafeGap + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image(
                  image: const AssetImage(AppImages.carrierTicket),
                  width: _kCarrierTicketWidth,
                ),
              ),
              const SizedBox(height: _kTicketToTextGap),
              Text(
                '여행이 시작되면 기록할 수 있어요.',
                textAlign: TextAlign.center,
                style: AppTextStyles.subTitle.copyWith(color: AppColors.gray5),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      case AppTravelStatus.inProgress:
        return Padding(
          padding: EdgeInsets.fromLTRB(
            _kHorizontalPadding,
            _kStatusToContentGap,
            _kHorizontalPadding,
            _kInProgressBottomGap + MediaQuery.of(context).padding.bottom,
          ),
          child: _CourseSwipeCue(
            courseKey: courseTransitionKey,
            child: _PosingColumn(
              members: members,
              myUserId: myUserId,
              cameraKey: cameraKey,
              isCameraReady: isCameraReady,
              onCameraTap: onCameraTap,
              memberThumbnails: memberThumbnails,
              isCameraThumbnailPending: isCameraThumbnailPending,
            ),
          ),
        );
      case AppTravelStatus.completed:
        return Padding(
          padding: EdgeInsets.fromLTRB(
            _kHorizontalPadding,
            _kStatusToContentGap,
            _kHorizontalPadding,
            _kBottomSafeGap + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CourseSwipeCue(
                courseKey: courseTransitionKey,
                child: _PosingColumn(
                  members: members,
                  myUserId: myUserId,
                  memberThumbnails: memberThumbnails,
                ),
              ),
              const SizedBox(height: _kPosingToButtonGap),
              AppButton(text: '여행 로그 저장하기', onPressed: onSaveLogTap),
            ],
          ),
        );
    }
  }
}

class _PosingColumn extends StatelessWidget {
  const _PosingColumn({
    required this.members,
    this.myUserId,
    this.memberThumbnails = const {},
    this.cameraKey,
    this.isCameraReady = false,
    this.onCameraTap,
    this.isCameraThumbnailPending = false,
  });

  final List<TravelMemberModel> members;
  final int? myUserId;
  final Map<int, String> memberThumbnails;
  final Key? cameraKey;
  final bool isCameraReady;
  final VoidCallback? onCameraTap;
  final bool isCameraThumbnailPending;

  @override
  Widget build(BuildContext context) {
    final rows = members.isNotEmpty
        ? members
        : const [TravelMemberModel(userId: 0, nickname: '', isLeader: false)];
    return Column(
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: _kPosingGap),
          _buildMemberPosing(
            rows[i],
            isSelf: myUserId != null && rows[i].userId == myUserId,
          ),
        ],
      ],
    );
  }

  Widget _buildMemberPosing(TravelMemberModel member, {required bool isSelf}) {
    final thumbnailUrl = memberThumbnails[member.userId];
    final isPending = isSelf && isCameraThumbnailPending;
    final canTap = isSelf && isCameraReady && !isPending;
    return AppPosing(
      key: isSelf ? cameraKey : null,
      name: member.nickname.isEmpty ? null : member.nickname,
      isCameraOn: canTap && thumbnailUrl == null,
      thumbnailUrl: thumbnailUrl,
      isThumbnailPending: isPending,
      onTap: canTap ? onCameraTap : null,
    );
  }
}

class _CourseSwipeCue extends StatefulWidget {
  const _CourseSwipeCue({required this.courseKey, required this.child});

  final Object? courseKey;
  final Widget child;

  @override
  State<_CourseSwipeCue> createState() => _CourseSwipeCueState();
}

class _CourseSwipeCueState extends State<_CourseSwipeCue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _kCourseSwipeCueDuration,
    value: 1,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );
  late final Animation<double> _opacity = Tween<double>(
    begin: _kCourseSwipeCueBeginOpacity,
    end: 1,
  ).animate(_curve);

  @override
  void didUpdateWidget(covariant _CourseSwipeCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courseKey != widget.courseKey) {
      _controller
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: AnimatedBuilder(
        animation: _curve,
        child: widget.child,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_kCourseSwipeCueTranslateX * (1 - _curve.value), 0),
            child: child,
          );
        },
      ),
    );
  }
}

@Preview(group: 'travel_detail', name: 'BottomSection - 여행 전')
Widget travelDetailBottomSectionUpcomingPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 300,
        child: TravelDetailBottomSection(
          status: AppTravelStatus.upcoming,
          members: _kPreviewMembers,
        ),
      ),
    ),
  );
}

@Preview(group: 'travel_detail', name: 'BottomSection - 여행 중')
Widget travelDetailBottomSectionInProgressPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: TravelDetailBottomSection(
        status: AppTravelStatus.inProgress,
        members: _kPreviewMembers,
      ),
    ),
  );
}

@Preview(group: 'travel_detail', name: 'BottomSection - 여행 후')
Widget travelDetailBottomSectionCompletedPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: TravelDetailBottomSection(
        status: AppTravelStatus.completed,
        members: _kPreviewMembers,
      ),
    ),
  );
}
