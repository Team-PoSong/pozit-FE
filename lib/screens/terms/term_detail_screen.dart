import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../data/models/support/support_info_model.dart';

class TermDetailScreen extends StatelessWidget {
  const TermDetailScreen({super.key, required this.term});

  final TermModel term;

  String get _effectiveDateText {
    final date = term.effectiveDate;
    if (date == null) return '버전 ${term.version}';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '시행일 ${date.year}.$month.$day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            children: [
              AppDetailHeader(title: term.title),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        term.title,
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.text,
                          fontSize: 22,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _effectiveDateText,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: AppColors.gray3),
                      const SizedBox(height: 26),
                      _TermContent(term: term),
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

class _TermContent extends StatelessWidget {
  const _TermContent({required this.term});

  final TermModel term;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < term.sections.length; index++) ...[
            Text(
              term.sections[index].title,
              style: AppTextStyles.subTitle.copyWith(color: AppColors.text),
            ),
            const SizedBox(height: 10),
            Text(
              term.sections[index].content,
              style: AppTextStyles.body.copyWith(color: AppColors.gray5),
            ),
            if (index < term.sections.length - 1) const SizedBox(height: 26),
          ],
        ],
      ),
    );
  }
}

@Preview(group: 'haerim', name: '서비스 이용약관', size: Size(393, 852))
Widget termDetailScreenPreview() => MaterialApp(
  home: TermDetailScreen(
    term: TermModel(
      title: '서비스 이용약관',
      version: '1.0',
      effectiveDate: DateTime(2026, 8, 1),
      sections: [
        TermSectionModel(
          title: '제1조 (목적)',
          content: '본 약관은 Pozit 서비스 이용에 관한 사항을 규정합니다.',
        ),
      ],
    ),
  ),
);
