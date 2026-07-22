import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_images.dart';
import '../app_text_styles.dart';

enum AppNavigationTab { travel, explore }

class AppNavigationBar extends StatefulWidget {
  const AppNavigationBar({
    super.key,
    this.selectedTab,
    this.initialTab = AppNavigationTab.travel,
    this.onChanged,
    this.onPosongTap,
    this.assetPackage,
  });

  final AppNavigationTab? selectedTab;
  final AppNavigationTab initialTab;
  final ValueChanged<AppNavigationTab>? onChanged;
  final VoidCallback? onPosongTap;
  final String? assetPackage;

  @override
  State<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends State<AppNavigationBar> {
  static const double _navigationWidth = 283;
  static const double _navigationHeight = 63;

  late AppNavigationTab _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.selectedTab ?? widget.initialTab;
  }

  @override
  void didUpdateWidget(AppNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTab != null &&
        widget.selectedTab != oldWidget.selectedTab) {
      _selectedTab = widget.selectedTab!;
    }
  }

  void _handleTabTap(AppNavigationTab tab) {
    if (_selectedTab == tab) return;
    if (widget.selectedTab == null) {
      setState(() => _selectedTab = tab);
    }
    widget.onChanged?.call(tab);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 12),
      child: Align(
        widthFactor: 1,
        heightFactor: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = math.min(_navigationWidth, constraints.maxWidth);

            return SizedBox(
              width: width,
              height: _navigationHeight,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: const _BottomNavigationShadowPainter(),
                      child: ClipPath(
                        clipper: const _BottomNavigationClipper(),
                        child: ColoredBox(
                          color: AppColors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 35),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 30,
                                  child: _NavigationItem(
                                    label: '여행',
                                    iconAsset:
                                        _selectedTab == AppNavigationTab.travel
                                        ? AppImages.bottomNavTravelOn
                                        : AppImages.bottomNavTravelOff,
                                    isSelected:
                                        _selectedTab == AppNavigationTab.travel,
                                    assetPackage: widget.assetPackage,
                                    onTap: () =>
                                        _handleTabTap(AppNavigationTab.travel),
                                  ),
                                ),
                                const Spacer(),
                                const SizedBox(width: 94),
                                const Spacer(),
                                SizedBox(
                                  width: 30,
                                  child: _NavigationItem(
                                    label: '탐색',
                                    iconAsset:
                                        _selectedTab == AppNavigationTab.explore
                                        ? AppImages.bottomNavSearchOn
                                        : AppImages.bottomNavSearchOff,
                                    isSelected:
                                        _selectedTab ==
                                        AppNavigationTab.explore,
                                    assetPackage: widget.assetPackage,
                                    onTap: () =>
                                        _handleTabTap(AppNavigationTab.explore),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -28,
                    child: _CenterButton(
                      assetPackage: widget.assetPackage,
                      onTap: widget.onPosongTap,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.iconAsset,
    required this.isSelected,
    required this.assetPackage,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final bool isSelected;
  final String? assetPackage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.purple3 : AppColors.gray5;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          child: Padding(
            padding: const EdgeInsets.only(top: 7, bottom: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  iconAsset,
                  package: assetPackage,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  const _CenterButton({required this.assetPackage, required this.onTap});

  final String? assetPackage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '포짓',
      child: SizedBox.square(
        dimension: 75,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppColors.navigationBorderStart, blurRadius: 12),
            ],
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.navigationBorderStart,
                  AppColors.navigationBorderEnd,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Material(
                color: AppColors.white,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(9),
                    child: Image.asset(
                      AppImages.appLogo,
                      package: assetPackage,
                      width: 52,
                      height: 52,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationClipper extends CustomClipper<Path> {
  const _BottomNavigationClipper();

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    const designOuterRadius = 56.0;
    final outerRadius = math.min(designOuterRadius, height / 2);
    final notchHalfWidth = width * (52 / 283);
    final notchDepth = 52.0.clamp(0.0, height);
    final notchStart = centerX - notchHalfWidth;
    final notchEnd = centerX + notchHalfWidth;

    return Path()
      ..moveTo(outerRadius, 0)
      ..lineTo(notchStart, 0)
      ..cubicTo(
        notchStart + 10,
        0,
        centerX - 44,
        notchDepth * 0.48,
        centerX - 30,
        notchDepth * 0.72,
      )
      ..cubicTo(
        centerX - 20,
        notchDepth * 0.91,
        centerX - 10,
        notchDepth,
        centerX,
        notchDepth,
      )
      ..cubicTo(
        centerX + 10,
        notchDepth,
        centerX + 20,
        notchDepth * 0.91,
        centerX + 30,
        notchDepth * 0.72,
      )
      ..cubicTo(centerX + 44, notchDepth * 0.48, notchEnd - 10, 0, notchEnd, 0)
      ..lineTo(width - outerRadius, 0)
      ..arcToPoint(
        Offset(width, outerRadius),
        radius: Radius.circular(outerRadius),
      )
      ..arcToPoint(
        Offset(width - outerRadius, height),
        radius: Radius.circular(outerRadius),
      )
      ..lineTo(outerRadius, height)
      ..arcToPoint(Offset(0, outerRadius), radius: Radius.circular(outerRadius))
      ..arcToPoint(Offset(outerRadius, 0), radius: Radius.circular(outerRadius))
      ..close();
  }

  @override
  bool shouldReclip(covariant _BottomNavigationClipper oldClipper) => false;
}

class _BottomNavigationShadowPainter extends CustomPainter {
  const _BottomNavigationShadowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = const _BottomNavigationClipper().getClip(size);
    final paint = Paint()
      ..color = AppColors.purple1
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BottomNavigationShadowPainter oldDelegate) =>
      false;
}

@Preview(group: 'hycho', name: 'App Navigation Bar', size: Size(393, 140))
Widget appNavigationBarPreview() {
  return const MediaQuery(
    data: MediaQueryData(
      size: Size(393, 140),
      padding: EdgeInsets.only(bottom: 34),
    ),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.gray1,
        body: Align(
          alignment: Alignment.bottomCenter,
          child: AppNavigationBar(assetPackage: 'pozit'),
        ),
      ),
    ),
  );
}
