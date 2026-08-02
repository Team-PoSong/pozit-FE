import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_filter_chip.dart';
import '../../core/design_system/widgets/app_search_bar.dart';
import '../../core/design_system/widgets/app_travel_card.dart';
import 'widgets/explore_filter_sheet.dart';

const double _horizontalPadding = 24.0;
const double _filterChipGap = 8.0;
const double _travelCardGap = 12.0;

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
    await _showFilterSheet(ExploreFilterTab.region);
  }

  Future<void> _selectDate() async {
    final externalHandler = widget.onDateFilterTap;
    if (externalHandler != null) {
      externalHandler();
      return;
    }
    await _showFilterSheet(ExploreFilterTab.date);
  }

  Future<void> _selectCategories() async {
    final externalHandler = widget.onCategoryFilterTap;
    if (externalHandler != null) {
      externalHandler();
      return;
    }
    await _showFilterSheet(ExploreFilterTab.category);
  }

  Future<void> _showFilterSheet(ExploreFilterTab initialTab) async {
    final result = await showModalBottomSheet<ExploreFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FractionallySizedBox(
        heightFactor: ExploreFilterSheet.heightFactor,
        child: ExploreFilterSheet(
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
