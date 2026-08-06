import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_dimensions.dart';
import '../../../core/design_system/app_icons.dart';
import '../../../core/design_system/app_text_styles.dart';
import '../../../core/design_system/widgets/app_calendar.dart';
import '../../../core/design_system/widgets/app_chip.dart';
import '../../../core/design_system/widgets/toggle/app_region_toggle.dart';
import 'explore_filter_actions.dart';

const double _horizontalPadding = 24.0;
const int _regionColumnCount = 4;
const double _regionCellGap = 7.0;
const int _categoryColumnCount = 4;
const double _categoryCellGap = 8.0;

const List<String> _regions = [
  '전국',
  '서울',
  '부산',
  '인천',
  '강원',
  '제주',
  '경기',
  '충청',
  '경상',
  '전라',
];

const List<String> _categories = [
  '기록',
  '예술',
  '쇼핑',
  '탐험',
  '문화',
  '힐링',
  '체험',
  '미식',
];

enum ExploreFilterTab { region, date, category }

class ExploreFilterResult {
  const ExploreFilterResult({
    required this.region,
    required this.dateRange,
    required this.categories,
  });

  final String? region;
  final DateTimeRange? dateRange;
  final Set<String> categories;
}

class ExploreFilterSheet extends StatefulWidget {
  const ExploreFilterSheet({
    super.key,
    required this.initialTab,
    required this.selectedRegion,
    required this.selectedDateRange,
    required this.selectedCategories,
  });

  static const double heightFactor = 669 / 852;

  final ExploreFilterTab initialTab;
  final String? selectedRegion;
  final DateTimeRange? selectedDateRange;
  final Set<String> selectedCategories;

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  late ExploreFilterTab _selectedTab = widget.initialTab;
  late String? _selectedRegion = widget.selectedRegion;
  late DateTimeRange? _selectedDateRange = widget.selectedDateRange;
  late final Set<String> _selectedCategories = {...widget.selectedCategories};
  int _calendarVersion = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(_horizontalPadding, 14, 16, 0),
            child: _SheetHeader(),
          ),
          const SizedBox(height: 6),
          _FilterTabs(
            selectedTab: _selectedTab,
            onChanged: (tab) => setState(() => _selectedTab = tab),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                _horizontalPadding,
                20,
                _horizontalPadding,
                20,
              ),
              child: _buildSelectedContent(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              _horizontalPadding,
              0,
              _horizontalPadding,
              AppDimensions.screenBottomPadding,
            ),
            child: ExploreFilterActions(
              onReset: _resetSelectedTab,
              onApply: () => Navigator.pop(
                context,
                ExploreFilterResult(
                  region: _selectedRegion,
                  dateRange: _selectedDateRange,
                  categories: {..._selectedCategories},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedContent() {
    return IndexedStack(
      index: _selectedTab.index,
      children: [
        _buildRegionContent(),
        _buildDateContent(),
        _buildCategoryContent(),
      ],
    );
  }

  Widget _buildRegionContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGap = _regionCellGap * (_regionColumnCount - 1);
        final cellWidth = (constraints.maxWidth - totalGap) /
            _regionColumnCount;
        final rowCount = (_regions.length / _regionColumnCount).ceil();

        return Column(
          children: [
            for (var rowIndex = 0; rowIndex < rowCount; rowIndex++) ...[
              if (rowIndex > 0) const SizedBox(height: _regionCellGap),
              Row(
                children: [
                  for (
                    var columnIndex = 0;
                    columnIndex < _regionColumnCount;
                    columnIndex++
                  ) ...[
                    if (columnIndex > 0)
                      const SizedBox(width: _regionCellGap),
                    if (rowIndex * _regionColumnCount + columnIndex <
                        _regions.length)
                      SizedBox(
                        width: cellWidth,
                        child: _buildRegionToggle(
                          _regions[
                              rowIndex * _regionColumnCount + columnIndex],
                        ),
                      )
                    else
                      SizedBox(width: cellWidth),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRegionToggle(String region) {
    final value = region == '전국' ? null : region;
    return AppRegionToggle(
      label: region,
      isSelected: _selectedRegion == value,
      onTap: () => setState(() => _selectedRegion = value),
    );
  }

  Widget _buildDateContent() {
    return AppCalendar(
      key: ValueKey(_calendarVersion),
      initialMonth: _selectedDateRange?.start ?? DateTime.now(),
      initialRangeStart: _selectedDateRange?.start,
      initialRangeEnd: _selectedDateRange?.end,
      isCompact: true,
      onRangeSelected: (start, end) {
        _selectedDateRange = DateTimeRange(start: start, end: end);
      },
      onSelectionCleared: () => _selectedDateRange = null,
    );
  }

  Widget _buildCategoryContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGap = _categoryCellGap * (_categoryColumnCount - 1);
        final cellWidth = (constraints.maxWidth - totalGap) /
            _categoryColumnCount;
        final rowCount = (_categories.length / _categoryColumnCount).ceil();

        return Column(
          children: [
            for (var rowIndex = 0; rowIndex < rowCount; rowIndex++) ...[
              if (rowIndex > 0) const SizedBox(height: _categoryCellGap),
              Row(
                children: [
                  for (
                    var columnIndex = 0;
                    columnIndex < _categoryColumnCount;
                    columnIndex++
                  ) ...[
                    if (columnIndex > 0)
                      const SizedBox(width: _categoryCellGap),
                    if (rowIndex * _categoryColumnCount + columnIndex <
                        _categories.length)
                      SizedBox(
                        width: cellWidth,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: _buildCategoryChip(
                            _categories[
                                rowIndex * _categoryColumnCount + columnIndex],
                          ),
                        ),
                      )
                    else
                      SizedBox(width: cellWidth),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategories.contains(category);
    return AppTagChip(
      label: '#$category',
      isSelected: isSelected,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      onTap: () => setState(() {
        isSelected
            ? _selectedCategories.remove(category)
            : _selectedCategories.add(category);
      }),
    );
  }

  void _resetSelectedTab() {
    setState(() {
      switch (_selectedTab) {
        case ExploreFilterTab.region:
          _selectedRegion = null;
        case ExploreFilterTab.date:
          _selectedDateRange = null;
          _calendarVersion++;
        case ExploreFilterTab.category:
          _selectedCategories.clear();
      }
    });
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Text('검색 필터', style: AppTextStyles.subTitle)),
        Semantics(
          button: true,
          label: '닫기',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pop(context),
            child: SizedBox.square(
              dimension: AppDimensions.minimumTapTargetSize,
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.close,
                  width: 24,
                  height: 24,
                  excludeFromSemantics: true,
                  colorFilter: const ColorFilter.mode(
                    AppColors.text,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selectedTab, required this.onChanged});

  final ExploreFilterTab selectedTab;
  final ValueChanged<ExploreFilterTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Divider(height: 1, thickness: 1, color: AppColors.gray2),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FilterTabButton(
                  label: '지역',
                  isSelected: selectedTab == ExploreFilterTab.region,
                  onTap: () => onChanged(ExploreFilterTab.region),
                ),
                const SizedBox(width: 12),
                _FilterTabButton(
                  label: '날짜',
                  isSelected: selectedTab == ExploreFilterTab.date,
                  onTap: () => onChanged(ExploreFilterTab.date),
                ),
                const SizedBox(width: 12),
                _FilterTabButton(
                  label: '카테고리',
                  isSelected: selectedTab == ExploreFilterTab.category,
                  onTap: () => onChanged(ExploreFilterTab.category),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTabButton extends StatelessWidget {
  const _FilterTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppDimensions.minimumTapTargetSize,
            minHeight: AppDimensions.minimumTapTargetSize,
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      color: isSelected ? AppColors.text : AppColors.gray5,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (isSelected)
                    const SizedBox(
                      height: 3,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: -1,
                            right: -1,
                            top: 0,
                            bottom: 0,
                            child: ColoredBox(color: AppColors.text),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(height: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreFilterPreview extends StatelessWidget {
  const _ExploreFilterPreview({required this.initialTab});

  final ExploreFilterTab initialTab;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.gray2,
        body: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: ExploreFilterSheet.heightFactor,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ExploreFilterSheet(
                initialTab: initialTab,
                selectedRegion: null,
                selectedDateRange: null,
                selectedCategories: const {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'haerim', name: '공개 여행 탐색 - 지역 필터', size: Size(393, 852))
Widget exploreRegionFilterPreview() =>
    const _ExploreFilterPreview(initialTab: ExploreFilterTab.region);

@Preview(group: 'haerim', name: '공개 여행 탐색 - 날짜 필터', size: Size(393, 852))
Widget exploreDateFilterPreview() =>
    const _ExploreFilterPreview(initialTab: ExploreFilterTab.date);

@Preview(group: 'haerim', name: '공개 여행 탐색 - 카테고리 필터', size: Size(393, 852))
Widget exploreCategoryFilterPreview() =>
    const _ExploreFilterPreview(initialTab: ExploreFilterTab.category);
