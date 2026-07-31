import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/app_travel_status.dart';
import '../../core/design_system/widgets/app_chip.dart';
import '../../core/design_system/widgets/app_input_field.dart';
import '../../core/design_system/widgets/app_posing.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/design_system/widgets/toggle/app_visibility_toggle.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';
import 'travel_date_edit_screen.dart';

const double _kHorizontalPadding = 24.0;

const double _kTopBarToFirstGap = 31.0;
const double _kLabelToFieldGap = 18.0;
const double _kFieldToNextLabelGap = 23.0;
const double _kPhotoToNameLabelGap = 19.0;
const double _kTagGridToButtonGap = 36.0;
const double _kVisibilityTitleToDescGap = 14.0;
const double _kVisibilityDescToToggleGap = 20.0;
const double _kVisibilityToggleToCommonGap = 19.0;
const double _kVisibilityToggleGap = 9.0;

const int _kMaxTagCount = 2;
const List<String> _kTravelTagOptions = [
  '기록',
  '미식',
  '힐링',
  '체험',
  '문화',
  '예술',
  '쇼핑',
  '탐험',
];

class TravelSettingsResult {
  const TravelSettingsResult({
    required this.travelName,
    required this.startDate,
    required this.endDate,
    required this.tags,
    required this.isPublic,
    this.backgroundImage,
  });

  final String travelName;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> tags;
  final bool isPublic;
  final File? backgroundImage;
}

class TravelSettingsScreen extends StatefulWidget {
  const TravelSettingsScreen({
    super.key,
    required this.status,
    required this.destination,
    this.initialTravelName = '',
    this.initialStartDate,
    this.initialEndDate,
    this.initialTags = const [],
    this.initialIsPublic = false,
    this.initialBackgroundImage,
    this.onBackTap,
    this.onSave,
  });

  final AppTravelStatus status;
  final String destination;
  final String initialTravelName;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final List<String> initialTags;
  final bool initialIsPublic;
  final File? initialBackgroundImage;
  final VoidCallback? onBackTap;

  final ValueChanged<TravelSettingsResult>? onSave;

  @override
  State<TravelSettingsScreen> createState() => _TravelSettingsScreenState();
}

class _TravelSettingsScreenState extends State<TravelSettingsScreen> {
  late final TextEditingController _travelNameController =
      TextEditingController(text: widget.initialTravelName);
  late final TextEditingController _destinationController =
      TextEditingController(text: widget.destination);
  late final TextEditingController _dateController = TextEditingController(
    text: _hasInitialDateRange
        ? _formatDateRange(widget.initialStartDate!, widget.initialEndDate!)
        : '',
  );
  late DateTime? _startDate = widget.initialStartDate;
  late DateTime? _endDate = widget.initialEndDate;
  late final Set<String> _selectedTags = {...widget.initialTags};
  late bool _isPublic = widget.initialIsPublic;
  File? _backgroundImage;

  bool get _hasInitialDateRange =>
      widget.initialStartDate != null && widget.initialEndDate != null;

  bool get _isCompleted => widget.status == AppTravelStatus.completed;

  bool get _hasChanges =>
      _travelNameController.text.trim() != widget.initialTravelName.trim() ||
      _startDate != widget.initialStartDate ||
      _endDate != widget.initialEndDate ||
      _selectedTags.length != widget.initialTags.length ||
      !_selectedTags.containsAll(widget.initialTags) ||
      _isPublic != widget.initialIsPublic ||
      _backgroundImage != widget.initialBackgroundImage;

  bool get _isFormValid =>
      _hasChanges &&
      _travelNameController.text.trim().isNotEmpty &&
      _startDate != null &&
      _endDate != null &&
      _selectedTags.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _backgroundImage = widget.initialBackgroundImage;
  }

  @override
  void dispose() {
    _travelNameController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  static String _formatDateRange(DateTime start, DateTime end) =>
      '${start.month}/${start.day} - ${end.month}/${end.day}';

  Future<void> _handlePickBackgroundImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (picked == null || !mounted) return;
      setState(() => _backgroundImage = File(picked.path));
    } catch (error) {
      debugPrint('배경 사진 선택 실패: $error');
    }
  }

  Future<void> _handlePickDateRange() async {
    final range = await Navigator.of(context).push<DateTimeRange>(
      MaterialPageRoute<DateTimeRange>(
        builder: (_) => TravelDateEditScreen(
          initialStartDate: _startDate ?? DateTime.now(),
          initialEndDate: _endDate ?? DateTime.now(),
        ),
      ),
    );
    if (range == null) return;
    setState(() {
      _startDate = range.start;
      _endDate = range.end;
      _dateController.text = _formatDateRange(range.start, range.end);
    });
  }

  void _handleToggleTag(String tag) {
    FocusScope.of(context).unfocus();
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else if (_selectedTags.length < _kMaxTagCount) {
        _selectedTags.add(tag);
      }
    });
  }

  void _handleSave() {
    widget.onSave?.call(
      TravelSettingsResult(
        travelName: _travelNameController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        tags: _selectedTags.toList(),
        isPublic: _isPublic,
        backgroundImage: _backgroundImage,
      ),
    );
    Navigator.of(context).pop();
  }

  void _handleBack() {
    widget.onBackTap?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TravelDetailTopBar(title: '여행 설정', onBackTap: _handleBack),
                const SizedBox(height: _kTopBarToFirstGap),
                if (_isCompleted) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _kHorizontalPadding,
                    ),
                    child: _VisibilitySection(
                      isPublic: _isPublic,
                      onChanged: (value) => setState(() => _isPublic = value),
                    ),
                  ),
                  const SizedBox(height: _kVisibilityToggleToCommonGap),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    _kHorizontalPadding,
                    0,
                    _kHorizontalPadding,
                    AppDimensions.screenBottomPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('배경사진 추가하기'),
                      const SizedBox(height: _kLabelToFieldGap),
                      GestureDetector(
                        onTap: _handlePickBackgroundImage,
                        child: _backgroundImage == null
                            ? const AppPosing.travelPhoto()
                            : _BackgroundPhotoPreview(
                                image: _backgroundImage!,
                              ),
                      ),
                      const SizedBox(height: _kPhotoToNameLabelGap),
                      const _SectionLabel('여행명'),
                      const SizedBox(height: _kLabelToFieldGap),
                      AppInputField(
                        controller: _travelNameController,
                        hintText: '친구들과 경주 여행',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: _kFieldToNextLabelGap),
                      const _SectionLabel('어디로 떠나시나요?'),
                      const SizedBox(height: _kLabelToFieldGap),

                      IgnorePointer(
                        child: AppInputField(
                          controller: _destinationController,
                          readOnly: true,
                          textColor: AppColors.gray5,
                        ),
                      ),
                      const SizedBox(height: _kFieldToNextLabelGap),
                      const _SectionLabel('여행이 언제인가요?'),
                      const SizedBox(height: _kLabelToFieldGap),
                      AppInputField(
                        controller: _dateController,
                        readOnly: true,
                        hintText: '8/18 - 8/21',
                        onTap: _handlePickDateRange,
                      ),
                      const SizedBox(height: _kFieldToNextLabelGap),
                      const _SectionLabel('어떤 여행인가요?(최대 2개 선택)'),
                      const SizedBox(height: _kLabelToFieldGap),
                      _TagGrid(
                        selectedTags: _selectedTags,
                        onToggle: _handleToggleTag,
                      ),
                      const SizedBox(height: _kTagGridToButtonGap),
                      AppButton(
                        text: '저장하기',
                        isEnabled: _isFormValid,
                        onPressed: _handleSave,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.subTitle.copyWith(color: AppColors.text),
    );
  }
}

class _BackgroundPhotoPreview extends StatelessWidget {
  const _BackgroundPhotoPreview({required this.image});

  final File image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 183,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Image.file(image, fit: BoxFit.cover),
    );
  }
}

class _VisibilitySection extends StatelessWidget {
  const _VisibilitySection({required this.isPublic, required this.onChanged});

  final bool isPublic;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('공개 여부'),
        const SizedBox(height: _kVisibilityTitleToDescGap),
        Text(
          '공개를 선택할 시 다른 사용자들이 탐색 탭에서 내 여행 코스와 설정한 배경 사진을 볼 수 있습니다. (로그 제외)',
          style: AppTextStyles.body.copyWith(color: AppColors.gray5),
        ),
        const SizedBox(height: _kVisibilityDescToToggleGap),
        Row(
          children: [
            Expanded(
              child: AppVisibilityToggle(
                label: '비공개',
                isSelected: !isPublic,
                onTap: () => onChanged(false),
              ),
            ),
            const SizedBox(width: _kVisibilityToggleGap),
            Expanded(
              child: AppVisibilityToggle(
                label: '공개',
                isSelected: isPublic,
                onTap: () => onChanged(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TagGrid extends StatelessWidget {
  const _TagGrid({required this.selectedTags, required this.onToggle});

  final Set<String> selectedTags;
  final ValueChanged<String> onToggle;

  static const int _columns = 4;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (var i = 0; i < _kTravelTagOptions.length; i += _columns)
        _kTravelTagOptions.sublist(
          i,
          (i + _columns).clamp(0, _kTravelTagOptions.length),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: 10),
          Row(
            children: [
              for (var c = 0; c < rows[r].length; c++) ...[
                if (c > 0) const SizedBox(width: 9),
                Expanded(
                  child: AppTagChip(
                    label: '# ${rows[r][c]}',
                    isSelected: selectedTags.contains(rows[r][c]),
                    onTap: () => onToggle(rows[r][c]),

                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 12.0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

TravelSettingsScreen _previewScreen(AppTravelStatus status) {
  return TravelSettingsScreen(status: status, destination: '경주');
}

@Preview(
  group: 'travel_settings',
  name: 'TravelSettingsScreen - 여행 전',
  size: Size(390, 844),
)
Widget travelSettingsScreenUpcomingPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _previewScreen(AppTravelStatus.upcoming),
  );
}

@Preview(
  group: 'travel_settings',
  name: 'TravelSettingsScreen - 여행 중',
  size: Size(390, 844),
)
Widget travelSettingsScreenInProgressPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _previewScreen(AppTravelStatus.inProgress),
  );
}

@Preview(
  group: 'travel_settings',
  name: 'TravelSettingsScreen - 여행 후',
  size: Size(390, 844),
)
Widget travelSettingsScreenCompletedPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _previewScreen(AppTravelStatus.completed),
  );
}
