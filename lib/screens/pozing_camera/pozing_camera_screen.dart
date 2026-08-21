import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/network/api_exception.dart';
import '../../data/repositories/pozing/pozing_repository.dart';

const Duration _kMaxRecordingDuration = Duration(seconds: 3);

enum _CaptureStatus { capturing, uploading, error }

class PozingCameraScreen extends StatefulWidget {
  const PozingCameraScreen({
    super.key,
    required this.courseSpotId,
    this.repository = const PozingRepository(),
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker;

  final int courseSpotId;
  final PozingRepository repository;
  final ImagePicker? _imagePicker;

  @override
  State<PozingCameraScreen> createState() => _PozingCameraScreenState();
}

class _PozingCameraScreenState extends State<PozingCameraScreen> {
  late final ImagePicker _imagePicker = widget._imagePicker ?? ImagePicker();

  _CaptureStatus _status = _CaptureStatus.capturing;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _capture());
  }

  Future<void> _capture() async {
    if (mounted) {
      setState(() {
        _status = _CaptureStatus.capturing;
        _errorMessage = '';
      });
    }

    XFile? video;
    try {
      // OS 기본 카메라 앱을 그대로 띄워 촬영을 위임한다.
      video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxDuration: _kMaxRecordingDuration,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = _CaptureStatus.error;
        _errorMessage = '카메라를 사용할 수 없어요. 카메라 권한을 확인해 주세요.';
      });
      return;
    }

    if (!mounted) return;

    if (video == null) {
      Navigator.of(context).maybePop();
      return;
    }

    await _upload(File(video.path));
  }

  Future<void> _upload(File videoFile) async {
    setState(() => _status = _CaptureStatus.uploading);

    try {
      final result = await widget.repository.uploadPozingVideo(
        courseSpotId: widget.courseSpotId,
        videoFile: videoFile,
      );
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _status = _CaptureStatus.error;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = _CaptureStatus.error;
        _errorMessage = '포징 영상을 업로드하지 못했어요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: switch (_status) {
          _CaptureStatus.capturing => const SizedBox.shrink(),
          _CaptureStatus.uploading => const Center(
            child: CircularProgressIndicator(color: AppColors.white),
          ),
          _CaptureStatus.error => _buildError(),
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.subTitle.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text(
                    '닫기',
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _capture,
                  child: const Text(
                    '다시 시도',
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
