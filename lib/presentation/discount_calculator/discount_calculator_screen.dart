import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../core/widgets/ad_banner_placeholder.dart';
import '../../domain/models/discount_calculator_state.dart';
import '../../presentation/widgets/scroll_fade_view.dart';
import 'discount_calculator_colors.dart';
import 'discount_calculator_viewmodel.dart';
import 'widgets/discount_keypad.dart';
import 'widgets/discount_rate_section.dart';
import 'widgets/discount_result_card.dart';
import 'widgets/extra_discount_section.dart';
import 'widgets/original_price_field.dart';

String _getCurrencySymbol() {
  const map = <String, String>{
    'KR': '원',
    'US': '\$', 'CA': '\$',
    'JP': '¥', 'CN': '¥',
    'GB': '£',
    'DE': '€', 'FR': '€', 'IT': '€', 'ES': '€', 'NL': '€',
    'PT': '€', 'AT': '€', 'BE': '€', 'FI': '€', 'IE': '€',
    'IN': '₹',
    'AU': 'A\$',
  };
  final code = PlatformDispatcher.instance.locale.countryCode?.toUpperCase();
  return map[code] ?? '';
}

// ──────────────────────────────────────────
// Screen
// ──────────────────────────────────────────

class DiscountCalculatorScreen extends ConsumerWidget {
  final String title;
  const DiscountCalculatorScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discountCalculatorViewModelProvider);
    final vm = ref.read(discountCalculatorViewModelProvider.notifier);
    final result = vm.result;
    final currency = _getCurrencySymbol();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: kDiscountTextPrimary, size: CmAppBar.backIconSize),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          title,
          style: CmAppBar.titleText.copyWith(color: kDiscountTextPrimary),
        ),
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kDiscountBg1, kDiscountBg2],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ScrollFadeView(
                  fadeColor: kDiscountBg2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: screenPaddingH,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OriginalPriceField(
                        value: state.originalPrice,
                        isActive: state.activeField == ActiveField.originalPrice,
                        currencySymbol: currency,
                        onTap: () => vm.handleIntent(
                            const DiscountCalculatorIntent.fieldTapped(
                                ActiveField.originalPrice)),
                      ),
                      const SizedBox(height: 20),
                      DiscountRateSection(
                        rateText: state.discountRate,
                        selectedChip: state.selectedChip,
                        isActive: state.activeField == ActiveField.discountRate,
                        chips: kDiscountChips,
                        onChipTap: (i) => vm.handleIntent(
                            DiscountCalculatorIntent.chipSelected(i)),
                        onFieldTap: () => vm.handleIntent(
                            const DiscountCalculatorIntent.fieldTapped(
                                ActiveField.discountRate)),
                      ),
                      const SizedBox(height: 12),
                      ExtraDiscountSection(
                        show: state.showExtra,
                        rateText: state.extraRate,
                        selectedChip: state.selectedExtraChip,
                        isActive:
                            state.activeField == ActiveField.extraDiscountRate,
                        chips: kDiscountChips,
                        onToggle: () => vm.handleIntent(
                            const DiscountCalculatorIntent.toggleExtraDiscount()),
                        onChipTap: (i) => vm.handleIntent(
                            DiscountCalculatorIntent.chipSelected(i,
                                isExtra: true)),
                        onFieldTap: () => vm.handleIntent(
                            const DiscountCalculatorIntent.fieldTapped(
                                ActiveField.extraDiscountRate)),
                      ),
                      const SizedBox(height: 24),
                      if (result.hasResult)
                        DiscountResultCard(
                          originalPrice: result.originalPrice,
                          finalPrice: result.finalPrice,
                          savedAmount: result.savedAmount,
                          effectiveRate: result.effectiveRate,
                          discountRate:
                              double.tryParse(state.discountRate) ?? 0,
                          extraRate: state.showExtra
                              ? double.tryParse(state.extraRate)
                              : null,
                          currencySymbol: currency,
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(
                  color: kDiscountDivider, thickness: 0.5, height: 1),
              DiscountKeypad(
                onKey: (key) => vm.handleIntent(
                    DiscountCalculatorIntent.keyPressed(key)),
              ),
              const AdBannerPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }
}
