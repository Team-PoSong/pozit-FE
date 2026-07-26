import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_chip.dart';
import '../../core/design_system/widgets/app_location_select.dart';
import '../../core/design_system/widgets/app_search_bar.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../data/models/tourist_spot_model.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';

const double _kHorizontalPadding = 24.0;
const double _kTopBarToSearchBarGap = 41.0;
const double _kSearchBarToErrorGap = 11.0;
const double _kSearchBarToLabelGap = 46.0;
const double _kLabelToListGap = 24.0;
const double _kLocationGap = 11.0;
const double _kEmptyImageSize = 160.0;
const double _kEmptyImageToTextGap = 16.0;
const double _kChipsToButtonGap = 17.0;
const double _kChipGap = 5.0;
const int _kMinQueryLength = 2;
const double _kSearchBarVerticalPadding = 12.0;

// 빈 결과 이미지/텍스트는 검색 바~버튼 사이 빈 공간을 이 비율(157:184)로
// 나눠서 위아래 여백을 잡습니다. 화면 높이가 달라져도 같은 비율을 유지하기
// 위해 고정 픽셀 대신 flex로 배치합니다.
const int _kEmptyResultTopFlex = 157;
const int _kEmptyResultBottomFlex = 184;

/// 코스 수정 화면의 '+' 플로팅 버튼에서 진입하는 장소 검색 화면입니다.
///
/// 검색어가 없으면 [popularSpots](지금 인기 있는 장소)를, 두 글자 이상으로
/// 검색하면 [onSearch] 결과를 보여줍니다. 여러 장소를 선택해 한 번에
/// '장소 추가하기'로 넘길 수 있고, 누르는 즉시 선택된 장소 목록을 들고
/// 이전 화면으로 돌아갑니다.
class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({
    super.key,
    this.popularSpots = const [],
    this.recentSearches = const [],
    this.onSearch,
    this.onRecentSearchDeleted,
    this.onBackTap,
  });

  final List<TouristSpotModel> popularSpots;
  final List<String> recentSearches;

  /// 두 글자 이상인 검색어로 호출됩니다. 실제 검색(서버 조회)은 호출하는
  /// 쪽의 몫입니다.
  final Future<List<TouristSpotModel>> Function(String query)? onSearch;

  /// 최근 검색어 칩의 x를 눌렀을 때 호출됩니다.
  final ValueChanged<String>? onRecentSearchDeleted;
  final VoidCallback? onBackTap;

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  late final List<String> _recentSearches = List.of(widget.recentSearches);
  final Map<int, TouristSpotModel> _spotById = {};
  final Set<int> _selectedIds = {};

  List<TouristSpotModel> _searchResults = [];
  bool _hasSearched = false;
  bool _showLengthError = false;

  @override
  void initState() {
    super.initState();
    for (final spot in widget.popularSpots) {
      _spotById[spot.touristSpotId] = spot;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSearch(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.length < _kMinQueryLength) {
      setState(() => _showLengthError = true);
      return;
    }

    final results = await widget.onSearch?.call(query) ?? const [];
    if (!mounted) return;
    setState(() {
      _showLengthError = false;
      _hasSearched = true;
      _searchResults = results;
      for (final spot in results) {
        _spotById[spot.touristSpotId] = spot;
      }
    });
  }

  void _handleQueryChanged(String value) {
    if (value.trim().isNotEmpty) return;
    setState(() {
      _hasSearched = false;
      _searchResults = [];
      _showLengthError = false;
    });
  }

  void _handleSpotSelectedChanged(TouristSpotModel spot, bool selected) {
    setState(() {
      _spotById[spot.touristSpotId] = spot;
      if (selected) {
        _selectedIds.add(spot.touristSpotId);
      } else {
        _selectedIds.remove(spot.touristSpotId);
      }
    });
  }

  void _handleDeleteRecentSearch(String keyword) {
    setState(() => _recentSearches.remove(keyword));
    widget.onRecentSearchDeleted?.call(keyword);
  }

  void _handleAddTap() {
    final selected = _selectedIds.map((id) => _spotById[id]!).toList();
    Navigator.of(context).pop(selected);
  }

  void _handleBack() {
    widget.onBackTap?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final displayedSpots = _hasSearched ? _searchResults : widget.popularSpots;
    final isEmptyResult = _hasSearched && displayedSpots.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      // 최근 검색어·버튼이 화면 하단에 고정되어야 해서, 키보드가 올라와도
      // 본문이 눌려 올라가지 않도록 합니다.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TravelDetailTopBar(title: '장소 검색', onBackTap: _handleBack),
            const SizedBox(height: _kTopBarToSearchBarGap),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kHorizontalPadding,
              ),
              child: AppSearchBar(
                controller: _controller,
                hintText: '장소명을 검색해주세요.',
                verticalPadding: _kSearchBarVerticalPadding,
                onChanged: _handleQueryChanged,
                onSubmitted: _handleSearch,
                onSearchTap: () => _handleSearch(_controller.text),
              ),
            ),
            const SizedBox(height: _kSearchBarToErrorGap),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kHorizontalPadding,
              ),
              // 워닝이 뜨고 사라질 때 아래 요소들이 밀리지 않도록, 보이지
              // 않을 때도 같은 높이를 그대로 차지하게 둡니다.
              child: Visibility(
                visible: _showLengthError,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Text(
                  '두 글자 이상 검색할 수 있어요.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ),
            ),
            const SizedBox(height: _kSearchBarToLabelGap),
            if (!_hasSearched) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _kHorizontalPadding,
                ),
                child: Text(
                  '지금 인기 있는 장소',
                  style: AppTextStyles.headline.copyWith(color: AppColors.text),
                ),
              ),
              const SizedBox(height: _kLabelToListGap),
            ],
            Expanded(
              child: isEmptyResult
                  ? const _EmptyResult()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _kHorizontalPadding,
                      ),
                      itemCount: displayedSpots.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: _kLocationGap),
                      itemBuilder: (context, index) {
                        final spot = displayedSpots[index];
                        return AppLocationSelect(
                          key: ValueKey(spot.touristSpotId),
                          title: spot.name,
                          address: spot.address,
                          isSelected: _selectedIds.contains(spot.touristSpotId),
                          onChanged: (selected) =>
                              _handleSpotSelectedChanged(spot, selected),
                        );
                      },
                    ),
            ),
            if (_recentSearches.isNotEmpty) ...[
              SizedBox(
                height: 29,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kHorizontalPadding,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < _recentSearches.length; i++) ...[
                          if (i > 0) const SizedBox(width: _kChipGap),
                          AppDeletableChip(
                            label: _recentSearches[i],
                            onDeleted: () =>
                                _handleDeleteRecentSearch(_recentSearches[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: _kChipsToButtonGap),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kHorizontalPadding,
              ),
              child: AppButton(
                text: '장소 추가하기',
                isEnabled: _selectedIds.isNotEmpty,
                onPressed: _handleAddTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(flex: _kEmptyResultTopFlex, child: SizedBox()),
          Image.asset(
            AppImages.pin,
            width: _kEmptyImageSize,
            height: _kEmptyImageSize,
          ),
          const SizedBox(height: _kEmptyImageToTextGap),
          Text(
            '검색 결과가 없어요.',
            style: AppTextStyles.subTitle.copyWith(color: AppColors.gray5),
          ),
          const Expanded(flex: _kEmptyResultBottomFlex, child: SizedBox()),
        ],
      ),
    );
  }
}

List<TouristSpotModel> _previewPopularSpots() {
  return const [
    TouristSpotModel(
      touristSpotId: 1,
      name: '첨성대',
      address: '경북 경주시 인왕동 839-1',
      latitude: 35.8347,
      longitude: 129.2194,
    ),
    TouristSpotModel(
      touristSpotId: 2,
      name: '동궁과 월지',
      address: '경북 경주시 원화로 102',
      latitude: 35.8347,
      longitude: 129.2247,
    ),
    TouristSpotModel(
      touristSpotId: 3,
      name: '대릉원',
      address: '경북 경주시 계림로 9',
      latitude: 35.8351,
      longitude: 129.2118,
    ),
  ];
}

@Preview(
  group: 'location_search',
  name: 'LocationSearchScreen',
  size: Size(390, 844),
)
Widget locationSearchScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LocationSearchScreen(
      popularSpots: _previewPopularSpots(),
      recentSearches: const ['경주월드', '불국사'],
      onSearch: (query) async {
        await Future.delayed(const Duration(milliseconds: 300));
        return _previewPopularSpots()
            .where((spot) => spot.name.contains(query))
            .toList();
      },
    ),
  );
}
