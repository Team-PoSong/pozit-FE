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

double _minCellWidthFor({
  required List<String> labels,
  required TextStyle style,
  required double horizontalPadding,
  required TextScaler textScaler,
}) {
  var maxTextWidth = 0.0;
  for (final label in labels) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();
    if (painter.width > maxTextWidth) maxTextWidth = painter.width;
  }
  return maxTextWidth + horizontalPadding;
}

Widget _buildFixedColumnGrid({
  required int itemCount,
  required int crossAxisCount,
  required double cellWidth,
  required double gap,
  required double rowGap,
  required Widget Function(int index) itemBuilder,
}) {
  final rows = <Widget>[];
  for (var start = 0; start < itemCount; start += crossAxisCount) {
    final end = start + crossAxisCount > itemCount
        ? itemCount
        : start + crossAxisCount;
    rows.add(
      Row(
        children: [
          for (var index = start; index < end; index++) ...[
            if (index > start) SizedBox(width: gap),
            SizedBox(width: cellWidth, child: itemBuilder(index)),
          ],
        ],
      ),
    );
    if (end < itemCount) rows.add(SizedBox(height: rowGap));
  }
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
}

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
    const crossAxisCount = 4;
    const idealGap = 7.0;
    const minGap = 4.0;
    const cellHorizontalPadding = 20.0 * 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final minCellWidth = _minCellWidthFor(
          labels: _regions,
          style: AppTextStyles.subTitle,
          horizontalPadding: cellHorizontalPadding,
          textScaler: MediaQuery.textScalerOf(context),
        );
        var gap = idealGap;
        var cellWidth =
            (constraints.maxWidth - gap * (crossAxisCount - 1)) /
            crossAxisCount;
        if (cellWidth < minCellWidth) {
          gap = minGap;
          cellWidth =
              (constraints.maxWidth - gap * (crossAxisCount - 1)) /
              crossAxisCount;
        }
        cellWidth = cellWidth.clamp(0.0, double.infinity);

        return _buildFixedColumnGrid(
          itemCount: _regions.length,
          crossAxisCount: crossAxisCount,
          cellWidth: cellWidth,
          gap: gap,
          rowGap: idealGap,
          itemBuilder: (index) => _buildRegionToggle(_regions[index]),
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
    const crossAxisCount = 4;
    const idealGap = 8.0;
    const minGap = 4.0;
    const cellHorizontalPadding = 24.0 * 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final labels = _categories.map((category) => '#$category').toList();
        final minCellWidth = _minCellWidthFor(
          labels: labels,
          style: AppTextStyles.caption2,
          horizontalPadding: cellHorizontalPadding,
          textScaler: MediaQuery.textScalerOf(context),
        );

        var gap = idealGap;
        var cellWidth =
            (constraints.maxWidth - gap * (crossAxisCount - 1)) /
            crossAxisCount;
        if (cellWidth < minCellWidth) {
          gap = minGap;
          cellWidth =
              (constraints.maxWidth - gap * (crossAxisCount - 1)) /
              crossAxisCount;
        }
        cellWidth = cellWidth.clamp(0.0, double.infinity);

        return _buildFixedColumnGrid(
          itemCount: _categories.length,
          crossAxisCount: crossAxisCount,
          cellWidth: cellWidth,
          gap: gap,
          rowGap: idealGap,
          itemBuilder: (index) {
            final category = _categories[index];
            final isSelected = _selectedCategories.contains(category);
            return AppTagChip(
              label: '#$category',
              isSelected: isSelected,
              onTap: () => setState(() {
                isSelected
                    ? _selectedCategories.remove(category)
                    : _selectedCategories.add(category);
              }),
            );
          },
        );
      },
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
