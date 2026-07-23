import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'onboarding_flow_screen.dart';

@Preview(group: 'hycho', name: 'Onboarding Flow', size: Size(393, 852))
Widget onboardingFlowPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(393, 852),
        padding: EdgeInsets.only(top: 59, bottom: 34),
      ),
      child: OnboardingFlowScreen(),
    ),
  );
}
