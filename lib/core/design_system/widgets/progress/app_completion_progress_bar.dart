import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../app_colors.dart';

class AppCompletionProgressBar extends StatelessWidget {
  final double progress;
  final double width;
  final double height;

  const AppCompletionProgressBar({
    super.key,
    required this.progress,
    this.width = 242.0,
    this.height = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: AppColors.purple1,
        shape: StadiumBorder(
          side: const BorderSide(color: AppColors.primary, width: 0.5),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0).toDouble(),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(200.0),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.purple2, AppColors.purple3],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'AppCompletionProgressBar')
Widget appCompletionProgressBarPreview() =>
    const AppCompletionProgressBar(progress: 156 / 242);