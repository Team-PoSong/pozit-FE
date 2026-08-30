import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_detail_header.dart';
import '../../core/design_system/widgets/app_switch.dart';
import '../../core/design_system/widgets/app_toast.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/user/notification_settings_model.dart';

const double _kHorizontalPadding = 24.0;
const double _kSettingMinHeight = 56.0;
const double _kSectionGap = 6.0;
const double _kSectionTopPadding = 16.0;

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({
    super.key,
    required this.initialSettings,
    this.onChanged,
  });

  final NotificationSettingsModel initialSettings;
  final Future<void> Function(NotificationSettingsModel settings)? onChanged;

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationSettingsModel _settings = widget.initialSettings;
  bool _isSaving = false;

  Future<void> _update(NotificationSettingsModel next) async {
    if (_isSaving) return;
    final previous = _settings;
    setState(() {
      _settings = next;
      _isSaving = true;
    });
    try {
      await widget.onChanged?.call(next);
    } catch (error) {
      if (!mounted) return;
      setState(() => _settings = previous);
      final message = error is ApiException
          ? error.message
          : '알림 설정을 변경하지 못했습니다.';
      showAppToast(context, message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _setMaster(bool value) {
    _update(
      NotificationSettingsModel(
        pushEnabled: value,
        travelEnabled: value ? _settings.travelEnabled : false,
        groupEnabled: value ? _settings.groupEnabled : false,
        pozingEnabled: value ? _settings.pozingEnabled : false,
        courseEnabled: value ? _settings.courseEnabled : false,
        noticeEnabled: value ? _settings.noticeEnabled : false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childrenEnabled = _settings.pushEnabled;
    return Scaffold(
      backgroundColor: AppColors.gray2,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            children: [
              Container(
                color: AppColors.white,
                child: Column(
                  children: [
                    const AppDetailHeader(title: '알림 설정'),
                    _SettingRow(
                      label: '푸시 알림 받기',
                      value: _settings.pushEnabled,
                      onChanged: _setMaster,
                      isEnabled: !_isSaving,
                      isEmphasized: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: _kSectionGap),
              Expanded(
                child: Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.only(top: _kSectionTopPadding),
                  child: Column(
                    children: [
                      _SettingRow(
                        label: '여행 시작/종료 알림',
                        value: _settings.travelEnabled,
                        isEnabled: childrenEnabled && !_isSaving,
                        onChanged: (value) =>
                            _update(_settings.copyWith(travelEnabled: value)),
                      ),
                      _SettingRow(
                        label: '그룹 활동 알림',
                        value: _settings.groupEnabled,
                        isEnabled: childrenEnabled && !_isSaving,
                        onChanged: (value) =>
                            _update(_settings.copyWith(groupEnabled: value)),
                      ),
                      _SettingRow(
                        label: 'Pozing 등록 알림',
                        value: _settings.pozingEnabled,
                        isEnabled: childrenEnabled && !_isSaving,
                        onChanged: (value) =>
                            _update(_settings.copyWith(pozingEnabled: value)),
                      ),
                      _SettingRow(
                        label: '코스 진행 알림',
                        value: _settings.courseEnabled,
                        isEnabled: childrenEnabled && !_isSaving,
                        onChanged: (value) =>
                            _update(_settings.copyWith(courseEnabled: value)),
                      ),
                      _SettingRow(
                        label: '공지 및 이벤트 알림',
                        value: _settings.noticeEnabled,
                        isEnabled: childrenEnabled && !_isSaving,
                        onChanged: (value) =>
                            _update(_settings.copyWith(noticeEnabled: value)),
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

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.isEnabled = true,
    this.isEmphasized = false,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isEnabled;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _kSettingMinHeight),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style:
                    (isEmphasized ? AppTextStyles.subTitle : AppTextStyles.body)
                        .copyWith(color: AppColors.text),
              ),
            ),
            AppSwitch(
              key: ValueKey(label),
              value: value,
              isEnabled: isEnabled,
              semanticLabel: label,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: '알림 설정', size: Size(393, 852))
Widget notificationSettingsScreenPreview() => const MaterialApp(
  home: NotificationSettingsScreen(
    initialSettings: NotificationSettingsModel(
      pushEnabled: true,
      travelEnabled: true,
      groupEnabled: true,
      pozingEnabled: true,
      courseEnabled: true,
      noticeEnabled: true,
    ),
  ),
);
