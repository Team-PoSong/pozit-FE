import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../data/repositories/user/user_repository.dart';
import '../auth/auth_gate.dart';
import 'nickname_screen.dart';
import 'terms_agreement_screen.dart';

enum _OnboardingStep { nickname, terms }

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key, UserRepository? userRepository})
    : userRepository = userRepository ?? const UserRepository();

  final UserRepository userRepository;

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  _OnboardingStep _step = _OnboardingStep.nickname;

  Future<void> _showTermsAgreement(String nickname) async {
    await widget.userRepository.setInitialNickname(nickname);
    if (!mounted) return;
    setState(() => _step = _OnboardingStep.terms);
  }

  void _completeOnboarding() {
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
