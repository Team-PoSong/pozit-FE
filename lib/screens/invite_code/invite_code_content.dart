import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_travel_card.dart';
import '../../data/models/travel_invite/travel_invite_search_model.dart';

const double _codeCellGap = 10.0;
const double _codeRowHorizontalPadding = 3.0;
const double _codeCellMinHeight = 67.0;
const double _codeCellRadius = 4.0;
const double _promptToInputGap = 52.0;
const double _inputToMessageGap = 14.0;
const double _messageToTravelGap = 84.0;
const double _errorMessageHeight = 14.0;
const double _travelTitleToCardGap = 24.0;

class InviteCodeContent extends StatelessWidget {
  const InviteCodeContent({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onCodeChanged,
    this.isJoining = false,
    this.errorMessage,
    this.showErrorBorder = false,
    this.travel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onCodeChanged;
  final bool isJoining;
  final String? errorMessage;
  final bool showErrorBorder;
  final TravelInviteSearchModel? travel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '초대 코드를 입력해주세요.',
          style: AppTextStyles.headline.copyWith(color: AppColors.text),
        ),
        const SizedBox(height: _promptToInputGap),
        _InviteCodeInput(
          controller: controller,
          focusNode: focusNode,
          isEnabled: !isJoining,
          isError: showErrorBorder,
          isValidated: travel?.status == TravelInviteSearchStatus.joinable,
          onChanged: onCodeChanged,
        ),
        if (errorMessage case final message?) ...[
          const SizedBox(height: _inputToMessageGap),
          SizedBox(
            width: double.infinity,
            child: Semantics(
              liveRegion: true,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ),
          ),
        ],
        if (travel case final item?) ...[
          SizedBox(
            height:
                _messageToTravelGap +
                (errorMessage == null
                    ? _inputToMessageGap + _errorMessageHeight
                    : 0),
          ),
          Text(
            '이 여행이 맞으신가요?',
            style: AppTextStyles.headline.copyWith(color: AppColors.text),
          ),
          const SizedBox(height: _travelTitleToCardGap),
          AppTravelCard(
            type: AppTravelCardType.myTravel,
            title: item.title,
            location: item.destination,
            dateText: _dateText(item.startDate, item.endDate),
            author: item.leader,
            status: item.travelStatus,
            dDay: _dDay(item.startDate),
            tags: item.tags,
            participantCount: item.memberCount,
            backgroundImage: item.backgroundImageUrl.isEmpty
                ? null
                : NetworkImage(item.backgroundImageUrl),
          ),
        ],
      ],
    );
  }

  static String _dateText(DateTime startDate, DateTime endDate) {
    final totalDays = endDate.difference(startDate).inDays + 1;
    final duration = totalDays <= 1 ? '당일치기' : '${totalDays - 1}박 $totalDays일';
    return '${startDate.month}/${startDate.day} ~ '
        '${endDate.month}/${endDate.day} · $duration';
  }

  static String _dDay(DateTime startDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final days = start.difference(today).inDays;
    if (days == 0) return 'D-Day';
    return days > 0 ? 'D-$days' : 'D+${days.abs()}';
  }
}

class _InviteCodeInput extends StatelessWidget {
  const _InviteCodeInput({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.isEnabled = true,
    this.isError = false,
    this.isValidated = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool isEnabled;
  final bool isError;
  final bool isValidated;

  @override
  Widget build(BuildContext context) {
    void focusAtEnd() {
      focusNode.requestFocus();
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }

    return Semantics(
      textField: true,
      label: '${TravelInviteSearchModel.inviteCodeLength}자리 초대 코드',
      value: controller.text,
      enabled: isEnabled,
      onTap: isEnabled ? focusAtEnd : null,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _codeRowHorizontalPadding,
            ),
            child: Row(
              children: [
                for (
                  var index = 0;
                  index < TravelInviteSearchModel.inviteCodeLength;
                  index++
                ) ...[
                  if (index > 0) const SizedBox(width: _codeCellGap),
                  Expanded(
                    child: _InviteCodeCell(
                      character: index < controller.text.length
                          ? controller.text[index]
                          : '',
                      isError: isError,
                      isValidated: isValidated,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned.fill(
            child: ExcludeSemantics(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: isEnabled,
                autofocus: true,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                enableSuggestions: false,
                enableInteractiveSelection: false,
                showCursor: false,
                maxLength: TravelInviteSearchModel.inviteCodeLength,
                inputFormatters: [
                  const _UpperCaseAlphaNumericFormatter(),
                  LengthLimitingTextInputFormatter(
                    TravelInviteSearchModel.inviteCodeLength,
                  ),
                ],
                onTap: focusAtEnd,
                onChanged: onChanged,
                cursorColor: Colors.transparent,
                style: AppTextStyles.body.copyWith(color: Colors.transparent),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteCodeCell extends StatelessWidget {
  const _InviteCodeCell({
    required this.character,
    required this.isError,
    required this.isValidated,
  });

  final String character;
  final bool isError;
  final bool isValidated;

  @override
  Widget build(BuildContext context) {
    final borderColor = isError
        ? AppColors.error
        : isValidated
        ? AppColors.purple2
        : character.isNotEmpty
        ? AppColors.purple3
        : Colors.transparent;
    return Container(
      constraints: const BoxConstraints(minHeight: _codeCellMinHeight),
      padding: const EdgeInsets.symmetric(vertical: 23.5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.gray2,
        borderRadius: BorderRadius.circular(_codeCellRadius),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        character,
        style: AppTextStyles.headline.copyWith(color: AppColors.text),
      ),
    );
  }
}

class _UpperCaseAlphaNumericFormatter extends TextInputFormatter {
  const _UpperCaseAlphaNumericFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final value = newValue.text.replaceAll(RegExp('[^a-zA-Z0-9]'), '');
    final upperCaseValue = value.toUpperCase();
    return newValue.copyWith(
      text: upperCaseValue,
      selection: TextSelection.collapsed(offset: upperCaseValue.length),
      composing: TextRange.empty,
    );
  }
}

TravelInviteSearchModel _previewTravel(TravelInviteSearchStatus status) {
  return TravelInviteSearchModel(
    status: status,
    travelStatus: AppTravelStatus.upcoming,
    message: switch (status) {
      TravelInviteSearchStatus.joinable => '성공적으로 조회했어요.',
      TravelInviteSearchStatus.alreadyJoined => '이미 참여한 여행입니다.',
      TravelInviteSearchStatus.unavailable => '참여할 수 없는 여행입니다.',
    },
    travelId: 1,
    title: '강릉 데이트',
    destination: '강원 강릉',
    leader: '민서',
    memberCount: 2,
    tags: const ['문화', '탐험'],
    startDate: DateTime(2026, 7, 2),
    endDate: DateTime(2026, 7, 3),
    backgroundImageUrl: '',
  );
}

@Preview(group: 'haerim', name: 'Invite Code Content - 여행 확인')
Widget inviteCodeContentFoundPreview() {
  return _previewContent(
    code: 'PZ82H',
    travel: _previewTravel(TravelInviteSearchStatus.joinable),
  );
}

@Preview(group: 'haerim', name: 'Invite Code Content - 이미 참여')
Widget inviteCodeContentAlreadyJoinedPreview() {
  return _previewContent(
    code: 'PZ82H',
    errorMessage: '이미 참여중인 여행입니다.',
    showErrorBorder: true,
    travel: _previewTravel(TravelInviteSearchStatus.alreadyJoined),
  );
}

@Preview(group: 'haerim', name: 'Invite Code Content - 입력 미완료')
Widget inviteCodeContentIncompletePreview() {
  return _previewContent(
    code: 'PZ',
    errorMessage: '${TravelInviteSearchModel.inviteCodeLength}자리 모두 입력해주세요.',
  );
}

@Preview(group: 'haerim', name: 'Invite Code Content - 유효하지 않은 코드')
Widget inviteCodeContentInvalidPreview() {
  return _previewContent(
    code: 'PZ82K',
    errorMessage: '유효하지 않은 초대 코드입니다.',
    showErrorBorder: true,
  );
}

@Preview(group: 'haerim', name: 'Invite Code Content - 참여 불가')
Widget inviteCodeContentUnavailablePreview() {
  return _previewContent(
    code: 'PZ82H',
    errorMessage: '참여할 수 없는 여행입니다.',
    showErrorBorder: true,
    travel: _previewTravel(TravelInviteSearchStatus.unavailable),
  );
}

Widget _previewContent({
  required String code,
  String? errorMessage,
  bool showErrorBorder = false,
  TravelInviteSearchModel? travel,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: InviteCodeContent(
          controller: TextEditingController(text: code),
          focusNode: FocusNode(),
          onCodeChanged: (_) {},
          errorMessage: errorMessage,
          showErrorBorder: showErrorBorder,
          travel: travel,
        ),
      ),
    ),
  );
}
