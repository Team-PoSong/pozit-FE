import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_icons.dart';

class AppSendButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;

  const AppSendButton({super.key, this.isEnabled = false, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        width: 40.0,
        height: 40.0,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.primary : AppColors.purple1,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          AppIcons.send,
          width: isEnabled ? 19.501 : 24.0,
          height: isEnabled ? 19.501 : 24.0,
          colorFilter: ColorFilter.mode(
            isEnabled ? AppColors.purple1 : AppColors.purple2,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'AppSendButton - 비활성')
Widget appSendButtonDisabledPreview() => const AppSendButton();

@Preview(group: 'haerim', name: 'AppSendButton - 활성')
Widget appSendButtonEnabledPreview() => const AppSendButton(isEnabled: true);
