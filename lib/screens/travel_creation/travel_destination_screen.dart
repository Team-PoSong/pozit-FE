import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_chip.dart';
import '../../core/design_system/widgets/app_region_select.dart';
import '../../core/design_system/widgets/app_search_bar.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../core/design_system/widgets/progress/app_day_segment_bar.dart';
import '../travel_detail/widgets/travel_detail_top_bar.dart';
import 'travel_schedule_screen.dart';

typedef DestinationSearch = Future<List<String>> Function(String query);

class TravelDestinationScreen extends StatefulWidget {
  const TravelDestinationScreen({
    super.key,
    this.onSearch,
    this.onSave,
    this.onBackTap,
  });

  final DestinationSearch? onSearch;
  final ValueChanged<String>? onSave;
  final VoidCallback? onBackTap;

  @override
  State<TravelDestinationScreen> createState() =>
      _TravelDestinationScreenState();
}

class _TravelDestinationScreenState extends State<TravelDestinationScreen> {
  static const int _minimumQueryLength = 2;
  static const List<String> _sampleDestinations = ['경상북도 경주시', '경상남도 경주시'];

  final TextEditingController _searchController = TextEditingController();
  List<String> _results = const [];
  String? _selectedDestination;
  bool _showLengthError = false;
  bool _isSearching = false;
  int _requestId = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleQueryChanged(String rawQuery) async {
    final query = rawQuery.trim();
    final requestId = ++_requestId;

    if (query.isEmpty) {
      setState(() {
        _showLengthError = false;
        _results = const [];
        _selectedDestination = null;
        _isSearching = false;
      });
      return;
    }

    if (query.length < _minimumQueryLength) {
      setState(() {
        _showLengthError = true;
        _results = const [];
        _selectedDestination = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _showLengthError = false;
      _selectedDestination = null;
      _isSearching = true;
    });

    final results = widget.onSearch == null
        ? _sampleDestinations.where((item) => item.contains(query)).toList()
        : await widget.onSearch!(query);
    if (!mounted || requestId != _requestId) return;

    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  void _handleInputChanged(String value) {
    if (!_showLengthError && value.trim().isNotEmpty) return;

    setState(() {
      _showLengthError = false;
      if (value.trim().isEmpty) {
        _requestId++;
        _results = const [];
        _selectedDestination = null;
        _isSearching = false;
      }
    });
  }

  void _handleBack() {
    widget.onBackTap?.call();
    Navigator.of(context).maybePop();
  }

  void _handleSave() {
    final destination = _selectedDestination;
    if (destination == null) return;
    final onSave = widget.onSave;
    if (onSave != null) {
      onSave(destination);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TravelScheduleScreen(destination: destination),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TravelDetailTopBar(title: '여행 생성하기', onBackTap: _handleBack),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.center,
              child: AppDaySegmentBar(totalDays: 3, currentDayIndex: 0),
            ),
            const SizedBox(height: 35),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '어디로 떠나시나요?',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.text,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppSearchBar(
                controller: _searchController,
                hintText: '도시명으로 검색',
                onChanged: _handleInputChanged,
                onSubmitted: _handleQueryChanged,
                onSearchTap: () => _handleQueryChanged(_searchController.text),
              ),
            ),
            if (_showLengthError) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '두 글자 이상 검색할 수 있어요.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _results.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final destination = _results[index];
                        return AppRegionSelect(
                          label: destination,
                          isSelected: _selectedDestination == destination,
                          onChanged: (_) {
                            setState(() => _selectedDestination = destination);
                          },
                        );
                      },
                    ),
            ),
            if (_selectedDestination != null) ...[
              SizedBox(
                height: 29,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppDeletableChip(
                      label: _selectedDestination!,
                      onDeleted: () {
                        setState(() => _selectedDestination = null);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 17),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                0,
                24,
                AppDimensions.screenBottomPadding,
              ),
              child: AppButton(
                text: '다음',
                isEnabled: _selectedDestination != null,
                onPressed: _handleSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Travel Destination', size: Size(393, 852))
Widget travelDestinationScreenPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(393, 852),
        padding: EdgeInsets.only(top: 59, bottom: 34),
      ),
      child: TravelDestinationScreen(),
    ),
  );
}
