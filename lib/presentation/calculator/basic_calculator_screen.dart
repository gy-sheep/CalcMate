import 'package:calcmate/core/theme/app_design_tokens.dart';
import 'package:calcmate/presentation/calculator/basic_calculator_colors.dart';
import 'package:calcmate/presentation/calculator/basic_calculator_viewmodel.dart';
import 'package:calcmate/presentation/calculator/widgets/button_pad.dart';
import 'package:calcmate/presentation/calculator/widgets/display_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BasicCalculatorScreen extends ConsumerWidget {
  final String title;

  const BasicCalculatorScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(basicCalculatorViewModelProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppTokens.fontSizeAppBarTitle,
            fontWeight: AppTokens.weightAppBarTitle,
          ),
        ),
        centerTitle: false,
      ),
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
