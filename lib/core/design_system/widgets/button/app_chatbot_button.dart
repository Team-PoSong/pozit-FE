import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app_colors.dart';
import '../../app_icons.dart';

class AppChatbotButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double width;
  final double height;

  const AppChatbotButton({
    super.key,
    this.onPressed,
    this.width = 38.0,
    this.height = 31.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            SvgPicture.asset(
              AppIcons.chatBubble,
              width: width,
              height: height,
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13.0, 5.0, 13.0, 12.0),
                child: Center(
                  child: Text(
                    'AI',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      height: 14 / 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: 'AppChatbotButton')
Widget appChatbotButtonPreview() => const AppChatbotButton();