import 'package:flutter/material.dart';

import '../age_calculator_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '미래 날짜는 계산할 수 없어요',
        style: TextStyle(color: kAgeSubText, fontSize: 15),
      ),
    );
  }
}
