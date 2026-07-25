import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/app_travel_status.dart';
import '../../core/design_system/widgets/app_calendar.dart';
import '../../core/design_system/widgets/app_chip.dart';
import '../../core/design_system/widgets/app_input_field.dart';
import '../../core/design_system/widgets/app_posing.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/design_system/widgets/toggle/app_visibility_toggle.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';

const double _kHorizontalPadding = 24.0;
const double _kTopBarToFirstGap = 39.0;
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

/// 여행 설정 화면을 저장했을 때 상위로 전달되는 값입니다.
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

/// 여행 설정 화면입니다.
///
/// '여행 전'/'여행 후' 상태에서만 진입할 수 있으며, '여행 후'일 때는 다른
/// 공통 항목들 위에 공개 여부 섹션이 추가로 표시됩니다. [destination](여행지)은
/// 이미 정해진 값을 보여주기만 하고 수정할 수 없습니다.
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
  }) : assert(
         status != AppTravelStatus.inProgress,
         '여행 설정은 여행 전/후 상태에서만 진입할 수 있습니다.',
       );

  final AppTravelStatus status;
  final String destination;
  final String initialTravelName;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final List<String> initialTags;
  final bool initialIsPublic;
  final File? initialBackgroundImage;
  final VoidCallback? onBackTap;

  /// '저장하기'를 눌렀을 때 호출됩니다. 실제 저장(서버 반영)은 호출하는 쪽의 몫입니다.
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

  bool get _isFormValid =>
      _backgroundImage != null &&
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
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _backgroundImage = File(picked.path));
  }

  Future<void> _handlePickDateRange() async {
    final range = await showDialog<DateTimeRange>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: AppCalendar(
          initialMonth: _startDate ?? DateTime.now(),
          onRangeSelected: (start, end) {
            Navigator.of(
              dialogContext,
            ).pop(DateTimeRange(start: start, end: end));
          },
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
  }

  void _handleBack() {
    widget.onBackTap?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: _kHorizontalPadding,
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
                          : _BackgroundPhotoPreview(image: _backgroundImage!),
                    ),
                    const SizedBox(height: _kPhotoToNameLabelGap),
                    const _SectionLabel('여행명'),
                    const SizedBox(height: _kLabelToFieldGap),
                    AppInputField(
                      controller: _travelNameController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: _kFieldToNextLabelGap),
                    const _SectionLabel('어디로 떠나시나요?'),
                    const SizedBox(height: _kLabelToFieldGap),
                    AppInputField(
                      controller: _destinationController,
                      readOnly: true,
                      textColor: AppColors.gray5,
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

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 10,
      children: [
        for (final tag in _kTravelTagOptions)
          AppTagChip(
            label: tag,
            isSelected: selectedTags.contains(tag),
            onTap: () => onToggle(tag),
          ),
      ],
    );
  }
}

TravelSettingsScreen _previewScreen(AppTravelStatus status) {
  return TravelSettingsScreen(
    status: status,
    destination: '경주',
    initialTravelName: '경주 여행',
    initialStartDate: DateTime(2026, 6, 5),
    initialEndDate: DateTime(2026, 6, 7),
    initialTags: const ['기록', '미식'],
  );
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
  name: 'TravelSettingsScreen - 여행 후',
  size: Size(390, 844),
)
Widget travelSettingsScreenCompletedPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _previewScreen(AppTravelStatus.completed),
  );
}
