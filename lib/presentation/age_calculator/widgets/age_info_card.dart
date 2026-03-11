import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../age_calculator_colors.dart';

class AgeInfoCard extends StatelessWidget {
  const AgeInfoCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radiusCard),
        boxShadow: [
          BoxShadow(
            color: kAgeCardShadow.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
