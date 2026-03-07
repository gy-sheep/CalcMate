import 'package:flutter/material.dart';

import '../../../presentation/widgets/app_animated_tab_bar.dart';
import '../date_calculator_colors.dart';

class DateTabBar extends StatelessWidget {
  const DateTabBar({
    super.key,
    required this.pageOffset,
    required this.onTabSelected,
  });

  final double pageOffset;
  final ValueChanged<int> onTabSelected;

  static const _labels = ['기간 계산', '날짜 계산', 'D-Day'];

  @override
  Widget build(BuildContext context) {
    return AppAnimatedTabBar(
      labels: _labels,
      pageOffset: pageOffset,
      onTabSelected: onTabSelected,
      accentColor: kDateAccent,
      dividerColor: kDateDivider,
      inactiveColor: kDateTextTertiary,
    );
  }
}
