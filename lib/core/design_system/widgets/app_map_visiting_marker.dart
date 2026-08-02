import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../app_colors.dart';
import '../app_images.dart';

class MapVisitingMarker extends StatelessWidget {
  const MapVisitingMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.0,
      height: 30.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        boxShadow: const [
          BoxShadow(color: AppColors.purple2, blurRadius: 12.0),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4.082, 5.0, 3.582, 4.375),
        child: Image.asset(
          AppImages.posongVisiting,
          semanticLabel: '방문 중',
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'MapVisitingMarker')
Widget mapVisitingMarkerPreview() => const MapVisitingMarker();
