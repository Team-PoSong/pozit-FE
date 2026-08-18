import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/app_colors.dart';
import 'package:pozit/core/design_system/widgets/app_switch.dart';

void main() {
  testWidgets('비활성화되어도 현재 설정값은 켜진 상태로 표시한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppSwitch(value: true, isEnabled: false)),
      ),
    );

    final track = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final decoration = track.decoration! as BoxDecoration;

    expect(decoration.color, AppColors.primary);
  });
}
