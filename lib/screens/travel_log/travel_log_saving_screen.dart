import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';

const double _kTopToTapeGap = 260.0;
const double _kTapeWidth = 155.0;
const double _kTapeHeight = 117.0;
const double _kTapeToTextGap = 62.0;

class TravelLogSavingScreen extends StatelessWidget {
  const TravelLogSavingScreen({super.key, required this.travelName});

  final String travelName;

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
            child: Column(
              children: [
                const SizedBox(height: _kTopToTapeGap),
                Image.asset(
                  AppImages.tape,
                  width: _kTapeWidth,
                  height: _kTapeHeight,
                ),
                const SizedBox(height: _kTapeToTextGap),
                Text(
                  '$travelName의 추억이 담긴\n여행 로그를 저장중이에요..',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subTitle.copyWith(
                    color: AppColors.text,
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

@Preview(
  group: 'travel_log',
  name: 'TravelLogSavingScreen',
  size: Size(390, 844),
)
Widget travelLogSavingScreenPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelLogSavingScreen(travelName: '경주여행'),
  );
}
