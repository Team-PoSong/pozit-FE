import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';

class AppBottomGradient extends StatelessWidget {
  const AppBottomGradient({super.key});

  static const double height = 106;

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bottomGradientStart,
              AppColors.bottomGradientEnd,
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'App Bottom Gradient', size: Size(393, 106))
Widget appBottomGradientPreview() {
  return const AppBottomGradient();
}
