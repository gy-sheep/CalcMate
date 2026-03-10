import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../date_calculator_colors.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: CmInfoCard.padding,
      decoration: BoxDecoration(
        color: kDateCardBg,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: kDateCardBorder),
      ),
      child: child,
    );
  }
}
