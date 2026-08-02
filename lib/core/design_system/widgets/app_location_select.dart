import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

class AppLocationSelect extends StatefulWidget {
  const AppLocationSelect({
    super.key,
    required this.title,
    required this.address,
    this.isSelected,
    this.initiallySelected = false,
    this.showTrailingIndicator = true,
    this.onChanged,
  });

  final String title;
  final String address;
  final bool? isSelected;
  final bool initiallySelected;

  final bool showTrailingIndicator;
  final ValueChanged<bool>? onChanged;

  @override
  State<AppLocationSelect> createState() => _AppLocationSelectState();
}

class _AppLocationSelectState extends State<AppLocationSelect> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected ?? widget.initiallySelected;
  }

  @override
  void didUpdateWidget(AppLocationSelect oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected != null &&
        widget.isSelected != oldWidget.isSelected) {
      _isSelected = widget.isSelected!;
    }
  }

  void _handleTap() {
    final nextSelected = !_isSelected;

    if (widget.isSelected == null) {
      setState(() => _isSelected = nextSelected);
    }

    widget.onChanged?.call(nextSelected);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _isSelected ? AppColors.purple2 : AppColors.gray3;
    final borderWidth = _isSelected ? 1.0 : 0.6;

    return Semantics(
      button: true,
      selected: _isSelected,
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 19,
          ).copyWith(left: 30, right: 20),
          decoration: BoxDecoration(
            color: AppColors.gray1,
            border: Border.all(width: borderWidth, color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subTitle.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.showTrailingIndicator) ...[
                const SizedBox(width: 12),
                _SelectionIndicator(isSelected: _isSelected),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 1,
          color: isSelected ? AppColors.gray5 : AppColors.gray4,
        ),
      ),
      child: isSelected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.gray5,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

@Preview(group: 'hycho', name: 'Location Select - 기본형')
Widget appLocationSelectDefaultPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: AppLocationSelect(
          title: '정동진 해변',
          address: '강원특별자치도 강릉시 강동면 정동진리 64-3',
        ),
      ),
    ),
  );
}

@Preview(group: 'hycho', name: 'Location Select - 선택됨')
Widget appLocationSelectSelectedPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: AppLocationSelect(
          title: '정동진 해변',
          address: '강원특별자치도 강릉시 강동면 정동진리 64-3',
          initiallySelected: true,
        ),
      ),
    ),
  );
}
