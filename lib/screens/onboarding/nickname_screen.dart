import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_input_field.dart';
import '../../core/design_system/widgets/app_toast.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/user/nickname_validation_model.dart';

class NicknameScreen extends StatefulWidget {
  const NicknameScreen({super.key, this.onNext});

  final FutureOr<void> Function(String nickname)? onNext;

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  static const int _nicknameMaxLength = 5;

  final _nicknameController = TextEditingController();
  NicknameValidationState _validationState = NicknameValidationState.idle;

  bool get _isAvailable =>
      _validationState == NicknameValidationState.available;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _handleNicknameChanged(String value) {
    setState(() {
      _validationState = value.trim().isEmpty
          ? NicknameValidationState.idle
          : NicknameValidationState.available;
    });
  }

  Future<void> _submit() async {
    if (!_isAvailable || _isSubmitting) return;
    final submittedNickname = _nicknameController.text.trim();
    setState(() => _isSubmitting = true);
    try {
      await widget.onNext?.call(submittedNickname);
    } catch (error) {
      if (!mounted) return;
      if (error is ApiException && error.code == 'USER400_1') {
        if (_nicknameController.text.trim() == submittedNickname) {
          setState(() => _validationState = NicknameValidationState.duplicate);
        }
      } else {
        final message = error is ApiException
            ? error.message
            : '닉네임을 설정하지 못했습니다.';
        showAppToast(context, message);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isError =
        _validationState == NicknameValidationState.duplicate ||
        _validationState == NicknameValidationState.error;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            0,
            24,
            AppDimensions.screenBottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 34),
              Text(
                '사용하실 닉네임을 입력해주세요.',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.text,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 34),
              Text(
                '닉네임',
                style: AppTextStyles.subTitle.copyWith(color: AppColors.text),
              ),
              const SizedBox(height: 10),
              AppInputField(
                controller: _nicknameController,
                maxLength: _nicknameMaxLength,
                isError: isError,
                onChanged: _handleNicknameChanged,
              ),
              const SizedBox(height: 4),
              _NicknameStatus(
                state: _validationState,
                currentLength: _nicknameController.text.trim().length,
              ),
              const Spacer(),
              AppButton(
                text: '다음',
                isEnabled: _isAvailable && !_isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NicknameStatus extends StatelessWidget {
  const _NicknameStatus({required this.state, required this.currentLength});

  final NicknameValidationState state;
  final int currentLength;

  @override
  Widget build(BuildContext context) {
    final message = switch (state) {
      NicknameValidationState.available => null,
      NicknameValidationState.duplicate => '이미 사용중인 아이디입니다.',
      NicknameValidationState.error => '닉네임을 확인하지 못했습니다.',
      _ => null,
    };
    final messageColor =
        state == NicknameValidationState.duplicate ||
            state == NicknameValidationState.error
        ? AppColors.error
        : AppColors.text;

    return SizedBox(
      height: 20,
      child: Row(
        children: [
          if (message != null)
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.caption.copyWith(color: messageColor),
              ),
            )
          else
            const Spacer(),
          if (currentLength > 0)
            Text(
              '$currentLength/5',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSub,
                height: 20 / 12,
                letterSpacing: -0.5,
              ),
            ),
        ],
      ),
    );
  }
}
