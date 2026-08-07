import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../core/design_system/widgets/app_input_field.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/utils/nickname_validation.dart';

class NicknameEditScreen extends StatefulWidget {
  const NicknameEditScreen({
    super.key,
    required this.initialNickname,
    this.initialErrorMessage,
    this.validateNickname,
    this.validationDelay = const Duration(milliseconds: 400),
  });

  final String initialNickname;
  final String? initialErrorMessage;
  final NicknameAvailabilityValidator? validateNickname;
  final Duration validationDelay;

  @override
  State<NicknameEditScreen> createState() => _NicknameEditScreenState();
}

class _NicknameEditScreenState extends State<NicknameEditScreen> {
  static const int _maxLength = 5;

  late final TextEditingController _controller;
  late String? _errorMessage = widget.initialErrorMessage;
  Timer? _validationTimer;
  int _validationGeneration = 0;
  NicknameValidationState _validationState = NicknameValidationState.idle;

  bool get _canSubmit {
    final nickname = _controller.text.trim();
    return nickname != widget.initialNickname &&
        _validationState == NicknameValidationState.available;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNickname);
  }

  @override
  void dispose() {
    _validationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    _validationTimer?.cancel();
    final generation = ++_validationGeneration;
    final nickname = value.trim();
    final isValidLength =
        nickname.isNotEmpty && nickname.characters.length <= _maxLength;
    final shouldValidate = isValidLength && nickname != widget.initialNickname;

    setState(() {
      _errorMessage = null;
      _validationState = shouldValidate
          ? NicknameValidationState.checking
          : NicknameValidationState.idle;
    });

    if (!shouldValidate) return;
    _validationTimer = Timer(
      widget.validationDelay,
      () => _validateNickname(nickname, generation),
    );
  }

  Future<void> _validateNickname(String nickname, int generation) async {
    try {
      final isAvailable = await widget.validateNickname?.call(nickname) ?? true;
      if (!mounted || generation != _validationGeneration) return;
      setState(() {
        _validationState = isAvailable
            ? NicknameValidationState.available
            : NicknameValidationState.duplicate;
      });
    } catch (_) {
      if (!mounted || generation != _validationGeneration) return;
      setState(() => _validationState = NicknameValidationState.error);
    }
  }

  void _submit() {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();
    final nickname = _controller.text.trim();
    Navigator.pop(context, nickname);
  }

  @override
  Widget build(BuildContext context) {
    final currentLength = _controller.text.characters.length;
    final validationMessage = switch (_validationState) {
      NicknameValidationState.available => '사용 가능한 닉네임입니다.',
      NicknameValidationState.duplicate => '이미 사용중인 닉네임입니다.',
      NicknameValidationState.error => '닉네임을 확인하지 못했습니다.',
      _ => null,
    };
    final statusMessage = _errorMessage ?? validationMessage;
    final isError =
        _errorMessage != null ||
        _validationState == NicknameValidationState.duplicate ||
        _validationState == NicknameValidationState.error;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            children: [
              const AppDetailHeader(title: '닉네임 수정'),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    27,
                    24,
                    MediaQuery.viewPaddingOf(context).bottom +
                        AppDimensions.bottomNavigationSpacing,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '닉네임',
                        style: AppTextStyles.subTitle.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AppInputField(
                        controller: _controller,
                        autofocus: true,
                        maxLength: _maxLength,
                        isError: isError,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(_maxLength),
                        ],
                        onChanged: _handleChanged,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              statusMessage ?? '',
                              style: AppTextStyles.caption.copyWith(
                                color: isError
                                    ? AppColors.error
                                    : AppColors.text,
                                height: 20 / 12,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Text(
                            '$currentLength/$_maxLength',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSub,
                              height: 20 / 12,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      AppButton(
                        text: '완료',
                        isEnabled: _canSubmit,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: '닉네임 수정', size: Size(393, 852))
Widget nicknameEditScreenPreview() =>
    const MaterialApp(home: NicknameEditScreen(initialNickname: '조현영'));

@Preview(group: 'haerim', name: '닉네임 수정 - 중복', size: Size(393, 852))
Widget nicknameEditErrorScreenPreview() => const MaterialApp(
  home: NicknameEditScreen(
    initialNickname: '조현영',
    initialErrorMessage: '이미 사용중인 닉네임입니다.',
  ),
);
