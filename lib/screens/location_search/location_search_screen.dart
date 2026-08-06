import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_chip.dart';
import '../../core/design_system/widgets/app_location.dart';
import '../../core/design_system/widgets/app_location_select.dart';
import '../../core/design_system/widgets/app_search_bar.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../data/models/tourist_spot_model.dart';
import '../../data/models/tourist_spot_rank_model.dart';
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

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({
    super.key,
    this.onLoadPopularSpots,
    this.onSearch,
    this.onBackTap,
  });

  /// 인기 있는 장소 목록을 커서 기반으로 불러옵니다. 첫 호출은 커서 1로 합니다.
  final Future<TouristSpotRankPage> Function(int cursor)? onLoadPopularSpots;

  final Future<List<TouristSpotModel>> Function(String query)? onSearch;

  final VoidCallback? onBackTap;

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _popularScrollController = ScrollController();
  final Map<int, TouristSpotModel> _spotById = {};
  final Set<int> _selectedIds = {};

  List<TouristSpotModel> _searchResults = [];
  bool _hasSearched = false;
  bool _showLengthError = false;
  bool _isSearching = false;
  bool _hasSearchError = false;
  int _searchRequestId = 0;

  List<TouristSpotRankModel> _popularSpots = [];
  int? _nextPopularCursor = _kInitialPopularSpotsCursor;
  bool _hasNextPopularPage = false;
  bool _isLoadingPopular = false;
  bool _isLoadingMorePopular = false;
  bool _hasPopularError = false;

  List<TouristSpotModel> get _selectedSpots =>
      _selectedIds.map((id) => _spotById[id]!).toList();

  @override
  void initState() {
    super.initState();
    _popularScrollController.addListener(_handlePopularScroll);
    _loadPopularSpots();
  }

  @override
  void dispose() {
    _controller.dispose();
    _popularScrollController.dispose();
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
        return AppLocation(
          key: ValueKey(spot.touristSpotId),
          name: spot.title,
          address: spot.address,
        );
      },
    );
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
      final results = await widget.onSearch?.call(query) ?? const [];
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _hasSearched = true;
        _searchResults = results;
        for (final spot in results) {
          _spotById[spot.touristSpotId] = spot;
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

  void _handleQueryChanged(String value) {
    if (value.trim().isNotEmpty) return;
    setState(() {
      _hasSearched = false;
      _searchResults = [];
      _showLengthError = false;
      _hasSearchError = false;
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
    final isEmptyResult =
        _showLengthError || (_hasSearched && _searchResults.isEmpty);
    final selectedSpots = _selectedSpots;

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
                      padding: const EdgeInsets.fromLTRB(
                        _kHorizontalPadding,
                        0,
                        _kHorizontalPadding,
                        _kLocationGap,
                      ),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: _kLocationGap),
                      itemBuilder: (context, index) {
                        final spot = _searchResults[index];
                        return AppLocationSelect(
                          key: ValueKey(spot.touristSpotId),
                          title: spot.name,
                          address: spot.address,
                          isSelected: _selectedIds.contains(spot.touristSpotId),
                          onChanged: (selected) =>
                              _handleSpotSelectedChanged(spot, selected),
                        );
                      },
                    )
                  : _buildPopularSpotsSection(),
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
      onSearch: (query) async {
        await Future.delayed(const Duration(milliseconds: 300));
        return _previewPopularSpots()
            .where((spot) => spot.name.contains(query))
            .toList();
      },
    ),
  );
}
