import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_input_field.dart';
import '../../core/design_system/widgets/button/app_button.dart';

enum NicknameValidationState { idle, checking, available, duplicate, error }

class NicknameScreen extends StatefulWidget {
  const NicknameScreen({
    super.key,
    this.validateNickname,
    this.onNext,
    this.validationDelay = const Duration(milliseconds: 400),
  });

  final Future<bool> Function(String nickname)? validateNickname;
  final ValueChanged<String>? onNext;
  final Duration validationDelay;

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  static const int _nicknameMaxLength = 5;

  final _nicknameController = TextEditingController();
  Timer? _validationTimer;
  NicknameValidationState _validationState = NicknameValidationState.idle;

  bool get _isAvailable =>
      _validationState == NicknameValidationState.available;

  @override
  void dispose() {
    _validationTimer?.cancel();
    _nicknameController.dispose();
    super.dispose();
  }

  void _handleNicknameChanged(String value) {
    _validationTimer?.cancel();
    setState(() {
      _validationState = value.isEmpty
          ? NicknameValidationState.idle
          : NicknameValidationState.checking;
    });

    if (value.isEmpty) return;
    _validationTimer = Timer(widget.validationDelay, () {
      _validateNickname(value);
    });
  }

  Future<void> _validateNickname(String nickname) async {
    try {
      final isAvailable = await widget.validateNickname?.call(nickname) ?? true;
      if (!mounted || _nicknameController.text != nickname) return;
      setState(() {
        _validationState = isAvailable
            ? NicknameValidationState.available
            : NicknameValidationState.duplicate;
      });
    } catch (_) {
      if (!mounted || _nicknameController.text != nickname) return;
      setState(() => _validationState = NicknameValidationState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isError =
        _validationState == NicknameValidationState.duplicate ||
        _validationState == NicknameValidationState.error;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
              const SizedBox(height: 46),
              Text(
                '닉네임',
                style: AppTextStyles.subTitle.copyWith(color: AppColors.text),
              ),
              const SizedBox(height: 10),
              AppInputField(
                controller: _nicknameController,
                maxLength: _nicknameMaxLength,
                inputFormatters: [LengthLimitingTextInputFormatter(5)],
                isError: isError,
                onChanged: _handleNicknameChanged,
              ),
              const SizedBox(height: 4),
              _NicknameStatus(
                state: _validationState,
                currentLength: _nicknameController.text.length,
              ),
              const Spacer(),
              AppButton(
                text: '다음',
                isEnabled: _isAvailable,
                onPressed: () => widget.onNext?.call(_nicknameController.text),
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
      NicknameValidationState.available => '사용 가능한 닉네임입니다.',
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
