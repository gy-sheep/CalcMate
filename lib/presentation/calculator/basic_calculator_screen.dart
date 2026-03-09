import 'package:calcmate/core/theme/app_design_tokens.dart';
import 'package:calcmate/core/widgets/ad_banner_placeholder.dart';
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
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: AppTokens.sizeAppBarBackIcon),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: AppTokens.textStyleAppBarTitle.copyWith(color: Colors.white),
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
              const AdBannerPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }
}
