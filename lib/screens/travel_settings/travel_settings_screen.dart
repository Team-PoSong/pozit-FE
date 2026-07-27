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
// TravelDetailTopBar가 자체적으로 위에 4px을 더 내려가므로(_kTopOffset),
// 탑 바 다음 요소의 위치가 그대로 유지되도록 이 간격을 8px 줄였습니다.
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
/// 팀장은 여행 전/중/후 어느 상태에서든 진입할 수 있으며, '여행 후'일 때는
/// 다른 공통 항목들 위에 공개 여부 섹션이 추가로 표시됩니다.
/// [destination](여행지)은 이미 정해진 값을 보여주기만 하고 수정할 수 없습니다.
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
    // 태그 자체의 GestureDetector가 탭을 먼저 가져가서(제스처 아레나 승리),
    // 화면 전체를 감싼 "바깥 탭 시 포커스 해제" 처리기가 실행되지 않습니다.
    // 그래서 태그를 눌렀을 때 여기서 직접 포커스를 해제합니다.
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
                        hintText: widget.initialTravelName.isNotEmpty
                            ? widget.initialTravelName
                            : '친구들과 경주 여행',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: _kFieldToNextLabelGap),
                      const _SectionLabel('어디로 떠나시나요?'),
                      const SizedBox(height: _kLabelToFieldGap),
                      // 수정할 수 없는 항목이라, 탭이 TextField까지 전달되지
                      // 않도록 막아 포커스(선택 테두리)가 생기지 않게 합니다.
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
                        hintText: _hasInitialDateRange
                            ? _formatDateRange(
                                widget.initialStartDate!,
                                widget.initialEndDate!,
                              )
                            : '8/18 - 8/21',
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

/// 태그를 2행 4열 고정 그리드로 배치합니다. 텍스트 길이에 따라 줄바꿈
/// 개수가 바뀌는 [Wrap] 대신 한 행에 4개씩 직접 묶고, 각 칸을 [Expanded]로
/// 균등 분할해 전체 가로 너비(좌우 기본 패딩 제외)를 채우도록 합니다.
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
                    // 기본 padding(좌우 24)은 4칸 그리드 폭 안에서 라벨이
                    // 줄바꿈되므로, 이 화면에서만 좌우를 줄입니다.
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
