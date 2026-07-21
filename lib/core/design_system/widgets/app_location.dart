import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';
import '../app_icons.dart';
import '../app_text_styles.dart';

/// 여행지의 이름과 주소를 표시하는 공통 카드입니다.
///
/// [showReorderHandle]을 활성화하면 왼쪽에 정렬 핸들이 표시되고,
/// [reorderIndex]를 전달하면 핸들을 드래그해 순서 변경을 시작할 수 있습니다.
/// [onDelete]를 전달하면 오른쪽 더보기 버튼과 삭제 팝오버가 표시됩니다.
class AppLocation extends StatefulWidget {
  const AppLocation({
    super.key,
    required this.name,
    required this.address,
    this.showReorderHandle = false,
    this.onMorePressed,
    this.onDelete,
    this.reorderIndex,
    this.assetPackage,
  }) : assert(
         reorderIndex == null || showReorderHandle,
         'reorderIndex를 사용하려면 showReorderHandle이 true여야 합니다.',
       );

  final String name;
  final String address;
  final bool showReorderHandle;
  final VoidCallback? onMorePressed;
  final VoidCallback? onDelete;
  final int? reorderIndex;
  final String? assetPackage;

  @override
  State<AppLocation> createState() => _AppLocationState();
}

class _AppLocationState extends State<AppLocation> {
  bool _isDeletePopoverVisible = false;

  void _handleMorePressed() {
    widget.onMorePressed?.call();

    if (widget.onDelete != null) {
      setState(() => _isDeletePopoverVisible = !_isDeletePopoverVisible);
    }
  }

  void _handleDelete() {
    setState(() => _isDeletePopoverVisible = false);
    widget.onDelete?.call();
  }

  Widget _buildReorderHandle() {
    final Widget handle = Semantics(
      button: widget.reorderIndex != null,
      label: widget.reorderIndex != null ? '순서 변경' : null,
      child: SvgPicture.asset(
        AppIcons.reorderHandle,
        package: widget.assetPackage,
        width: 24,
        height: 24,
      ),
    );

    final int? reorderIndex = widget.reorderIndex;
    if (reorderIndex == null) {
      return handle;
    }

    return ReorderableDragStartListener(index: reorderIndex, child: handle);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 77),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.gray1,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.5, color: AppColors.gray3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: TapRegion(
        onTapOutside: (_) {
          if (_isDeletePopoverVisible) {
            setState(() => _isDeletePopoverVisible = false);
          }
        },
        child: Stack(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 77),
              child: Row(
                children: [
                  if (widget.showReorderHandle) ...[
                    const SizedBox(width: 16),
                    _buildReorderHandle(),
                    const SizedBox(width: 17),
                  ] else
                    const SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.subTitle.copyWith(
                            color: AppColors.text,
                            package: widget.assetPackage,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.text,
                            package: widget.assetPackage,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.onMorePressed != null || widget.onDelete != null)
                    Semantics(
                      button: true,
                      label: '더보기',
                      child: InkWell(
                        onTap: _handleMorePressed,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 26,
                          ),
                          child: SvgPicture.asset(
                            AppIcons.more,
                            package: widget.assetPackage,
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              AppColors.gray5,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 30),
                ],
              ),
            ),
            if (_isDeletePopoverVisible)
              Positioned(
                top: 14,
                right: 5,
                child: _DeletePopover(
                  assetPackage: widget.assetPackage,
                  onTap: _handleDelete,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeletePopover extends StatelessWidget {
  const _DeletePopover({required this.assetPackage, required this.onTap});

  final String? assetPackage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '삭제하기',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 125,
          height: 50,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            shadows: const [
              BoxShadow(
                color: AppColors.popoverShadow,
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 22,
                top: 13,
                child: SvgPicture.asset(
                  AppIcons.trashBlack,
                  package: assetPackage,
                  width: 24,
                  height: 24,
                ),
              ),
              Positioned(
                left: 54,
                top: 13,
                child: Text(
                  '삭제하기',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.text,
                    package: assetPackage,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'yoongi', name: 'Location')
Widget appLocationPreview() {
  return const Material(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: AppLocation(
        name: '첨성대',
        address: '경북 경주시 인왕동 839-1',
        assetPackage: 'pozit',
      ),
    ),
  );
}

@Preview(group: 'yoongi', name: 'Reorderable Location')
Widget reorderableAppLocationPreview() {
  return Material(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: AppLocation(
        name: '동궁과월지',
        address: '경북 경주시 원화로 102',
        showReorderHandle: true,
        onDelete: () {},
        assetPackage: 'pozit',
      ),
    ),
  );
}

@Preview(group: 'yoongi', name: 'Reorderable Location List')
Widget reorderableAppLocationListPreview() {
  return const Material(child: _ReorderableLocationListPreview());
}

class _ReorderableLocationListPreview extends StatefulWidget {
  const _ReorderableLocationListPreview();

  @override
  State<_ReorderableLocationListPreview> createState() =>
      _ReorderableLocationListPreviewState();
}

class _ReorderableLocationListPreviewState
    extends State<_ReorderableLocationListPreview> {
  final List<(String, String)> _locations = [
    ('첨성대', '경북 경주시 인왕동 839-1'),
    ('동궁과 월지', '경북 경주시 원화로 102'),
    ('황리단길', '경북 경주시 포석로 1080'),
  ];

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      final location = _locations.removeAt(oldIndex);
      _locations.insert(newIndex, location);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.all(16),
      itemCount: _locations.length,
      onReorderItem: _reorder,
      itemBuilder: (context, index) {
        final location = _locations[index];

        return Padding(
          key: ValueKey(location.$1),
          padding: const EdgeInsets.only(bottom: 8),
          child: AppLocation(
            name: location.$1,
            address: location.$2,
            showReorderHandle: true,
            reorderIndex: index,
            onDelete: () {
              setState(() => _locations.remove(location));
            },
            assetPackage: 'pozit',
          ),
        );
      },
    );
  }
}
