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
import '../../data/models/travel/travel_course_model.dart';
import '../../data/models/travel/travel_detail_model.dart';
import '../../data/models/travel/travel_info_card_model.dart';
import '../../data/models/travel/travel_tag_model.dart';
import '../../data/models/travel/travel_update_request.dart';
import '../../data/models/pozing_edit_job_model.dart';
import '../../data/repositories/pozing/pozing_repository.dart';
import '../../data/repositories/tourist_spot/tourist_spot_repository.dart';
import '../../data/repositories/travel/travel_repository.dart';
import '../course_edit/course_edit_screen.dart';
import '../travel_course_map/travel_course_map_screen.dart';
import '../travel_log/travel_log_complete_screen.dart';
import '../travel_log/travel_log_saving_screen.dart';
import '../travel_member/travel_member_screen.dart';
import '../travel_settings/travel_settings_screen.dart';
import 'travel_detail_screen.dart';

const Duration _kLocationFixTimeout = Duration(seconds: 3);
const Duration _kEditPozingJobPollInterval = Duration(seconds: 2);
const int _kEditPozingJobMaxPollAttempts = 30;

enum _LoadStatus { loading, error, loaded }

class TravelDetailPage extends StatefulWidget {
  const TravelDetailPage({
    super.key,
    required this.travelId,
    this.repository = const TravelRepository(),
    this.touristSpotRepository = const TouristSpotRepository(),
    this.pozingRepository = const PozingRepository(),
    this.tokenStorage = const AuthTokenStorage(),
  });

  final int travelId;
  final TravelRepository repository;
  final TouristSpotRepository touristSpotRepository;
  final PozingRepository pozingRepository;
  final AuthTokenStorage tokenStorage;

  @override
  State<TravelDetailPage> createState() => _TravelDetailPageState();
}

class _TravelDetailPageState extends State<TravelDetailPage> {
  _LoadStatus _status = _LoadStatus.loading;
  String _errorMessage = '';

  TravelDetailModel? _detail;
  List<TravelTagModel> _tagOptions = const [];
  List<TravelTagModel> _travelTags = const [];
  String _inviteCode = '';
  bool _isLeader = false;
  int _initialDay = 1;
  int _initialSpotIndex = 0;

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
        _tryGetTravelTags(),
        _tryGetInviteCode(),
      ]);
      final detail = results[0] as TravelDetailModel;
      final location = results[1] as LatLng?;
      final tagOptions = results[2] as List<TravelTagModel>;
      final travelTags = results[3] as List<TravelTagModel>;
      final fetchedInviteCode = results[4] as String?;

      final myUserId = await widget.tokenStorage.readUserId();

      final nearbyFocus = detail.status == AppTravelStatus.inProgress
          ? nearbyCourseFocus(location, detail.courses)
          : null;
      final focus = nearbyFocus ?? defaultTravelFocus(detail.courses);

      if (!mounted) return;
      setState(() {
        _detail = detail;
        _tagOptions = tagOptions;
        _travelTags = travelTags;
        _inviteCode = (fetchedInviteCode != null && fetchedInviteCode.isNotEmpty)
            ? fetchedInviteCode
            : detail.inviteCode;
        _isLeader = myUserId != null &&
            detail.members.any(
              (member) => member.userId == myUserId && member.isLeader,
            );
        _initialDay = focus.dayNumber;
        _initialSpotIndex = focus.spotIndex;
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

  Future<List<TravelTagModel>> _tryGetTravelTags() async {
    try {
      return await widget.repository.getTravelTags(widget.travelId);
    } catch (_) {
      return const [];
    }
  }

  Future<String?> _tryGetInviteCode() async {
    try {
      return await widget.repository.getInviteCode(widget.travelId);
    } catch (_) {
      return null;
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
          inviteCode: _inviteCode,
        ),
      ),
    );
  }

  Future<void> _openCourseMapScreen(BuildContext context, int day) async {
    final detail = _detail!;
    final enrichedCourses = await _fetchEnrichedCourses(detail.courses);
    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TravelCourseMapScreen(
          courses: enrichedCourses,
          status: detail.status,
          totalDays: detail.endDate.difference(detail.startDate).inDays + 1,
          initialDay: day,
        ),
      ),
    );
  }

  /// getTravelDetail의 courses에는 address/imageUrl/initialFocusSpotId가
  /// 빠져 있어서, getCourseDetail로 코스별 상세 데이터를 보강합니다.
  /// 코스 하나가 실패해도 나머지는 그대로 쓰고, 실패한 코스만 기존 데이터로
  /// 대체합니다.
  Future<List<TravelCourseModel>> _fetchEnrichedCourses(
    List<TravelCourseModel> courses,
  ) async {
    final enriched = await Future.wait(
      courses.map((course) async {
        try {
          return await widget.repository.getCourseDetail(course.courseId);
        } catch (_) {
          return course;
        }
      }),
    );
    return enriched;
  }

  void _openSettingsScreen(BuildContext context) {
    final detail = _detail!;
    final initialTagIds = _travelTags.map((tag) => tag.id).toList();

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

    if (result.backgroundImage != null) {
      try {
        await widget.repository.uploadBackgroundImage(
          widget.travelId,
          result.backgroundImage!,
        );
      } on ApiException catch (error) {
        errors.add(error.message);
      } catch (_) {
        errors.add('배경 사진을 업로드하지 못했어요.');
      }
    }

    await _load();

    if (errors.isNotEmpty && context.mounted) {
      _showSnackBar(context, errors.join('\n'));
    }
  }

  Future<void> _handleSaveLogTap(BuildContext context) async {
    final detail = _detail!;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TravelLogSavingScreen(travelName: detail.title),
      ),
    );

    try {
      final job = await widget.pozingRepository.requestEditPozing(
        widget.travelId,
      );
      final status = await _pollEditPozingJob(job.jobId);

      if (!context.mounted) return;

      if (status.status == PozingEditJobStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => TravelLogCompleteScreen(
              travelName: detail.title,
              onCancelTap: () => Navigator.of(context).pop(),
            ),
          ),
        );
      } else {
        Navigator.of(context).pop();
        _showSnackBar(context, status.errorMessage ?? '여행 로그를 만들지 못했어요.');
      }
    } on ApiException catch (error) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      _showSnackBar(context, error.message);
    } catch (_) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      _showSnackBar(context, '여행 로그를 만들지 못했어요.');
    }
  }

  Future<PozingEditJobStatusResponse> _pollEditPozingJob(int jobId) async {
    for (var attempt = 0; attempt < _kEditPozingJobMaxPollAttempts; attempt++) {
      final status = await widget.pozingRepository.getEditPozingJob(jobId);
      if (!isPozingEditJobInProgress(status.status)) {
        return status;
      }
      await Future.delayed(_kEditPozingJobPollInterval);
    }
    throw const ApiException('여행 로그 생성이 너무 오래 걸리고 있어요.');
  }

  void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openCourseEditScreen(BuildContext context) async {
    final detail = _detail!;
    final enrichedCourses = await _fetchEnrichedCourses(detail.courses);
    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CourseEditScreen(
          courses: enrichedCourses,
          initialDay: _initialDay,
          onLoadPopularSpots: (cursor) => widget.touristSpotRepository
              .getHostTouristSpotsRank(cursor: cursor),
          onSearch: (keyword, cursor) => widget.touristSpotRepository
              .searchCourseSpots(keyword: keyword, cursor: cursor),
          onAddSelectedSpots: (selected) =>
              widget.touristSpotRepository.saveSelectedSpots(selected),
          onSave: (spotsByCourseId) =>
              _handleCourseEditSave(context, spotsByCourseId),
        ),
      ),
    );
  }

  Future<void> _handleCourseEditSave(
    BuildContext context,
    Map<int, List<CourseSpotModel>> spotsByCourseId,
  ) async {
    final errors = <String>[];

    for (final entry in spotsByCourseId.entries) {
      try {
        await widget.repository.updateCourseSpots(
          entry.key,
          entry.value.map((spot) => spot.touristSpotId).toList(),
        );
      } on ApiException catch (error) {
        errors.add(error.message);
      } catch (_) {
        errors.add('코스를 수정하지 못했어요.');
      }
    }

    await _load();

    if (errors.isNotEmpty && context.mounted) {
      _showSnackBar(context, errors.join('\n'));
    }
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
          info: TravelInfoCardModel.fromTravelDetail(
            detail,
            tags: _travelTags.map((tag) => tag.name).toList(),
          ),
          status: detail.status,
          isLeader: _isLeader,
          isPublic: detail.isPublic,
          courses: detail.courses,
          initialDay: _initialDay,
          initialSpotIndex: _initialSpotIndex,
          backgroundImage: detail.backgroundImageUrl.isNotEmpty
              ? NetworkImage(detail.backgroundImageUrl)
              : const AssetImage(AppImages.travelMockup),
          onBackTap: () => Navigator.of(context).maybePop(),
          onSettingsTap: () => _openSettingsScreen(context),
          onMemberTap: () => _openMemberScreen(context),
          onCourseTap: (day) => _openCourseMapScreen(context, day),
          onCourseEditTap: () => _openCourseEditScreen(context),
          onSaveLogTap: () => _handleSaveLogTap(context),
        );
    }
  }
}
