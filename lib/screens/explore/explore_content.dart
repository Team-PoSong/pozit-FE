import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_calendar.dart';
import '../../core/design_system/widgets/app_chip.dart';
import '../../core/design_system/widgets/app_filter_chip.dart';
import '../../core/design_system/widgets/app_search_bar.dart';
import '../../core/design_system/widgets/app_travel_card.dart';
import '../../core/design_system/widgets/toggle/app_region_toggle.dart';
import 'explore_filter_actions.dart';

const double _filterSheetHeightFactor = 669 / 852;
const double _horizontalPadding = 24.0;
const double _filterChipGap = 8.0;
const double _travelCardGap = 12.0;

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

class ExploreTravelItem {
  const ExploreTravelItem({
    required this.id,
    required this.title,
    required this.location,
    required this.dateText,
    required this.author,
    required this.participantCount,
    required this.tags,
    required this.region,
    required this.startDate,
    required this.endDate,
    required this.favoriteCount,
    this.isFavorite = false,
  });

  final int id;
  final String title;
  final String location;
  final String dateText;
  final String author;
  final int participantCount;
  final List<String> tags;
  final String region;
  final DateTime startDate;
  final DateTime endDate;
  final int favoriteCount;
  final bool isFavorite;
}

enum _FilterTab { region, date, category }

class _ExploreFilterResult {
  const _ExploreFilterResult({
    required this.region,
    required this.dateRange,
    required this.categories,
  });

  final String? region;
  final DateTimeRange? dateRange;
  final Set<String> categories;
}

class ExploreContent extends StatefulWidget {
  const ExploreContent({
    super.key,
    this.travels = const [],
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchTap,
    this.onRegionFilterTap,
    this.onDateFilterTap,
    this.onCategoryFilterTap,
    this.onFilterResetTap,
    this.assetPackage,
  });

  final List<ExploreTravelItem> travels;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onSearchTap;
  final VoidCallback? onRegionFilterTap;
  final VoidCallback? onDateFilterTap;
  final VoidCallback? onCategoryFilterTap;
  final VoidCallback? onFilterResetTap;
  final String? assetPackage;

  @override
  State<ExploreContent> createState() => _ExploreContentState();
}

class _ExploreContentState extends State<ExploreContent> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _showSearchError = false;
  String? _selectedRegion;
  DateTimeRange? _selectedDateRange;
  Set<String> _selectedCategories = {};
  late Set<int> _favoriteIds;

  List<ExploreTravelItem> get _travels => widget.travels;

  @override
  void initState() {
    super.initState();
    _favoriteIds = _travels
        .where((travel) => travel.isFavorite)
        .map((travel) => travel.id)
        .toSet();
  }

  @override
  void didUpdateWidget(covariant ExploreContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.travels != widget.travels) {
      _favoriteIds = _travels
          .where((travel) => travel.isFavorite)
          .map((travel) => travel.id)
          .toSet();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExploreTravelItem> get _visibleTravels {
    final hasFilter =
        _query.isNotEmpty ||
        _selectedRegion != null ||
        _selectedDateRange != null ||
        _selectedCategories.isNotEmpty;
    if (!hasFilter) return _travels;

    final filtered = _travels.where((travel) {
      final queryMatches =
          _query.isEmpty ||
          travel.title.contains(_query) ||
          travel.location.contains(_query) ||
          travel.tags.any((tag) => tag.contains(_query));
      final regionMatches =
          _selectedRegion == null || travel.region == _selectedRegion;
      final dateMatches =
          _selectedDateRange == null ||
          (!travel.endDate.isBefore(_selectedDateRange!.start) &&
              !travel.startDate.isAfter(_selectedDateRange!.end));
      final categoryMatches =
          _selectedCategories.isEmpty ||
          travel.tags.any(_selectedCategories.contains);
      return queryMatches && regionMatches && dateMatches && categoryMatches;
    }).toList();

    return filtered;
  }

  void _submitSearch([String? value]) {
    final query = (value ?? _searchController.text).trim();
    final hasError = query.isNotEmpty && query.length < 2;
    setState(() {
      _showSearchError = hasError;
      _query = hasError ? '' : query;
    });
    if (!hasError) widget.onSearchSubmitted?.call(query);
  }

  void _handleSearchChanged(String value) {
    final query = value.trim();
    final hasError = query.isNotEmpty && query.length < 2;
    setState(() {
      _showSearchError = hasError;
      _query = hasError ? '' : query;
    });
    if (!hasError) widget.onSearchChanged?.call(query);
  }

  void _resetFilters() {
    setState(() {
      _selectedRegion = null;
      _selectedDateRange = null;
      _selectedCategories = {};
    });
    widget.onFilterResetTap?.call();
  }

  Future<void> _selectRegion() async {
    final externalHandler = widget.onRegionFilterTap;
    if (externalHandler != null) {
      externalHandler();
      return;
    }
    await _showFilterSheet(_FilterTab.region);
  }

  Future<void> _selectDate() async {
    final externalHandler = widget.onDateFilterTap;
    if (externalHandler != null) {
      externalHandler();
      return;
    }
    await _showFilterSheet(_FilterTab.date);
  }

  Future<void> _selectCategories() async {
    final externalHandler = widget.onCategoryFilterTap;
    if (externalHandler != null) {
      externalHandler();
      return;
    }
    await _showFilterSheet(_FilterTab.category);
  }

  Future<void> _showFilterSheet(_FilterTab initialTab) async {
    final result = await showModalBottomSheet<_ExploreFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FractionallySizedBox(
        heightFactor: _filterSheetHeightFactor,
        child: _ExploreFilterSheet(
          initialTab: initialTab,
          selectedRegion: _selectedRegion,
          selectedDateRange: _selectedDateRange,
          selectedCategories: _selectedCategories,
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _selectedRegion = result.region;
      _selectedDateRange = result.dateRange;
      _selectedCategories = result.categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleTravels = _visibleTravels;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSearchBar(
            controller: _searchController,
            onChanged: _handleSearchChanged,
            onSubmitted: _submitSearch,
            onTap: widget.onSearchTap,
            onSearchTap: _submitSearch,
          ),
          if (_showSearchError) ...[
            const SizedBox(height: 4),
            Text(
              '두 글자 이상 검색할 수 있어요.',
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 9),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AppFilterChip(
                  label: _selectedRegion ?? '지역',
                  onTap: _selectRegion,
                  assetPackage: widget.assetPackage,
                ),
                const SizedBox(width: _filterChipGap),
                AppFilterChip(
                  label: '날짜',
                  onTap: _selectDate,
                  assetPackage: widget.assetPackage,
                ),
                const SizedBox(width: _filterChipGap),
                AppFilterChip(
                  label: _selectedCategories.isEmpty
                      ? '카테고리'
                      : '카테고리 ${_selectedCategories.length}',
                  onTap: _selectCategories,
                  assetPackage: widget.assetPackage,
                ),
                const SizedBox(width: _filterChipGap),
                AppFilterChip.icon(
                  iconAsset: AppIcons.turnBack,
                  onTap: _resetFilters,
                  assetPackage: widget.assetPackage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: visibleTravels.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: _travelCardGap),
              itemBuilder: (context, index) {
                final travel = visibleTravels[index];
                final isFavorite = _favoriteIds.contains(travel.id);
                return AppTravelCard(
                  type: AppTravelCardType.otherTravel,
                  title: travel.title,
                  location: travel.location,
                  dateText: travel.dateText,
                  author: travel.author,
                  participantCount: travel.participantCount,
                  tags: travel.tags,
                  backgroundImage: const AssetImage(AppImages.travelMockup),
                  isFavorite: isFavorite,
                  favoriteCount:
                      travel.favoriteCount +
                      (isFavorite ? 1 : 0) -
                      (travel.isFavorite ? 1 : 0),
                  onFavoriteTap: () => setState(() {
                    isFavorite
                        ? _favoriteIds.remove(travel.id)
                        : _favoriteIds.add(travel.id);
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
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

class _ExploreFilterSheet extends StatefulWidget {
  const _ExploreFilterSheet({
    required this.initialTab,
    required this.selectedRegion,
    required this.selectedDateRange,
    required this.selectedCategories,
  });

  final _FilterTab initialTab;
  final String? selectedRegion;
  final DateTimeRange? selectedDateRange;
  final Set<String> selectedCategories;

  @override
  State<_ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<_ExploreFilterSheet> {
  late _FilterTab _selectedTab = widget.initialTab;
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
                _ExploreFilterResult(
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
        final crossAxisCount = constraints.maxWidth >= 341
            ? 4
            : constraints.maxWidth >= 254
            ? 3
            : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 7,
            mainAxisSpacing: 7,
            childAspectRatio: 2,
          ),
          itemCount: _regions.length,
          itemBuilder: (context, index) {
            final region = _regions[index];
            final value = region == '전국' ? null : region;
            return AppRegionToggle(
              label: region,
              isSelected: _selectedRegion == value,
              onTap: () => setState(() => _selectedRegion = value),
            );
          },
        );
      },
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return IntrinsicWidth(
          child: AppTagChip(
            label: '#$category',
            isSelected: isSelected,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            onTap: () => setState(() {
              isSelected
                  ? _selectedCategories.remove(category)
                  : _selectedCategories.add(category);
            }),
          ),
        );
      }).toList(),
    );
  }

  void _resetSelectedTab() {
    setState(() {
      switch (_selectedTab) {
        case _FilterTab.region:
          _selectedRegion = null;
        case _FilterTab.date:
          _selectedDateRange = null;
          _calendarVersion++;
        case _FilterTab.category:
          _selectedCategories.clear();
      }
    });
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selectedTab, required this.onChanged});

  final _FilterTab selectedTab;
  final ValueChanged<_FilterTab> onChanged;

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
                  isSelected: selectedTab == _FilterTab.region,
                  onTap: () => onChanged(_FilterTab.region),
                ),
                const SizedBox(width: 12),
                _FilterTabButton(
                  label: '날짜',
                  isSelected: selectedTab == _FilterTab.date,
                  onTap: () => onChanged(_FilterTab.date),
                ),
                const SizedBox(width: 12),
                _FilterTabButton(
                  label: '카테고리',
                  isSelected: selectedTab == _FilterTab.category,
                  onTap: () => onChanged(_FilterTab.category),
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

  final _FilterTab initialTab;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.gray2,
        body: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: _filterSheetHeightFactor,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: _ExploreFilterSheet(
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

final List<ExploreTravelItem> explorePreviewTravels = [
  ExploreTravelItem(
    id: 1,
    title: '서울 여행',
    location: '서울 종로',
    dateText: '7/30 ~ 8/2 · 3박 4일',
    author: '현진',
    participantCount: 4,
    tags: ['기록', '미식'],
    region: '서울',
    startDate: DateTime(2026, 7, 30),
    endDate: DateTime(2026, 8, 2),
    favoriteCount: 12,
  ),
  ExploreTravelItem(
    id: 2,
    title: '부산 여행',
    location: '부산 해운대',
    dateText: '8/4 ~ 8/5 · 1박 2일',
    author: '성훈',
    participantCount: 3,
    tags: ['힐링', '체험'],
    region: '부산',
    startDate: DateTime(2026, 8, 4),
    endDate: DateTime(2026, 8, 5),
    favoriteCount: 8,
    isFavorite: true,
  ),
  ExploreTravelItem(
    id: 3,
    title: '제주 여행',
    location: '제주 제주',
    dateText: '8/10 ~ 8/13 · 3박 4일',
    author: '서현',
    participantCount: 6,
    tags: ['힐링', '미식'],
    region: '제주',
    startDate: DateTime(2026, 8, 10),
    endDate: DateTime(2026, 8, 13),
    favoriteCount: 15,
  ),
  ExploreTravelItem(
    id: 4,
    title: '수원 여행!!!!',
    location: '경기 수원',
    dateText: '8/15 ~ 8/16 · 1박 2일',
    author: '현영',
    participantCount: 4,
    tags: ['기록', '문화'],
    region: '경기',
    startDate: DateTime(2026, 8, 15),
    endDate: DateTime(2026, 8, 16),
    favoriteCount: 5,
  ),
  ExploreTravelItem(
    id: 5,
    title: '가평 여행!!!!!',
    location: '경기 가평',
    dateText: '8/22 ~ 8/23 · 1박 2일',
    author: '해림',
    participantCount: 7,
    tags: ['탐험', '체험'],
    region: '경기',
    startDate: DateTime(2026, 8, 22),
    endDate: DateTime(2026, 8, 23),
    favoriteCount: 10,
    isFavorite: true,
  ),
];

@Preview(group: 'haerim', name: '공개 여행 탐색')
Widget exploreContentPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SafeArea(child: ExploreContent(travels: explorePreviewTravels)),
    ),
  );
}

@Preview(group: 'haerim', name: '공개 여행 탐색 - 지역 필터', size: Size(393, 852))
Widget exploreRegionFilterPreview() =>
    const _ExploreFilterPreview(initialTab: _FilterTab.region);

@Preview(group: 'haerim', name: '공개 여행 탐색 - 날짜 필터', size: Size(393, 852))
Widget exploreDateFilterPreview() =>
    const _ExploreFilterPreview(initialTab: _FilterTab.date);

@Preview(group: 'haerim', name: '공개 여행 탐색 - 카테고리 필터', size: Size(393, 852))
Widget exploreCategoryFilterPreview() =>
    const _ExploreFilterPreview(initialTab: _FilterTab.category);
