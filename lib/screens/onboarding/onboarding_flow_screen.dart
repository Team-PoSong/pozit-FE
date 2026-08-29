import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/widgets/app_toast.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/support/support_info_model.dart';
import '../../data/repositories/support/support_repository.dart';
import '../../data/repositories/user/onboarding_repository.dart';
import '../auth/auth_gate.dart';
import '../terms/term_detail_screen.dart';
import 'nickname_screen.dart';
import 'terms_agreement_screen.dart';

enum _OnboardingStep { nickname, terms }

enum _OnboardingTerm { service, privacy, location }

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  _OnboardingStep _step = _OnboardingStep.nickname;
  final OnboardingRepository _repository = const OnboardingRepository();
  final SupportRepository _supportRepository = const SupportRepository();

  SupportInfoModel? _supportInfo;
  bool _isOpeningTerm = false;

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

  Future<void> _openTerm(_OnboardingTerm type) async {
    if (_isOpeningTerm) return;
    setState(() => _isOpeningTerm = true);

    try {
      final info = _supportInfo ?? await _supportRepository.getInfo();
      _supportInfo = info;
      if (!mounted) return;

      final term = switch (type) {
        _OnboardingTerm.service => info.serviceTerm,
        _OnboardingTerm.privacy => info.privacyPolicy,
        _OnboardingTerm.location => info.locationTerm,
      };
      if (term == null) {
        throw const ApiException('위치기반서비스 이용약관을 찾을 수 없습니다.');
      }
      await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => TermDetailScreen(term: term)),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException
          ? error.message
          : '약관 정보를 불러오지 못했습니다.';
      showAppToast(context, message);
    } finally {
      if (mounted) setState(() => _isOpeningTerm = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: switch (_step) {
            _OnboardingStep.nickname => NicknameScreen(
              key: const ValueKey('nickname-step'),
              onNext: _showTermsAgreement,
            ),
            _OnboardingStep.terms => TermsAgreementScreen(
              key: const ValueKey('terms-step'),
              onNext: _completeOnboarding,
              onServiceTermsTap: () => _openTerm(_OnboardingTerm.service),
              onPrivacyTermsTap: () => _openTerm(_OnboardingTerm.privacy),
              onLocationTermsTap: () => _openTerm(_OnboardingTerm.location),
            ),
          },
        ),
        if (_isOpeningTerm) ...[
          const ModalBarrier(
            dismissible: false,
            color: Colors.transparent,
            semanticsLabel: '약관 불러오는 중',
          ),
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ],
      ],
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
