import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';
import '../app_icons.dart';
import '../app_text_styles.dart';

class AppPosing extends StatelessWidget {
  const AppPosing({super.key, required String name, required bool isCameraOn})
    : _name = name,
      _isCameraOn = isCameraOn,
      _isTravelPhoto = false;

  const AppPosing.travelPhoto({super.key})
    : _name = null,
      _isCameraOn = false,
      _isTravelPhoto = true;

  final String? _name;
  final bool _isCameraOn;
  final bool _isTravelPhoto;

  @override
  Widget build(BuildContext context) {
    final cameraIcon = _isCameraOn ? AppIcons.cameraOn : AppIcons.cameraOff;

    return Container(
      width: double.infinity,
      height: _isTravelPhoto ? 183 : 194,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _isTravelPhoto ? AppColors.gray3 : AppColors.text,
        borderRadius: BorderRadius.circular(_isTravelPhoto ? 8 : 12),
      ),
      child: Stack(
        children: [
          Center(
            child: Semantics(
              label: _isTravelPhoto
                  ? '여행 사진 추가'
                  : _isCameraOn
                  ? '카메라 켜짐'
                  : '카메라 꺼짐',
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: SvgPicture.asset(
                  cameraIcon,
                  key: ValueKey(cameraIcon),
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
          if (_name != null)
            Positioned(
              left: 23,
              right: 23,
              bottom: 26,
              child: Text(
                _name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.subTitle.copyWith(color: AppColors.gray1),
              ),
            ),
        ],
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Posing - 카메라 켜짐')
Widget appPosingCameraOnPreview() {
  return const MaterialApp(
    home: Scaffold(body: AppPosing(name: '현영', isCameraOn: true)),
  );
}

@Preview(group: 'hycho', name: 'Posing - 카메라 꺼짐')
Widget appPosingCameraOffPreview() {
  return const MaterialApp(
    home: Scaffold(body: AppPosing(name: '윤지', isCameraOn: false)),
  );
}

@Preview(group: 'hycho', name: 'Posing - 여행 사진 추가')
Widget appPosingTravelPhotoPreview() {
  return const MaterialApp(home: Scaffold(body: AppPosing.travelPhoto()));
}
