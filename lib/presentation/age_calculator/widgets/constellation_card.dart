import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/usecases/age_calculate_usecase.dart';
import '../age_calculator_colors.dart';
import 'age_info_card.dart';

class ConstellationCard extends StatelessWidget {
  const ConstellationCard({super.key, required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    final (name, _) = kConstellations[result.constellationIndex];
    return AgeInfoCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '별자리',
              style: CmBirthdayMiniCard.labelText.copyWith(
                color: kAgeTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Image.asset(
                  kConstellationIcons[result.constellationIndex],
                  width: 36,
                  height: 36,
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: textStyle16.copyWith(
                    color: kAgeTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
