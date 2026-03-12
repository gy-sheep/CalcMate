import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppAnimatedTabBar(
      labels: [l10n.dutchPay_tab_equal, l10n.dutchPay_tab_individual],
      pageOffset: pageOffset,
      onTabSelected: onTabSelected,
      accentColor: kDutchAccent,
      dividerColor: kDutchDivider,
      inactiveColor: kDutchTextTertiary,
    );
  }
}
