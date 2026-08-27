import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../core/design_system/widgets/app_toast.dart';
import '../../core/network/api_exception.dart';
import '../../data/repositories/support/support_repository.dart';
import 'feedback_content.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key, SupportRepository? repository})
    : repository = repository ?? const SupportRepository();

  final SupportRepository repository;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _controller = TextEditingController();
  int _currentLength = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    setState(() => _currentLength = value.characters.length);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      await widget.repository.sendFeedback(content);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final message = error is ApiException ? error.message : '피드백을 보내지 못했습니다.';
      showAppToast(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            children: [
              const AppDetailHeader(title: '피드백 보내기'),
              Expanded(
                child: FeedbackContent(
                  controller: _controller,
                  currentLength: _currentLength,
                  isSubmitting: _isSubmitting,
                  onChanged: _handleChanged,
                  onSubmit: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: '피드백 보내기', size: Size(393, 852))
Widget feedbackScreenPreview() => const MaterialApp(home: FeedbackScreen());
