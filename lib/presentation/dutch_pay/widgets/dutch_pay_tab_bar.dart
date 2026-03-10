import 'package:flutter/material.dart';

import '../../../presentation/widgets/app_animated_tab_bar.dart';
import '../dutch_pay_colors.dart';

class DutchPayTabBar extends StatelessWidget {
  const DutchPayTabBar({
    super.key,
    required this.pageOffset,
    required this.onTabSelected,
  });

  final double pageOffset;
  final ValueChanged<int> onTabSelected;

  static const _labels = ['N빵', '각출'];

  @override
  Widget build(BuildContext context) {
    return AppAnimatedTabBar(
      labels: _labels,
      pageOffset: pageOffset,
      onTabSelected: onTabSelected,
      accentColor: kDutchAccent,
      dividerColor: kDutchDivider,
      inactiveColor: kDutchTextTertiary,
    );
  }
}
