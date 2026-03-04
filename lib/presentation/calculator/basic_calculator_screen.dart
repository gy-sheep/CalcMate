import 'package:calcmate/presentation/calculator/basic_calculator_colors.dart';
import 'package:calcmate/presentation/calculator/basic_calculator_viewmodel.dart';
import 'package:calcmate/presentation/calculator/widgets/button_pad.dart';
import 'package:calcmate/presentation/calculator/widgets/calculator_app_bar.dart';
import 'package:calcmate/presentation/calculator/widgets/display_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BasicCalculatorScreen extends ConsumerWidget {
  final String title;
  final IconData icon;
  final Color color;

  const BasicCalculatorScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(basicCalculatorViewModelProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kCalcGradientTop, kCalcGradientBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CalculatorAppBar(title: title, icon: icon),
              Expanded(child: DisplayPanel(state: state)),
              const Divider(color: Color(0x33FFFFFF), thickness: 0.5, height: 1),
              const ButtonPad(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
