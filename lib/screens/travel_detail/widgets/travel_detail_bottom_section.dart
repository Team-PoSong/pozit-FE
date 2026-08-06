import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_images.dart';
import '../../../core/design_system/app_text_styles.dart';
import '../../../core/design_system/app_travel_status.dart';
import '../../../core/design_system/widgets/app_posing.dart';
import '../../../core/design_system/widgets/button/app_button.dart';

const double _kHorizontalPadding = 24.0;
const double _kStatusToContentGap = 15.0;
const double _kPosingGap = 12.0;
const double _kPosingToButtonGap = 30.0;

const double _kTicketToTextGap = 21.0;

const double _kCarrierTicketWidth = 121.0;

const double _kBottomSafeGap = 7.0;
const double _kInProgressBottomGap = 10.0;

const Duration _kCourseSwipeCueDuration = Duration(milliseconds: 260);
// Matches the map card's title label swipe: that text slides by 0.3 of its
// own (narrow) width, which works out to roughly this many logical pixels.
// The camera column is full-width, so it uses this fixed pixel distance
// instead of the same 0.3 fraction of its own (much wider) width.
const double _kCourseSwipeCueTranslateX = 24.0;
const double _kCourseSwipeCueBeginOpacity = 0.6;

class TravelDetailBottomSection extends StatelessWidget {
  const TravelDetailBottomSection({
    super.key,
    required this.status,
    required this.memberNames,
    this.onSaveLogTap,
    this.cameraKey,
    this.courseTransitionKey,
    this.isCameraReady = false,
    this.onCameraTap,
  });

  final AppTravelStatus status;

  /// 본인의 타일이 항상 맨 앞에 오도록 정렬된 참여 멤버 이름 목록입니다.
  final List<String> memberNames;
  final VoidCallback? onSaveLogTap;
  final Key? cameraKey;

  final Object? courseTransitionKey;

  /// Whether the current user is within the visiting radius of a course
  /// spot, so their own posing tile's camera should be shown as on.
  final bool isCameraReady;

  /// 본인 타일의 카메라가 켜져 있을 때 탭하면 촬영 화면으로 이동합니다.
  final VoidCallback? onCameraTap;

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
              memberNames: memberNames,
              cameraKey: cameraKey,
              isCameraReady: isCameraReady,
              onCameraTap: onCameraTap,
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
                child: _PosingColumn(memberNames: memberNames),
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
    required this.memberNames,
    this.cameraKey,
    this.isCameraReady = false,
    this.onCameraTap,
  });

  final List<String> memberNames;
  final Key? cameraKey;
  final bool isCameraReady;
  final VoidCallback? onCameraTap;

  @override
  Widget build(BuildContext context) {
    // memberNames는 본인을 포함한 전체 참여 멤버 이름 목록입니다(본인이 0번).
    // 멤버 정보가 아직 없을 때도 방어적으로 본인 카메라 타일은 항상 보장합니다.
    final names = memberNames.isNotEmpty ? memberNames : const [''];
    return Column(
      children: [
        for (int i = 0; i < names.length; i++) ...[
          if (i > 0) const SizedBox(height: _kPosingGap),
          AppPosing(
            key: i == 0 ? cameraKey : null,
            name: names[i].isEmpty ? null : names[i],
            isCameraOn: i == 0 && isCameraReady,
            onTap: i == 0 && isCameraReady ? onCameraTap : null,
          ),
        ],
      ],
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
          memberNames: ['현영', '윤지', '해림'],
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
        memberNames: ['현영', '윤지', '해림'],
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
        memberNames: ['현영', '윤지', '해림'],
      ),
    ),
  );
}
