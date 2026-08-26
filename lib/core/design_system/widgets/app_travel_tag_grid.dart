import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'app_chip.dart';

class AppTravelTagGrid extends StatelessWidget {
  const AppTravelTagGrid({
    super.key,
    required this.selectedTags,
    required this.onToggle,
    this.availableTags = options,
  });

  static const List<String> options = [
    '기록',
    '미식',
    '힐링',
    '체험',
    '문화',
    '예술',
    '쇼핑',
    '탐험',
  ];

  static const int _columns = 4;

  final Set<String> selectedTags;
  final ValueChanged<String> onToggle;
  final List<String> availableTags;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (var i = 0; i < availableTags.length; i += _columns)
        availableTags.sublist(i, (i + _columns).clamp(0, availableTags.length)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var row = 0; row < rows.length; row++) ...[
          if (row > 0) const SizedBox(height: 10),
          Row(
            children: [
              for (var column = 0; column < rows[row].length; column++) ...[
                if (column > 0) const SizedBox(width: 9),
                Expanded(
                  child: AppTagChip(
                    label: '# ${rows[row][column]}',
                    isSelected: selectedTags.contains(rows[row][column]),
                    onTap: () => onToggle(rows[row][column]),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

@Preview(group: 'hycho', name: 'Travel Tag Grid')
Widget appTravelTagGridPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AppTravelTagGrid(
          selectedTags: const {'미식', '문화'},
          onToggle: (_) {},
        ),
      ),
    ),
  );
}
