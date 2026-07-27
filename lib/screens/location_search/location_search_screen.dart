import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
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
const double _kSearchBarToErrorGap = 10.0;
const double _kSearchBarToLabelGap = 24.0;
const double _kLabelToListGap = 24.0;
const double _kLocationGap = 8.0;
const double _kEmptyImageSize = 160.0;
const double _kEmptyImageToTextGap = 16.0;
const double _kChipsToButtonGap = 17.0;
const double _kChipGap = 5.0;
const int _kMinQueryLength = 2;

// 빈 결과 이미지/텍스트는 검색 바~버튼 사이 빈 공간을 이 비율(157:184)로
// 나눠서 위아래 여백을 잡습니다. 화면 높이가 달라져도 같은 비율을 유지하기
// 위해 고정 픽셀 대신 flex로 배치합니다.
const int _kEmptyResultTopFlex = 157;
const int _kEmptyResultBottomFlex = 184;

/// 코스 수정 화면의 '+' 플로팅 버튼에서 진입하는 장소 검색 화면입니다.
///
/// 검색어가 없으면 [popularSpots](지금 인기 있는 장소)를, 두 글자 이상으로
/// 검색하면 [onSearch] 결과를 보여줍니다. 여러 장소를 선택하면 버튼 위에
/// 선택된 장소들이 칩으로 나열되고, '장소 추가하기'를 누르면 그 장소들을
/// 들고 즉시 이전 화면으로 돌아갑니다.
class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({
    super.key,
    this.popularSpots = const [],
    this.onSearch,
    this.onBackTap,
  });

  final List<TouristSpotModel> popularSpots;

  /// 두 글자 이상인 검색어로 호출됩니다. 실제 검색(서버 조회)은 호출하는
  /// 쪽의 몫입니다.
  final Future<List<TouristSpotModel>> Function(String query)? onSearch;

  final VoidCallback? onBackTap;

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final Map<int, TouristSpotModel> _spotById = {};
  final Set<int> _selectedIds = {};

  List<TouristSpotModel> _searchResults = [];
  bool _hasSearched = false;
  bool _showLengthError = false;

  /// 지금까지 선택한 장소들입니다(선택한 순서 그대로). '장소 추가하기' 버튼
  /// 위 칩 목록과, 실제로 추가될 장소 목록에 그대로 쓰입니다.
  List<TouristSpotModel> get _selectedSpots =>
      _selectedIds.map((id) => _spotById[id]!).toList();

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

  void _handleAddTap() {
    Navigator.of(context).pop(_selectedSpots);
  }

  void _handleBack() {
    widget.onBackTap?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final displayedSpots = _hasSearched ? _searchResults : widget.popularSpots;
    // 두 글자 미만 경고가 떠 있을 때도 검색 결과가 없는 것과 같은 화면을
    // 보여줍니다('지금 인기 있는 장소' 대신 '검색 결과가 없어요').
    final isEmptyResult =
        _showLengthError || (_hasSearched && displayedSpots.isEmpty);
    final selectedSpots = _selectedSpots;

    return Scaffold(
      backgroundColor: AppColors.white,
      // 선택된 장소 칩·버튼이 화면 하단에 고정되어야 해서, 키보드가 올라와도
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
              // 경고 문구는 검색 바 아래에 떠 있는 형태라, 뜨고 사라져도
              // 검색 바~다음 요소 사이 간격(_kSearchBarToLabelGap)이 항상
              // 그대로 유지됩니다. 문구가 정확히 그 간격 안에 들어오도록
              // (검색 바~문구 _kSearchBarToErrorGap + 문구 한 줄 높이 14 =
              // _kSearchBarToLabelGap) 배치합니다.
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AppSearchBar(
                    controller: _controller,
                    hintText: '장소명을 검색해주세요.',
                    onChanged: _handleQueryChanged,
                    onSubmitted: _handleSearch,
                    onSearchTap: () => _handleSearch(_controller.text),
                  ),
                  if (_showLengthError)
                    Positioned(
                      top:
                          AppDimensions.inputMinHeight +
                          _kSearchBarToErrorGap,
                      left: 0,
                      right: 0,
                      child: Text(
                        '두 글자 이상 검색할 수 있어요.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: _kSearchBarToLabelGap),
            if (!_hasSearched && !_showLengthError) ...[
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
            if (selectedSpots.isNotEmpty) ...[
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
                        for (var i = 0; i < selectedSpots.length; i++) ...[
                          if (i > 0) const SizedBox(width: _kChipGap),
                          AppDeletableChip(
                            key: ValueKey(selectedSpots[i].touristSpotId),
                            label: selectedSpots[i].name,
                            onDeleted: () => _handleSpotSelectedChanged(
                              selectedSpots[i],
                              false,
                            ),
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
              padding: const EdgeInsets.fromLTRB(
                _kHorizontalPadding,
                0,
                _kHorizontalPadding,
                AppDimensions.screenBottomPadding,
              ),
              child: AppButton(
                text: '장소 추가하기',
                isEnabled: selectedSpots.isNotEmpty,
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
      onSearch: (query) async {
        await Future.delayed(const Duration(milliseconds: 300));
        return _previewPopularSpots()
            .where((spot) => spot.name.contains(query))
            .toList();
      },
    ),
  );
}
