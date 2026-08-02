import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';
import '../app_icons.dart';
import '../app_text_styles.dart';

class AppDeletePopover extends StatelessWidget {
  const AppDeletePopover({super.key, required this.onTap, this.assetPackage});

  final VoidCallback onTap;
  final String? assetPackage;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '삭제하기',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            shadows: const [
              BoxShadow(
                color: AppColors.popoverShadow,
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppIcons.trashBlack,
                package: assetPackage,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '삭제하기',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.text,
                  package: assetPackage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showAppDeletePopover(
  BuildContext context, {
  required LayerLink anchorLink,
  required VoidCallback onDelete,
  String? assetPackage,
}) {
  final overlay = Overlay.of(context);
  final completer = Completer<void>();
  late final OverlayEntry entry;

  void close() {
    entry.remove();
    completer.complete();
  }

  entry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: close),
        ),
        CompositedTransformFollower(
          link: anchorLink,

          targetAnchor: Alignment.centerLeft,
          followerAnchor: Alignment.centerRight,
          offset: const Offset(-8, 0),

          child: Material(
            type: MaterialType.transparency,
            child: AppDeletePopover(
              assetPackage: assetPackage,
              onTap: () {
                close();
                onDelete();
              },
            ),
          ),
        ),
      ],
    ),
  );

  overlay.insert(entry);
  return completer.future;
}
