import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'nickname_screen.dart';
import 'terms_agreement_screen.dart';

class _OnboardingFlowPreview extends StatefulWidget {
  const _OnboardingFlowPreview();

  @override
  State<_OnboardingFlowPreview> createState() => _OnboardingFlowPreviewState();
}

class _OnboardingFlowPreviewState extends State<_OnboardingFlowPreview> {
  bool _isTermsStep = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: _isTermsStep
          ? const TermsAgreementScreen(
              key: ValueKey('terms-step'),
              assetPackage: 'pozit',
            )
          : NicknameScreen(
              key: const ValueKey('nickname-step'),
              validationDelay: Duration.zero,
              onNext: (_) => setState(() => _isTermsStep = true),
            ),
    );
  }
}

@Preview(group: 'hycho', name: 'Onboarding Flow', size: Size(393, 852))
Widget onboardingFlowPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(393, 852),
        padding: EdgeInsets.only(top: 59, bottom: 34),
      ),
      child: _OnboardingFlowPreview(),
    ),
  );
}
