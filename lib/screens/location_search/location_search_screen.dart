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
import '../../data/models/tourist_spot_rank_model.dart';
import '../../data/models/tourist_spot_search_result_model.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';

const double _kHorizontalPadding = 24.0;

const double _kTopBarToSearchBarGap = 33.0;
const double _kSearchBarToErrorGap = 4.0;
const double _kSearchBarToLabelGap = 24.0;
const double _kLabelToListGap = 24.0;
const double _kLocationGap = 8.0;
const double _kEmptyImageSize = 160.0;
const double _kEmptyImageToTextGap = 16.0;
const double _kChipsToButtonGap = 17.0;
const double _kChipGap = 5.0;
const int _kMinQueryLength = 2;

const int _kEmptyResultTopFlex = 157;
const int _kEmptyResultBottomFlex = 184;

const double _kLoadMoreScrollThreshold = 200.0;
const int _kInitialPopularSpotsCursor = 1;
const int _kInitialSearchCursor = 1;

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({
    super.key,
    this.onLoadPopularSpots,
    this.onSearch,
    this.onAddSelectedSpots,
    this.onBackTap,
  });

  /// 인기 있는 장소 목록을 커서 기반으로 불러옵니다. 첫 호출은 커서 1로 합니다.
  final Future<TouristSpotRankPage> Function(int cursor)? onLoadPopularSpots;

  /// 키워드로 관광지를 커서 기반으로 검색합니다. 첫 호출은 커서 1로 합니다.
  final Future<TouristSpotSearchPage> Function(String keyword, int cursor)?
  onSearch;

  /// 검색 결과에서 선택한 장소를 실제 Pozit 장소로 저장하고, 코스에 쓸 수
  /// 있는 형태(TouristSpotModel)로 돌려줍니다.
  final Future<List<TouristSpotModel>> Function(
    List<TouristSpotSearchResultModel> selected,
  )?
  onAddSelectedSpots;

  final VoidCallback? onBackTap;

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _popularScrollController = ScrollController();
  final ScrollController _searchScrollController = ScrollController();
  final Map<String, TouristSpotSearchResultModel> _searchResultByContentId = {};
  final Set<String> _selectedContentIds = {};

  List<TouristSpotSearchResultModel> _searchResults = [];
  int? _nextSearchCursor = _kInitialSearchCursor;
  bool _hasNextSearchPage = false;
  bool _isLoadingMoreSearch = false;
  bool _hasSearched = false;
  bool _showLengthError = false;
  bool _isSearching = false;
  bool _hasSearchError = false;
  bool _isAddingSpots = false;
  int _searchRequestId = 0;

  List<TouristSpotRankModel> _popularSpots = [];
  int? _nextPopularCursor = _kInitialPopularSpotsCursor;
  bool _hasNextPopularPage = false;
  bool _isLoadingPopular = false;
  bool _isLoadingMorePopular = false;
  bool _hasPopularError = false;
  final Map<int, TouristSpotRankModel> _popularSpotById = {};
  final Set<int> _selectedPopularSpotIds = {};

  List<TouristSpotSearchResultModel> get _selectedSearchResults =>
      _selectedContentIds.map((id) => _searchResultByContentId[id]!).toList();

  /// 인기 있는 장소는 이미 Pozit에 등록된 관광지라서, 검색 결과와 달리
  /// 별도로 저장할 필요 없이 바로 코스에 추가할 수 있습니다.
  List<TouristSpotRankModel> get _selectedPopularSpots => _selectedPopularSpotIds
      .map((id) => _popularSpotById[id]!)
      .toList();

  @override
  void initState() {
    super.initState();
    _popularScrollController.addListener(_handlePopularScroll);
    _searchScrollController.addListener(_handleSearchScroll);
    _loadPopularSpots();
  }

  @override
  void dispose() {
    _controller.dispose();
    _popularScrollController.dispose();
    _searchScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPopularSpots() async {
    if (widget.onLoadPopularSpots == null) return;

    setState(() {
      _isLoadingPopular = true;
      _hasPopularError = false;
    });

    try {
      final page = await widget.onLoadPopularSpots!(
        _kInitialPopularSpotsCursor,
      );
      if (!mounted) return;
      setState(() {
        _popularSpots = page.ranks;
        for (final spot in page.ranks) {
          _popularSpotById[spot.touristSpotId] = spot;
        }
        _nextPopularCursor = page.nextCursor;
        _hasNextPopularPage = page.hasNext;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasPopularError = true);
    } finally {
      if (mounted) setState(() => _isLoadingPopular = false);
    }
  }

  Future<void> _loadMorePopularSpots() async {
    final cursor = _nextPopularCursor;
    if (widget.onLoadPopularSpots == null ||
        _isLoadingMorePopular ||
        !_hasNextPopularPage ||
        cursor == null) {
      return;
    }

    setState(() => _isLoadingMorePopular = true);
    try {
      final page = await widget.onLoadPopularSpots!(cursor);
      if (!mounted) return;
      setState(() {
        _popularSpots = [..._popularSpots, ...page.ranks];
        for (final spot in page.ranks) {
          _popularSpotById[spot.touristSpotId] = spot;
        }
        _nextPopularCursor = page.nextCursor;
        _hasNextPopularPage = page.hasNext;
      });
    } catch (_) {
      // 다음 페이지 로드 실패는 조용히 무시합니다. 스크롤하면 다시 시도됩니다.
    } finally {
      if (mounted) setState(() => _isLoadingMorePopular = false);
    }
  }

  void _handlePopularScroll() {
    if (!_popularScrollController.hasClients) return;
    final position = _popularScrollController.position;
    if (position.pixels >= position.maxScrollExtent - _kLoadMoreScrollThreshold) {
      _loadMorePopularSpots();
    }
  }

  Widget _buildPopularSpotsSection() {
    if (_isLoadingPopular) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasPopularError) {
      return _SearchError(onRetry: _loadPopularSpots);
    }
    if (_popularSpots.isEmpty) {
      return const _EmptyResult();
    }

    return ListView.separated(
      controller: _popularScrollController,
      padding: const EdgeInsets.fromLTRB(
        _kHorizontalPadding,
        0,
        _kHorizontalPadding,
        _kLocationGap,
      ),
      itemCount: _popularSpots.length + (_isLoadingMorePopular ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: _kLocationGap),
      itemBuilder: (context, index) {
        if (index >= _popularSpots.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final spot = _popularSpots[index];
        return AppLocationSelect(
          key: ValueKey(spot.touristSpotId),
          title: spot.title,
          address: spot.address,
          isSelected: _selectedPopularSpotIds.contains(spot.touristSpotId),
          onChanged: (selected) =>
              _handlePopularSpotSelectedChanged(spot, selected),
        );
      },
    );
  }

  void _handlePopularSpotSelectedChanged(
    TouristSpotRankModel spot,
    bool selected,
  ) {
    setState(() {
      _popularSpotById[spot.touristSpotId] = spot;
      if (selected) {
        _selectedPopularSpotIds.add(spot.touristSpotId);
      } else {
        _selectedPopularSpotIds.remove(spot.touristSpotId);
      }
    });
  }

  Future<void> _handleSearch(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.length < _kMinQueryLength) {
      setState(() {
        _showLengthError = true;
        _hasSearchError = false;
      });
      return;
    }

    final requestId = ++_searchRequestId;

    setState(() {
      _showLengthError = false;
      _hasSearchError = false;
      _isSearching = true;
    });

    try {
      final page = await widget.onSearch?.call(query, _kInitialSearchCursor);
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _hasSearched = true;
        _searchResults = page?.places ?? const [];
        _nextSearchCursor = page?.nextCursor;
        _hasNextSearchPage = page?.hasNext ?? false;
        for (final spot in _searchResults) {
          _searchResultByContentId[spot.contentId] = spot;
        }
      });
    } catch (_) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() => _hasSearchError = true);
    } finally {
      if (mounted && requestId == _searchRequestId) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _loadMoreSearchResults() async {
    final cursor = _nextSearchCursor;
    if (widget.onSearch == null ||
        _isLoadingMoreSearch ||
        !_hasNextSearchPage ||
        cursor == null) {
      return;
    }

    final requestId = _searchRequestId;
    setState(() => _isLoadingMoreSearch = true);
    try {
      final page = await widget.onSearch!(_controller.text.trim(), cursor);
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _searchResults = [..._searchResults, ...page.places];
        _nextSearchCursor = page.nextCursor;
        _hasNextSearchPage = page.hasNext;
        for (final spot in page.places) {
          _searchResultByContentId[spot.contentId] = spot;
        }
      });
    } catch (_) {
      // 다음 페이지 로드 실패는 조용히 무시합니다. 스크롤하면 다시 시도됩니다.
    } finally {
      if (mounted && requestId == _searchRequestId) {
        setState(() => _isLoadingMoreSearch = false);
      }
    }
  }

  void _handleSearchScroll() {
    if (!_searchScrollController.hasClients) return;
    final position = _searchScrollController.position;
    if (position.pixels >= position.maxScrollExtent - _kLoadMoreScrollThreshold) {
      _loadMoreSearchResults();
    }
  }

  void _handleQueryChanged(String value) {
    if (value.trim().isNotEmpty) return;
    setState(() {
      _hasSearched = false;
      _searchResults = [];
      _showLengthError = false;
      _hasSearchError = false;
    });
  }

  void _handleSpotSelectedChanged(
    TouristSpotSearchResultModel spot,
    bool selected,
  ) {
    setState(() {
      _searchResultByContentId[spot.contentId] = spot;
      if (selected) {
        _selectedContentIds.add(spot.contentId);
      } else {
        _selectedContentIds.remove(spot.contentId);
      }
    });
  }

  Future<void> _handleAddTap() async {
    final selectedPopular = _selectedPopularSpots;
    final selectedSearch = _selectedSearchResults;
    if (selectedPopular.isEmpty && selectedSearch.isEmpty) return;

    setState(() => _isAddingSpots = true);
    try {
      // 인기 있는 장소는 이미 등록된 관광지라서 별도 저장 API 없이 그대로
      // 코스에 추가합니다. 검색 결과만 saveSelectedSpots로 저장이 필요합니다.
      final popularAsSpots = [
        for (final spot in selectedPopular)
          TouristSpotModel(
            touristSpotId: spot.touristSpotId,
            name: spot.title,
            address: spot.address,
            latitude: spot.latitude,
            longitude: spot.longitude,
          ),
      ];
      final savedSearchSpots = selectedSearch.isEmpty
          ? const <TouristSpotModel>[]
          : await widget.onAddSelectedSpots!(selectedSearch);

      if (!mounted) return;
      Navigator.of(context).pop([...popularAsSpots, ...savedSearchSpots]);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isAddingSpots = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택한 장소를 추가하지 못했어요. 다시 시도해주세요.')),
      );
    }
  }

  void _handleBack() {
    widget.onBackTap?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEmptyResult =
        _showLengthError || (_hasSearched && _searchResults.isEmpty);
    final selectedChips = [
      for (final spot in _selectedPopularSpots)
        (
          key: 'rank-${spot.touristSpotId}',
          label: spot.title,
          onRemove: () => _handlePopularSpotSelectedChanged(spot, false),
        ),
      for (final spot in _selectedSearchResults)
        (
          key: 'search-${spot.contentId}',
          label: spot.title,
          onRemove: () => _handleSpotSelectedChanged(spot, false),
        ),
    ];

    return Scaffold(
      backgroundColor: AppColors.white,

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
            if (!_hasSearched &&
                !_showLengthError &&
                !_isSearching &&
                !_hasSearchError) ...[
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
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _hasSearchError
                  ? _SearchError(onRetry: () => _handleSearch(_controller.text))
                  : isEmptyResult
                  ? const _EmptyResult()
                  : _hasSearched
                  ? ListView.separated(
                      controller: _searchScrollController,
                      padding: const EdgeInsets.fromLTRB(
                        _kHorizontalPadding,
                        0,
                        _kHorizontalPadding,
                        _kLocationGap,
                      ),
                      itemCount:
                          _searchResults.length +
                          (_isLoadingMoreSearch ? 1 : 0),
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: _kLocationGap),
                      itemBuilder: (context, index) {
                        if (index >= _searchResults.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final spot = _searchResults[index];
                        return AppLocationSelect(
                          key: ValueKey(spot.contentId),
                          title: spot.title,
                          address: spot.address,
                          isSelected: _selectedContentIds.contains(
                            spot.contentId,
                          ),
                          onChanged: (selected) =>
                              _handleSpotSelectedChanged(spot, selected),
                        );
                      },
                    )
                  : _buildPopularSpotsSection(),
            ),
            if (selectedChips.isNotEmpty) ...[
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
                        for (var i = 0; i < selectedChips.length; i++) ...[
                          if (i > 0) const SizedBox(width: _kChipGap),
                          AppDeletableChip(
                            key: ValueKey(selectedChips[i].key),
                            label: selectedChips[i].label,
                            onDeleted: selectedChips[i].onRemove,
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
                text: _isAddingSpots ? '추가하는 중...' : '장소 추가하기',
                isEnabled: selectedChips.isNotEmpty && !_isAddingSpots,
                onPressed: _handleAddTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  const _SearchError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(flex: _kEmptyResultTopFlex, child: SizedBox()),
          Text(
            '검색에 실패했어요. 잠시 후 다시 시도해주세요.',
            style: AppTextStyles.subTitle.copyWith(color: AppColors.gray5),
          ),
          const SizedBox(height: _kEmptyImageToTextGap),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              '다시 시도',
              style: AppTextStyles.body.copyWith(
                color: AppColors.text,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const Expanded(flex: _kEmptyResultBottomFlex, child: SizedBox()),
        ],
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

List<TouristSpotSearchResultModel> _previewSearchResults() {
  return const [
    TouristSpotSearchResultModel(
      contentId: '1',
      contentTypeId: '12',
      title: '첨성대',
      address: '경북 경주시 인왕동 839-1',
      latitude: 35.8347,
      longitude: 129.2194,
    ),
    TouristSpotSearchResultModel(
      contentId: '2',
      contentTypeId: '12',
      title: '동궁과 월지',
      address: '경북 경주시 원화로 102',
      latitude: 35.8347,
      longitude: 129.2247,
    ),
    TouristSpotSearchResultModel(
      contentId: '3',
      contentTypeId: '12',
      title: '대릉원',
      address: '경북 경주시 계림로 9',
      latitude: 35.8351,
      longitude: 129.2118,
    ),
  ];
}

Future<TouristSpotRankPage> _previewLoadPopularSpots(int cursor) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return TouristSpotRankPage(
    ranks: const [
      TouristSpotRankModel(
        rank: 1,
        touristSpotId: 1,
        title: '첨성대',
        address: '경북 경주시 인왕동 839-1',
        courseSpotCount: 42,
      ),
      TouristSpotRankModel(
        rank: 2,
        touristSpotId: 2,
        title: '동궁과 월지',
        address: '경북 경주시 원화로 102',
        courseSpotCount: 31,
      ),
      TouristSpotRankModel(
        rank: 3,
        touristSpotId: 3,
        title: '대릉원',
        address: '경북 경주시 계림로 9',
        courseSpotCount: 20,
      ),
    ],
    currentCursor: cursor,
    nextCursor: null,
    hasNext: false,
  );
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
      onLoadPopularSpots: _previewLoadPopularSpots,
      onSearch: (keyword, cursor) async {
        await Future.delayed(const Duration(milliseconds: 300));
        final matched = _previewSearchResults()
            .where((spot) => spot.title.contains(keyword))
            .toList();
        return TouristSpotSearchPage(
          places: matched,
          currentCursor: cursor,
          nextCursor: null,
          hasNext: false,
        );
      },
      onAddSelectedSpots: (selected) async {
        await Future.delayed(const Duration(milliseconds: 300));
        return selected
            .map(
              (spot) => TouristSpotModel(
                touristSpotId: int.parse(spot.contentId),
                name: spot.title,
                address: spot.address,
                latitude: spot.latitude,
                longitude: spot.longitude,
              ),
            )
            .toList();
      },
    ),
  );
}
