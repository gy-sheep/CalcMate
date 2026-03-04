import 'package:flutter/material.dart';

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
            const Text(
              '띠',
              style: TextStyle(
                  color: kAgeSubText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
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
                  style: const TextStyle(
                      color: kAgeText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
