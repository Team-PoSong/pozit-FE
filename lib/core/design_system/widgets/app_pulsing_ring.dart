import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 회전하는 그라데이션 테두리와 은은하게 맥동하는 글로우를 [child] 뒤에 그린다.
///
/// 바텀 네비게이션 바의 카메라 버튼이 촬영 가능 상태일 때 뜨는 애니메이션과
/// 동일한 효과이며, [active]가 true인 동안에만 회전/맥동한다.
///
/// [strokeWidth]가 테두리 두께다. `size / 2`를 주면 안쪽까지 꽉 채운 원이 된다.
class AppPulsingRing extends StatefulWidget {
  const AppPulsingRing({
    super.key,
    required this.size,
    required this.strokeWidth,
    required this.active,
    required this.child,
    this.glow = true,
  });

  final double size;
  final double strokeWidth;
  final bool active;
  final Widget child;
  final bool glow;

  @override
  State<AppPulsingRing> createState() => _AppPulsingRingState();
}

class _AppPulsingRingState extends State<AppPulsingRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  bool _disableAnimations = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _syncAnimation();
  }

  @override
  void didUpdateWidget(AppPulsingRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.active && !_disableAnimations) {
      if (!_controller.isAnimating) _controller.repeat();
      return;
    }

    _controller.stop();
    _controller.value = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final pulse = (math.sin(_controller.value * math.pi * 2) + 1) / 2;
          final glowBlur = widget.active ? 12 + (pulse * 6) : 12.0;

          return DecoratedBox(
            decoration: widget.glow
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.active
                            ? const Color(0xFFC7C8FF).withValues(alpha: 0.72)
                            : const Color(0xFFECEBFF),
                        blurRadius: glowBlur,
                      ),
                    ],
                  )
                : const BoxDecoration(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RingPainter(
                      strokeWidth: widget.strokeWidth,
                      active: widget.active,
                      rotation: _controller.value,
                    ),
                  ),
                ),
                widget.child,
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.strokeWidth,
    required this.active,
    required this.rotation,
  });

  final double strokeWidth;
  final bool active;
  final double rotation;

  static const _activeColors = [
    Color(0xFFC7C8FF),
    Color(0xFFF2F0FF),
    Color(0xFFF6DDFB),
    Color(0xFFF6DDFB),
    Color(0xFFC7C8FF),
    Color(0xFFF2F0FF),
    Color(0xFFF6DDFB),
    Color(0xFFF6DDFB),
    Color(0xFFC7C8FF),
  ];
  static const _activeStops = [0.0, 0.12, 0.22, 0.3, 0.5, 0.62, 0.72, 0.8, 1.0];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - strokeWidth) / 2;

    final gradient = active
        ? SweepGradient(
            colors: _activeColors,
            stops: _activeStops,
            transform: GradientRotation(rotation * math.pi * 2),
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFECEBFF), Color(0xFFC7C8FF)],
          );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.rotation != rotation ||
      oldDelegate.active != active ||
      oldDelegate.strokeWidth != strokeWidth;
}
