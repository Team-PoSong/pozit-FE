import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../data/repositories/user/onboarding_repository.dart';
import '../auth/auth_gate.dart';
import 'nickname_screen.dart';
import 'terms_agreement_screen.dart';

enum _OnboardingStep { nickname, terms }

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  _OnboardingStep _step = _OnboardingStep.nickname;
  final OnboardingRepository _repository = const OnboardingRepository();

  Future<void> _showTermsAgreement(String nickname) async {
    await _repository.updateNickname(nickname);
    if (!mounted) return;
    setState(() => _step = _OnboardingStep.terms);
  }

  Future<void> _completeOnboarding() async {
    await _repository.saveRequiredTermAgreements();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: switch (_step) {
        _OnboardingStep.nickname => NicknameScreen(
          key: const ValueKey('nickname-step'),
          onNext: _showTermsAgreement,
        ),
        _OnboardingStep.terms => TermsAgreementScreen(
          key: const ValueKey('terms-step'),
          onNext: _completeOnboarding,
        ),
      },
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
      child: OnboardingFlowScreen(),
    ),
  );
}
