import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../age_calculator_colors.dart';

class AppBarRow extends StatelessWidget {
  const AppBarRow({super.key, required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: kAgeText,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Icon(icon, color: kAgeAccent, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: kAgeText,
              fontSize: AppTokens.fontSizeAppBarTitle,
              fontWeight: AppTokens.weightAppBarTitle,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
