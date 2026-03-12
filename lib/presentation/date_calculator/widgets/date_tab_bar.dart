import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppAnimatedTabBar(
      labels: [l10n.date_tab_period, l10n.date_tab_dateCalc, l10n.date_tab_dday],
      pageOffset: pageOffset,
      onTabSelected: onTabSelected,
      accentColor: kDateAccent,
      dividerColor: kDateDivider,
      inactiveColor: kDateTextTertiary,
    );
  }
}
