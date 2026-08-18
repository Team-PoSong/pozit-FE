import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/travel_invite/travel_invite_search_model.dart';
import '../../data/repositories/travel_invite/travel_invite_repository.dart';
import '../travel_detail/travel_detail_page.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';
import 'invite_code_content.dart';

const double _horizontalPadding = 24.0;
const double _topBarToContentGap = 20.0;
const double _joinErrorToButtonGap = 12.0;

class InviteCodeScreen extends StatefulWidget {
  const InviteCodeScreen({
    super.key,
    this.onBackTap,
    this.onJoined,
    TravelInviteRepository? inviteRepository,
  }) : inviteRepository = inviteRepository ?? const TravelInviteRepository();

  final VoidCallback? onBackTap;
  final ValueChanged<int>? onJoined;
  final TravelInviteRepository inviteRepository;

  @override
  State<InviteCodeScreen> createState() => _InviteCodeScreenState();
}

class _InviteCodeScreenState extends State<InviteCodeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  TravelInviteSearchModel? _travel;
  String? _errorMessage;
  String? _joinErrorMessage;
  bool _showErrorBorder = false;
  bool _isJoinBlocked = false;
  bool _isLookingUp = false;
  bool _isJoining = false;
  int _lookupGeneration = 0;

  bool get _hasCompleteCode =>
      _controller.text.length == TravelInviteSearchModel.inviteCodeLength;
  bool get _isLoading => _isLookingUp || _isJoining;

  bool get _canSubmit {
    if (_isLoading) return false;
    return !_isJoinBlocked &&
        _travel?.status == TravelInviteSearchStatus.joinable;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_isJoining) return;
    if (widget.onBackTap case final callback?) {
      callback();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _handleCodeChanged(String _) {
    final generation = ++_lookupGeneration;
    final inviteCode = _controller.text;
    setState(() {
      _travel = null;
      _joinErrorMessage = null;
      _isJoinBlocked = false;
      _errorMessage = inviteCode.isNotEmpty && !_hasCompleteCode
          ? '${TravelInviteSearchModel.inviteCodeLength}자리 모두 입력해주세요.'
          : null;
      _showErrorBorder = false;
      _isLookingUp = _hasCompleteCode;
    });

    if (_hasCompleteCode) {
      _findTravel(inviteCode, generation);
    }
  }

  Future<void> _handleSubmit() async {
    if (_isLoading) return;
    if (_travel?.status == TravelInviteSearchStatus.joinable) {
      await _joinTravel(_travel!.travelId);
    }
  }

  Future<void> _findTravel(String inviteCode, int generation) async {
    try {
      final travel = await widget.inviteRepository.findTravel(inviteCode);
      if (!mounted || generation != _lookupGeneration) return;
      _focusNode.unfocus();
      setState(() {
        _travel = travel;
        _joinErrorMessage = null;
        _isJoinBlocked = false;
        _errorMessage = switch (travel.status) {
          TravelInviteSearchStatus.joinable => null,
          TravelInviteSearchStatus.alreadyJoined => '이미 참여중인 여행입니다.',
          TravelInviteSearchStatus.unavailable => '참여할 수 없는 여행입니다.',
        };
        _showErrorBorder = travel.status != TravelInviteSearchStatus.joinable;
      });
    } on ApiException catch (error) {
      if (!mounted || generation != _lookupGeneration) return;
      setState(() {
        _travel = null;
        _errorMessage = error.code == 'TRAVEL400_5'
            ? '유효하지 않은 초대 코드입니다.'
            : error.message;
        _showErrorBorder = true;
      });
    } finally {
      if (generation == _lookupGeneration) {
        _setLookingUp(false);
      }
    }
  }

  Future<void> _joinTravel(int travelId) async {
    _setJoining(true);
    try {
      final joined = await widget.inviteRepository.joinTravel(travelId);
      if (!mounted) return;
      if (widget.onJoined case final callback?) {
        callback(joined.travelId);
        return;
      }
      Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute(
          builder: (_) => TravelDetailPage(travelId: joined.travelId),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _joinErrorMessage = error.message;
        _isJoinBlocked = _isClientError(error);
      });
    } finally {
      _setJoining(false);
    }
  }

  void _setLookingUp(bool value) {
    if (!mounted || _isLookingUp == value) return;
    setState(() => _isLookingUp = value);
  }

  void _setJoining(bool value) {
    if (!mounted || _isJoining == value) return;
    setState(() => _isJoining = value);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isJoining,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              TravelDetailTopBar(title: '초대 코드로 참여하기', onBackTap: _handleBack),
              const SizedBox(height: _topBarToContentGap),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _horizontalPadding,
                  ),
                  child: InviteCodeContent(
                    controller: _controller,
                    focusNode: _focusNode,
                    isJoining: _isJoining,
                    onCodeChanged: _handleCodeChanged,
                    errorMessage: _errorMessage,
                    showErrorBorder: _showErrorBorder,
                    travel: _travel,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  _horizontalPadding,
                  0,
                  _horizontalPadding,
                  AppDimensions.screenBottomPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_joinErrorMessage case final message?) ...[
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: _joinErrorToButtonGap),
                    ],
                    AppButton(
                      text: '다음',
                      isEnabled: _canSubmit,
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isClientError(ApiException error) {
  final statusCode = error.statusCode;
  return statusCode != null && statusCode >= 400 && statusCode < 500;
}

@Preview(group: 'haerim', name: 'Invite Code Screen', size: Size(393, 852))
Widget inviteCodeScreenPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: InviteCodeScreen(),
  );
}
