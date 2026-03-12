import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../age_calculator_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        l10n.age_label_futureDate,
        style: const TextStyle(color: kAgeTextSecondary, fontSize: 15),
      ),
    );
  }
}
