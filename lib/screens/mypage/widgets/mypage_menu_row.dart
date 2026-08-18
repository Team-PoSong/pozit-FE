import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_dimensions.dart';
import '../../../core/design_system/app_icons.dart';
import '../../../core/design_system/app_text_styles.dart';

class MyPageMenuRow extends StatelessWidget {
  const MyPageMenuRow({
    super.key,
    required this.label,
    required this.onTap,
    this.assetPackage,
  });

  final String label;
  final VoidCallback onTap;
  final String? assetPackage;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: AppDimensions.minimumTapTargetSize,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(color: AppColors.text),
                ),
              ),
              SizedBox.square(
                dimension: AppDimensions.minimumTapTargetSize,
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.arrowRightSmall,
                    package: assetPackage,
                    width: 20,
                    height: 20,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: '마이페이지 메뉴 행')
Widget myPageMenuRowPreview() => MaterialApp(
  home: Scaffold(
    body: MyPageMenuRow(label: '앱 버전 정보', onTap: () {}),
  ),
);
