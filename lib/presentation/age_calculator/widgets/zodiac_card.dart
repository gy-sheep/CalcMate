import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/usecases/age_calculate_usecase.dart';
import '../age_calculator_colors.dart';
import 'age_info_card.dart';

class ZodiacCard extends StatelessWidget {
  const ZodiacCard({super.key, required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    final (name, _) = kZodiacs[result.zodiacIndex];
    return AgeInfoCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '띠',
              style: CmBirthdayMiniCard.labelText.copyWith(
                color: kAgeSubText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Image.asset(
                  kZodiacIcons[result.zodiacIndex],
                  width: 36,
                  height: 36,
                ),
                const SizedBox(width: 8),
                Text(
                  '$name띠',
                  style: textStyle16.copyWith(
                    color: kAgeText,
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
