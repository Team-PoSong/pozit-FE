import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

/// 화면 하단에 잠시 떠 있다 사라지는 커스텀 토스트 메시지.
class AppToast extends StatelessWidget {
  const AppToast({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: ShapeDecoration(
            color: AppColors.gray1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: const [
              BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.text),
          ),
        ),
      ),
    );
  }
}

OverlayEntry? _currentToastEntry;

/// 현재 화면 위에 [message]를 담은 [AppToast]를 잠깐 띄운다.
///
/// 이미 떠 있는 토스트가 있다면 즉시 교체한다.
void showAppToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  _currentToastEntry?.remove();
  _currentToastEntry = null;

  final overlay = Overlay.of(context);
  late final OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => _AppToastOverlay(
      message: message,
      duration: duration,
      onDismissed: () {
        if (identical(_currentToastEntry, entry)) {
          _currentToastEntry = null;
        }
        entry.remove();
      },
    ),
  );

  _currentToastEntry = entry;
  overlay.insert(entry);
}

class _AppToastOverlay extends StatefulWidget {
  const _AppToastOverlay({
    required this.message,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _play();
  }

  Future<void> _play() async {
    await _controller.forward();
    if (!mounted) return;
    await Future.delayed(widget.duration);
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = math.max(
      mediaQuery.padding.bottom,
      mediaQuery.viewInsets.bottom,
    );
    return Positioned(
      left: 20,
      right: 20,
      bottom: 32 + bottomInset,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: AppToast(message: widget.message),
          ),
        ),
      ),
    );
  }
}

class _AppToastDemo extends StatelessWidget {
  const _AppToastDemo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showAppToast(context, '토스트 메시지 예시입니다.'),
          child: const Text('토스트 띄우기'),
        ),
      ),
    );
  }
}

@Preview(group: 'seohyun', name: 'AppToast')
Widget appToastPreview() => const _AppToastDemo();
