import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../age_calculator_colors.dart';

class AgePicker extends StatelessWidget {
  const AgePicker({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.label,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int index) label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 40,
      physics: const FixedExtentScrollPhysics(),
      perspective: 0.003,
      diameterRatio: 1.8,
      squeeze: 1,
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final isSelected = controller.hasClients &&
              controller.selectedItem == index;
          return Center(
            child: AnimatedDefaultTextStyle(
              duration: durationAnimFast,
              style: TextStyle(
                color: isSelected ? kAgeAccent : kAgeTextPrimary.withValues(alpha: 0.5),
                fontSize: isSelected ? 18 : 15,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                height: 1.0,
              ),
              child: Text(label(index)),
            ),
          );
        },
      ),
    );
  }
}
