import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_text_styles.dart';

enum TravelCompletionStatus { incomplete, complete }

class TravelCompletionToggle extends StatefulWidget {
  const TravelCompletionToggle({
    super.key,
    required this.incompleteCount,
    required this.completeCount,
    this.selectedStatus,
    this.initialStatus = TravelCompletionStatus.incomplete,
    this.onChanged,
  });

  final int incompleteCount;
  final int completeCount;
  final TravelCompletionStatus? selectedStatus;
  final TravelCompletionStatus initialStatus;
  final ValueChanged<TravelCompletionStatus>? onChanged;

  @override
  State<TravelCompletionToggle> createState() => _TravelCompletionToggleState();
}

class _TravelCompletionToggleState extends State<TravelCompletionToggle> {
  late TravelCompletionStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.selectedStatus ?? widget.initialStatus;
  }

  @override
  void didUpdateWidget(TravelCompletionToggle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedStatus != null &&
        widget.selectedStatus != oldWidget.selectedStatus) {
      _selectedStatus = widget.selectedStatus!;
    }
  }

  void _handleTap(TravelCompletionStatus status) {
    if (_selectedStatus == status) return;

    if (widget.selectedStatus == null) {
      setState(() => _selectedStatus = status);
    }

    widget.onChanged?.call(status);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: LayoutBuilder(
        builder: (context, _) {
          final isIncompleteSelected =
              _selectedStatus == TravelCompletionStatus.incomplete;

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
                                _handleTap(TravelCompletionStatus.incomplete),
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
                            onTap: () =>
                                _handleTap(TravelCompletionStatus.complete),
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

@Preview(group: 'hycho', name: 'Travel Completion Toggle')
Widget travelCompletionTogglePreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: TravelCompletionToggle(incompleteCount: 0, completeCount: 1),
      ),
    ),
  );
}
