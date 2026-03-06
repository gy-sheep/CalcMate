import 'package:flutter/material.dart';

import '../../../domain/models/age_calculator_state.dart';
import '../../../domain/usecases/age_calculate_usecase.dart';
import '../age_calculator_colors.dart';
import 'age_card.dart';
import 'constellation_card.dart';
import 'days_lived_card.dart';
import 'next_birthday_card.dart';
import 'zodiac_card.dart';

class ResultScrollView extends StatelessWidget {
  const ResultScrollView({super.key, required this.state, required this.result});
  final AgeCalculatorState state;
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              AgeCard(result: result),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: NextBirthdayCard(result: result)),
                  const SizedBox(width: 12),
                  Expanded(child: DaysLivedCard(result: result)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: ZodiacCard(result: result)),
                  const SizedBox(width: 12),
                  Expanded(child: ConstellationCard(result: result)),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 0, right: 0, bottom: 0,
          height: 48,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.6, 1.0],
                  colors: [
                    kAgeBgEnd.withValues(alpha: 0),
                    kAgeBgEnd.withValues(alpha: 0.7),
                    kAgeBgEnd,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
