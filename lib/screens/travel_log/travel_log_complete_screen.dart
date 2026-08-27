import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_toast.dart';
import '../../core/network/api_exception.dart';
import '../../data/repositories/pozing/pozing_repository.dart';

const double _kHorizontalPadding = 78.0;
const double _kTopToHeaderGap = 58.0;
const double _kTextToTicketGap = 9.0;
const double _kTicketWidth = 59.0;
const double _kTicketHeight = 89.0;
const double _kHeaderToLogGap = 29.0;
const double _kLogBlockAspectRatio = 236 / 421;
const double _kLogBlockRadius = 12.0;
const double _kButtonsBottomGap = 37.0;
const double _kButtonGap = 54.0;
const double _kButtonCircleSize = 60.0;
const double _kButtonBorderWidth = 1.0;
const double _kButtonIconSize = 30.0;
const double _kButtonIconToLabelGap = 13.0;

const String _kSavedAlbumName = 'Pozit';

enum _BusyAction { none, saving, sharing }

class TravelLogCompleteScreen extends StatefulWidget {
  const TravelLogCompleteScreen({
    super.key,
    required this.travelName,
    this.downloadUrl,
    this.onCancelTap,
    this.repository = const PozingRepository(),
  });

  final String travelName;

  final String? downloadUrl;
  final VoidCallback? onCancelTap;
  final PozingRepository repository;

  @override
  State<TravelLogCompleteScreen> createState() =>
      _TravelLogCompleteScreenState();
}

class _TravelLogCompleteScreenState extends State<TravelLogCompleteScreen> {
  _BusyAction _busy = _BusyAction.none;
  VideoPlayerController? _previewController;
  bool _previewFailed = false;

  @override
  void initState() {
    super.initState();
    _initializePreview();
  }

  void _initializePreview() {
    final downloadUrl = widget.downloadUrl;
    if (downloadUrl == null) return;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(downloadUrl),
    );
    _previewController = controller;
    controller.setLooping(true);
    controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {});
          controller.play();
        })
        .catchError((_) {
          if (!mounted) return;
          setState(() => _previewFailed = true);
        });
  }

  @override
  void dispose() {
    _previewController?.dispose();
    super.dispose();
  }

  Future<void> _handleSaveTap() async {
    final downloadUrl = widget.downloadUrl;
    if (downloadUrl == null || _busy != _BusyAction.none) return;

    setState(() => _busy = _BusyAction.saving);
    try {
      final file = await widget.repository.downloadEditedVideo(downloadUrl);
      await Gal.putVideo(file.path, album: _kSavedAlbumName);
      if (!mounted) return;
      _showToast('기기에 저장했어요.');
    } on GalException {
      if (!mounted) return;
      _showToast('저장 권한이 없어서 저장하지 못했어요.');
    } on ApiException catch (error) {
      if (!mounted) return;
      _showToast(error.message);
    } catch (_) {
      if (!mounted) return;
      _showToast('저장하지 못했어요.');
    } finally {
      if (mounted) setState(() => _busy = _BusyAction.none);
    }
  }

  Future<void> _handleShareTap() async {
    final downloadUrl = widget.downloadUrl;
    if (downloadUrl == null || _busy != _BusyAction.none) return;

    setState(() => _busy = _BusyAction.sharing);
    try {
      final file = await widget.repository.downloadEditedVideo(downloadUrl);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } on ApiException catch (error) {
      if (!mounted) return;
      _showToast(error.message);
    } catch (_) {
      if (!mounted) return;
      _showToast('공유하지 못했어요.');
    } finally {
      if (mounted) setState(() => _busy = _BusyAction.none);
    }
  }

  void _showToast(String message) {
    showAppToast(context, message);
  }

  Widget _buildLogPreview() {
    if (widget.downloadUrl == null || _previewFailed) {
      return const SizedBox.shrink();
    }

    final controller = _previewController;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.white),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.travelLogGradientStart,
                AppColors.travelLogGradientEnd,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: _kTopToHeaderGap),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kHorizontalPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            '${widget.travelName}의 추억이 담긴\n여행 로그가 저장되었어요!',
                            style: AppTextStyles.subTitle.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: _kTextToTicketGap),
                      Image.asset(
                        AppImages.carrierTicket,
                        width: _kTicketWidth,
                        height: _kTicketHeight,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: _kHeaderToLogGap),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kHorizontalPadding,
                  ),
                  child: AspectRatio(
                    aspectRatio: _kLogBlockAspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(_kLogBlockRadius),
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: AppColors.text,
                        ),
                        child: _buildLogPreview(),
                      ),
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LogActionButton(
                      icon: AppIcons.x,
                      label: '취소',
                      onTap: widget.onCancelTap,
                    ),
                    const SizedBox(width: _kButtonGap),
                    _LogActionButton(
                      icon: AppIcons.save,
                      label: '저장',
                      isLoading: _busy == _BusyAction.saving,
                      onTap: _busy == _BusyAction.none
                          ? _handleSaveTap
                          : null,
                    ),
                    const SizedBox(width: _kButtonGap),
                    _LogActionButton(
                      icon: AppIcons.share,
                      label: '공유',
                      isLoading: _busy == _BusyAction.sharing,
                      onTap: _busy == _BusyAction.none
                          ? _handleShareTap
                          : null,
                    ),
                  ],
                ),
                SizedBox(
                  height:
                      _kButtonsBottomGap + MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogActionButton extends StatelessWidget {
  const _LogActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isLoading = false,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: Material(
            color: AppColors.white,
            shape: const CircleBorder(
              side: BorderSide(
                color: AppColors.gray3,
                width: _kButtonBorderWidth,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: _kButtonCircleSize,
                height: _kButtonCircleSize,
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: _kButtonIconSize,
                          height: _kButtonIconSize,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : SvgPicture.asset(
                          icon,
                          width: _kButtonIconSize,
                          height: _kButtonIconSize,
                          excludeFromSemantics: true,
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: _kButtonIconToLabelGap),
        Text(
          label,
          style: AppTextStyles.caption2.copyWith(color: AppColors.gray5),
        ),
      ],
    );
  }
}

@Preview(
  group: 'travel_log',
  name: 'TravelLogCompleteScreen',
  size: Size(390, 844),
)
Widget travelLogCompleteScreenPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelLogCompleteScreen(travelName: '경주여행'),
  );
}
