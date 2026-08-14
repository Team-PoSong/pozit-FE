import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../core/design_system/widgets/app_input_field.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/user/nickname_validation_model.dart';

const double _kHorizontalPadding = 24.0;
const double _kContentTopPadding = 27.0;

class NicknameEditScreen extends StatefulWidget {
  const NicknameEditScreen({
    super.key,
    required this.initialNickname,
    required this.onSubmit,
    this.initialErrorMessage,
  });

  final String initialNickname;
  final String? initialErrorMessage;
  final Future<void> Function(String nickname) onSubmit;

  @override
  State<NicknameEditScreen> createState() => _NicknameEditScreenState();
}

class _NicknameEditScreenState extends State<NicknameEditScreen> {
  static const int _maxLength = 5;

  late final TextEditingController _controller;
  late String? _errorMessage = widget.initialErrorMessage;
  NicknameValidationState _validationState = NicknameValidationState.idle;
  bool _isSubmitting = false;

  bool get _hasValidInput {
    final nickname = _controller.text.trim();
    return nickname.isNotEmpty &&
        nickname.characters.length <= _maxLength &&
        nickname != widget.initialNickname;
  }

  bool get _canSubmit {
    return !_isSubmitting && _hasValidInput;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    setState(() {
      _errorMessage = null;
      _validationState = NicknameValidationState.idle;
    });
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();
    final nickname = _controller.text.trim();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await widget.onSubmit(nickname);
      if (!mounted) return;
      Navigator.pop(context, nickname);
    } on ApiException catch (error) {
      if (!mounted) return;
      final isDuplicate = error.code == nicknameDuplicateErrorCode;
      setState(() {
        _isSubmitting = false;
        _validationState = isDuplicate
            ? NicknameValidationState.duplicate
            : NicknameValidationState.error;
        _errorMessage = isDuplicate ? null : error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _validationState = NicknameValidationState.error;
        _errorMessage = '닉네임을 변경하지 못했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLength = _controller.text.characters.length;
    final validationMessage = switch (_validationState) {
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
                    _kHorizontalPadding,
                    _kContentTopPadding,
                    _kHorizontalPadding,
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
                        readOnly: _isSubmitting,
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
Widget nicknameEditScreenPreview() => MaterialApp(
  home: NicknameEditScreen(initialNickname: '조현영', onSubmit: (_) async {}),
);

@Preview(group: 'haerim', name: '닉네임 수정 - 중복', size: Size(393, 852))
Widget nicknameEditErrorScreenPreview() => MaterialApp(
  home: NicknameEditScreen(
    initialNickname: '조현영',
    initialErrorMessage: '이미 사용중인 닉네임입니다.',
    onSubmit: (_) async {},
  ),
);
