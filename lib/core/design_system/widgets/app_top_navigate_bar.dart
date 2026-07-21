import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

enum AppTopNavigateTab { incomplete, complete }

class AppTopNavigateBar extends StatefulWidget {
  const AppTopNavigateBar({
    super.key,
    required this.incompleteCount,
    required this.completeCount,
    this.selectedTab,
    this.initialTab = AppTopNavigateTab.incomplete,
    this.onChanged,
  });

  final int incompleteCount;
  final int completeCount;
  final AppTopNavigateTab? selectedTab;
  final AppTopNavigateTab initialTab;
  final ValueChanged<AppTopNavigateTab>? onChanged;

  @override
  State<AppTopNavigateBar> createState() => _AppTopNavigateBarState();
}

class _AppTopNavigateBarState extends State<AppTopNavigateBar> {
  late AppTopNavigateTab _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.selectedTab ?? widget.initialTab;
  }

  @override
  void didUpdateWidget(AppTopNavigateBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedTab != null &&
        widget.selectedTab != oldWidget.selectedTab) {
      _selectedTab = widget.selectedTab!;
    }
  }

  void _handleTap(AppTopNavigateTab tab) {
    if (_selectedTab == tab) return;

    if (widget.selectedTab == null) {
      setState(() => _selectedTab = tab);
    }

    widget.onChanged?.call(tab);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: LayoutBuilder(
        builder: (context, _) {
          final isIncompleteSelected =
              _selectedTab == AppTopNavigateTab.incomplete;

          return DecoratedBox(
            decoration: const ShapeDecoration(
              color: AppColors.gray2,
              shape: StadiumBorder(),
            ),
            child: ClipPath(
              clipper: const ShapeBorderClipper(shape: StadiumBorder()),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeInOutCubic,
                        alignment: isIncompleteSelected
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: const FractionallySizedBox(
                          widthFactor: 0.5,
                          heightFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(9999),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        children: [
                          Expanded(
                            child: _TabText(
                              label: '미완료 ${widget.incompleteCount}',
                              isSelected: isIncompleteSelected,
                            ),
                          ),
                          Expanded(
                            child: _TabText(
                              label: '완료 ${widget.completeCount}',
                              isSelected: !isIncompleteSelected,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: isIncompleteSelected,
                          label: '미완료 ${widget.incompleteCount}',
                          child: GestureDetector(
                            onTap: () =>
                                _handleTap(AppTopNavigateTab.incomplete),
                            behavior: HitTestBehavior.opaque,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: !isIncompleteSelected,
                          label: '완료 ${widget.completeCount}',
                          child: GestureDetector(
                            onTap: () => _handleTap(AppTopNavigateTab.complete),
                            behavior: HitTestBehavior.opaque,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TabText extends StatelessWidget {
  const _TabText({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.body.copyWith(
          color: isSelected ? AppColors.text : AppColors.gray5,
        ),
      ),
    );
  }
}

@Preview(group: 'hycho', name: 'Top Navigate Bar')
Widget appTopNavigateBarPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: AppTopNavigateBar(incompleteCount: 0, completeCount: 1),
      ),
    ),
  );
}
