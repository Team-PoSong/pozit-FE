import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/network/api_exception.dart';
import '../../data/repositories/pozing/pozing_repository.dart';

const Duration _kMaxRecordingDuration = Duration(seconds: 3);

enum _CameraStatus { initializing, error, ready, recording, uploading }

class PozingCameraScreen extends StatefulWidget {
  const PozingCameraScreen({
    super.key,
    required this.courseSpotId,
    this.repository = const PozingRepository(),
  });

  final int courseSpotId;
  final PozingRepository repository;

  @override
  State<PozingCameraScreen> createState() => _PozingCameraScreenState();
}

class _PozingCameraScreenState extends State<PozingCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  _CameraStatus _status = _CameraStatus.initializing;
  String _errorMessage = '';
  Timer? _autoStopTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _releaseCameraForBackground();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller == null && _status != _CameraStatus.uploading) {
        _initializeCamera();
      }
    }
  }

  Future<void> _releaseCameraForBackground() async {
    final controller = _controller;
    if (controller == null) return;

    _autoStopTimer?.cancel();
    _autoStopTimer = null;

    if (_status == _CameraStatus.recording) {
      try {
        final file = await controller.stopVideoRecording();
        await File(file.path).delete();
      } catch (_) {}
    }

    _controller = null;
    if (mounted && _status != _CameraStatus.uploading) {
      setState(() => _status = _CameraStatus.initializing);
    }
    await controller.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('noCamera', '사용 가능한 카메라가 없습니다.');
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: true,
      );
      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _status = _CameraStatus.ready;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '카메라를 사용할 수 없어요. 카메라 권한을 확인해 주세요.';
        _status = _CameraStatus.error;
      });
    }
  }

  Future<void> _startRecording() async {
    final controller = _controller;
    if (controller == null || _status != _CameraStatus.ready) return;

    try {
      await controller.startVideoRecording();
      if (!mounted) return;
      setState(() => _status = _CameraStatus.recording);
      _autoStopTimer = Timer(_kMaxRecordingDuration, _stopRecordingAndUpload);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('촬영을 시작하지 못했어요.');
    }
  }

  Future<void> _stopRecordingAndUpload() async {
    _autoStopTimer?.cancel();
    final controller = _controller;
    if (controller == null || _status != _CameraStatus.recording) return;

    try {
      final file = await controller.stopVideoRecording();
      if (!mounted) return;
      setState(() => _status = _CameraStatus.uploading);

      final result = await widget.repository.uploadPozingVideo(
        courseSpotId: widget.courseSpotId,
        videoFile: File(file.path),
      );

      if (!mounted) return;
      Navigator.of(context).pop(result);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _status = _CameraStatus.ready);
      _showSnackBar(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = _CameraStatus.ready);
      _showSnackBar('포징 영상을 업로드하지 못했어요.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoStopTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _status == _CameraStatus.initializing
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              )
            : _status == _CameraStatus.error
            ? _buildError()
            : _controller == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              )
            : _buildPreview(),
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
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text(
                '닫기',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final controller = _controller!;
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller),
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            onPressed: _status == _CameraStatus.recording
                ? null
                : () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close, color: AppColors.white),
          ),
        ),
        if (_status == _CameraStatus.uploading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.white),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 32,
          child: Center(
            child: _RecordButton(
              isRecording: _status == _CameraStatus.recording,
              onTap: _status == _CameraStatus.recording
                  ? _stopRecordingAndUpload
                  : _status == _CameraStatus.ready
                  ? _startRecording
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({required this.isRecording, this.onTap});

  final bool isRecording;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 4),
        ),
        padding: const EdgeInsets.all(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(isRecording ? 6 : 30),
          ),
        ),
      ),
    );
  }
}
