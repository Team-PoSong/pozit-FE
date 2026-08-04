import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' show LatLng;

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_travel_status.dart';
import '../../core/location/course_visiting.dart';
import '../../core/network/api_exception.dart';
import '../../core/travel/course_focus.dart';
import '../../data/datasources/auth/auth_token_storage.dart';
import '../../data/models/travel/travel_detail_model.dart';
import '../../data/models/travel/travel_info_card_model.dart';
import '../../data/models/travel/travel_tag_model.dart';
import '../../data/models/travel/travel_update_request.dart';
import '../../data/repositories/travel/travel_repository.dart';
import '../course_edit/course_edit_screen.dart';
import '../travel_course_map/travel_course_map_screen.dart';
import '../travel_member/travel_member_screen.dart';
import '../travel_settings/travel_settings_screen.dart';
import 'travel_detail_screen.dart';

const Duration _kLocationFixTimeout = Duration(seconds: 3);

enum _LoadStatus { loading, error, loaded }

class TravelDetailPage extends StatefulWidget {
  const TravelDetailPage({
    super.key,
    required this.travelId,
    this.repository = const TravelRepository(),
    this.tokenStorage = const AuthTokenStorage(),
  });

  final int travelId;
  final TravelRepository repository;
  final AuthTokenStorage tokenStorage;

  @override
  State<TravelDetailPage> createState() => _TravelDetailPageState();
}

class _TravelDetailPageState extends State<TravelDetailPage> {
  _LoadStatus _status = _LoadStatus.loading;
  String _errorMessage = '';

  TravelDetailModel? _detail;
  List<TravelTagModel> _tagOptions = const [];
  bool _isLeader = false;
  int _initialDay = 1;
  int _initialCourseIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted && _status != _LoadStatus.loading) {
      setState(() => _status = _LoadStatus.loading);
    }

    try {
      final results = await Future.wait([
        widget.repository.getTravelDetail(widget.travelId),
        _tryGetCurrentLocation(),
        _tryGetTags(),
      ]);
      final detail = results[0] as TravelDetailModel;
      final location = results[1] as LatLng?;
      final tagOptions = results[2] as List<TravelTagModel>;

      final myUserId = await widget.tokenStorage.readUserId();

      final nearbyFocus = detail.status == AppTravelStatus.inProgress
          ? nearbyCourseFocus(location, detail.courses)
          : null;
      final focus = nearbyFocus ?? defaultTravelFocus(detail.courses);

      if (!mounted) return;
      setState(() {
        _detail = detail;
        _tagOptions = tagOptions;
        _isLeader = myUserId != null &&
            detail.members.any(
              (member) => member.userId == myUserId && member.isLeader,
            );
        _initialDay = focus.dayNumber;
        _initialCourseIndex = focus.courseIndex;
        _status = _LoadStatus.loaded;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _status = _LoadStatus.error;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '여행 정보를 불러오지 못했어요.';
        _status = _LoadStatus.error;
      });
    }
  }

  Future<List<TravelTagModel>> _tryGetTags() async {
    try {
      return await widget.repository.getTags();
    } catch (_) {
      return const [];
    }
  }

  Future<LatLng?> _tryGetCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(_kLocationFixTimeout);
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  void _openMemberScreen(BuildContext context) {
    final detail = _detail!;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TravelMemberScreen(
          isLeader: _isLeader,
          status: detail.status,
          members: detail.members,
          inviteCode: detail.inviteCode,
        ),
      ),
    );
  }

  void _openCourseMapScreen(BuildContext context, int day) {
    final detail = _detail!;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TravelCourseMapScreen(
          courses: detail.courses,
          status: detail.status,
          totalDays: detail.endDate.difference(detail.startDate).inDays + 1,
          initialDay: day,
        ),
      ),
    );
  }

  void _openSettingsScreen(BuildContext context) {
    final detail = _detail!;
    final initialTagIds = _tagOptions
        .where((tag) => detail.tags.contains(tag.name))
        .map((tag) => tag.id)
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TravelSettingsScreen(
          status: detail.status,
          destination: detail.destination,
          tagOptions: _tagOptions,
          initialTravelName: detail.title,
          initialStartDate: detail.startDate,
          initialEndDate: detail.endDate,
          initialTagIds: initialTagIds,
          initialIsPublic: detail.isPublic,
          onSave: (result) => _handleSettingsSave(context, detail, result),
        ),
      ),
    );
  }

  Future<void> _handleSettingsSave(
    BuildContext context,
    TravelDetailModel detail,
    TravelSettingsResult result,
  ) async {
    final errors = <String>[];

    try {
      await widget.repository.updateTravel(
        widget.travelId,
        TravelUpdateRequest(
          title: result.travelName,
          destination: detail.destination,
          startDate: result.startDate,
          endDate: result.endDate,
          tagIds: result.tagIds,
        ),
      );
    } on ApiException catch (error) {
      errors.add(error.message);
    } catch (_) {
      errors.add('여행 정보를 수정하지 못했어요.');
    }

    // 완료된 여행만 공개 설정을 변경할 수 있고, 값이 실제로 바뀌었을 때만 호출합니다.
    if (detail.status == AppTravelStatus.completed &&
        result.isPublic != detail.isPublic) {
      try {
        await widget.repository.updateVisibility(
          widget.travelId,
          result.isPublic,
        );
      } on ApiException catch (error) {
        errors.add(error.message);
      } catch (_) {
        errors.add('공개 설정을 변경하지 못했어요.');
      }
    }

    await _load();

    if (errors.isNotEmpty && context.mounted) {
      _showSnackBar(context, errors.join('\n'));
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openCourseEditScreen(BuildContext context) {
    final detail = _detail!;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CourseEditScreen(
          courses: detail.courses,
          initialDay: _initialDay,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case _LoadStatus.loading:
        return const Scaffold(
          backgroundColor: AppColors.white,
          body: Center(child: CircularProgressIndicator()),
        );
      case _LoadStatus.error:
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_errorMessage, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextButton(onPressed: _load, child: const Text('다시 시도')),
              ],
            ),
          ),
        );
      case _LoadStatus.loaded:
        final detail = _detail!;
        return TravelDetailScreen(
          title: detail.title,
          info: TravelInfoCardModel.fromTravelDetail(detail),
          status: detail.status,
          isLeader: _isLeader,
          isPublic: detail.isPublic,
          courses: detail.courses,
          initialDay: _initialDay,
          initialCourseIndex: _initialCourseIndex,
          backgroundImage: detail.backgroundImageUrl.isNotEmpty
              ? NetworkImage(detail.backgroundImageUrl)
              : const AssetImage(AppImages.travelMockup),
          onBackTap: () => Navigator.of(context).maybePop(),
          onSettingsTap: () => _openSettingsScreen(context),
          onMemberTap: () => _openMemberScreen(context),
          onCourseTap: (day) => _openCourseMapScreen(context, day),
          onCourseEditTap: () => _openCourseEditScreen(context),
        );
    }
  }
}
