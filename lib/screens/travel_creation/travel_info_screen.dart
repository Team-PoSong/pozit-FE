import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_text_styles.dart';
import '../../core/design_system/widgets/app_input_field.dart';
import '../../core/design_system/widgets/app_travel_tag_grid.dart';
import '../../core/design_system/widgets/button/app_button.dart';
import '../../data/models/travel/travel_course_model.dart';
import '../../data/models/travel/travel_tag_model.dart';
import '../../data/repositories/travel/travel_repository.dart';
import 'travel_course_creation_screen.dart';
import 'travel_creation_data.dart';
import 'travel_creation_pipeline.dart';
import 'widgets/travel_creation_header.dart';
import 'travel_preferences_screen.dart';

class TravelInfoScreen extends StatefulWidget {
  const TravelInfoScreen({
    super.key,
    required this.destination,
    this.regionCode,
    required this.dateRange,
    this.onSave,
    this.onBackTap,
    this.creationMethod = TravelCreationMethod.create,
    this.initialCourses = const [],
    this.initialTags = const [],
    this.initialTagIds = const [],
    this.sourceTravelId,
    this.backgroundImageUrl,
    this.repository = const TravelRepository(),
  });

  final String destination;
  final String? regionCode;
  final DateTimeRange dateRange;
  final ValueChanged<TravelInfoResult>? onSave;
  final VoidCallback? onBackTap;
  final TravelCreationMethod creationMethod;
  final List<TravelCourseModel> initialCourses;
  final List<String> initialTags;
  final List<int> initialTagIds;
  final int? sourceTravelId;
  final String? backgroundImageUrl;
  final TravelRepository repository;

  @override
  State<TravelInfoScreen> createState() => _TravelInfoScreenState();
}

class _TravelInfoScreenState extends State<TravelInfoScreen> {
  static const int _maximumTagCount = 2;
  final TextEditingController _nameController = TextEditingController();
  late final Set<String> _selectedTags;
  late final Set<int> _selectedTagIds;
  List<TravelTagModel> _availableTags = const [];
  bool _isLoadingTags = false;
  bool _hasTagLoadError = false;

  @override
  void initState() {
    super.initState();
    _selectedTags = widget.initialTags.take(_maximumTagCount).toSet();
    _selectedTagIds = widget.initialTagIds.take(_maximumTagCount).toSet();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      _isLoadingTags = true;
      _hasTagLoadError = false;
    });
    try {
      final tags = await widget.repository.getTags();
      if (!mounted) return;
      setState(() {
        _availableTags = tags;
        if (_selectedTagIds.isNotEmpty) {
          _selectedTags
            ..clear()
            ..addAll(
              tags
                  .where((tag) => _selectedTagIds.contains(tag.id))
                  .map((tag) => tag.name)
                  .take(_maximumTagCount),
            );
        }
      });
    } catch (_) {
      if (mounted) setState(() => _hasTagLoadError = true);
    } finally {
      if (mounted) setState(() => _isLoadingTags = false);
    }
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty && _selectedTags.isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleTagTap(String tag) {
    setState(() {
      final tagId = _availableTags
          .where((item) => item.name == tag)
          .map((item) => item.id)
          .firstOrNull;
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
        if (tagId != null) _selectedTagIds.remove(tagId);
      } else if (_selectedTags.length < _maximumTagCount) {
        _selectedTags.add(tag);
        if (tagId != null) _selectedTagIds.add(tagId);
      }
    });
  }

  void _handleBack() {
    final onBackTap = widget.onBackTap;
    if (onBackTap != null) {
      onBackTap();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _handleSave() {
    if (!_canSave) return;
    final result = TravelInfoResult(
      destination: widget.destination,
      regionCode: widget.regionCode,
      dateRange: widget.dateRange,
      name: _nameController.text.trim(),
      tags: Set.unmodifiable(_selectedTags),
      tagIds: _selectedTagIds.toList(),
      creationMethod: widget.creationMethod,
      initialCourses: widget.initialCourses,
      sourceTravelId: widget.sourceTravelId,
      backgroundImageUrl: widget.backgroundImageUrl,
    );
    final onSave = widget.onSave;
    if (onSave != null) {
      onSave(result);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            TravelCreationPipeline.requiresPreferences(widget.creationMethod)
            ? TravelPreferencesScreen(travelInfo: result)
            : TravelCourseCreationScreen(travelInfo: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TravelCreationHeader(currentStepIndex: 1, onBackTap: _handleBack),
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '어떤 여행인지 알려주세요.',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '여행명',
                      style: AppTextStyles.subTitle.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppInputField(
                      controller: _nameController,
                      hintText: '직접 입력',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      '어떤 여행인가요?(최대 2개 선택)',
                      style: AppTextStyles.subTitle.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_isLoadingTags)
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    else if (_hasTagLoadError)
                      GestureDetector(
                        onTap: _loadTags,
                        child: Text(
                          '태그를 불러오지 못했어요. 다시 시도하기',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      )
                    else
                      AppTravelTagGrid(
                        selectedTags: _selectedTags,
                        availableTags: _availableTags
                            .map((tag) => tag.name)
                            .toList(),
                        onToggle: _handleTagTap,
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                0,
                24,
                AppDimensions.screenBottomPadding,
              ),
              child: AppButton(
                text: '다음',
                isEnabled: _canSave,
                onPressed: _handleSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Travel Info', size: Size(393, 852))
Widget travelInfoScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(393, 852),
        padding: EdgeInsets.only(top: 59, bottom: 34),
      ),
      child: TravelInfoScreen(
        destination: '경상북도 경주시',
        dateRange: DateTimeRange(
          start: DateTime(2026, 7, 3),
          end: DateTime(2026, 7, 5),
        ),
      ),
    ),
  );
}
