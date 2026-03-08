import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../core/widgets/ad_banner_placeholder.dart';
import '../../domain/models/discount_calculator_state.dart';
import '../../domain/usecases/calculate_discount_usecase.dart';
import '../../presentation/widgets/scroll_fade_view.dart';
import 'discount_calculator_colors.dart';
import 'discount_calculator_viewmodel.dart';

String _getCurrencySymbol() {
  const map = <String, String>{
    'KR': '₩',
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Colors.white, size: AppTokens.sizeAppBarBackIcon),
          onPressed: () => Navigator.maybePop(context),
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
            colors: [kDiscountGradientTop, kDiscountGradientBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ScrollFadeView(
                  fadeColor: kDiscountGradientBottom,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.paddingScreenH,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _OriginalPriceField(
                        value: state.originalPrice,
                        isActive: state.activeField == ActiveField.originalPrice,
                        currencySymbol: currency,
                        onTap: () => vm.handleIntent(
                            const DiscountCalculatorIntent.fieldTapped(
                                ActiveField.originalPrice)),
                      ),
                      const SizedBox(height: 20),
                      _DiscountRateSection(
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
                      _ExtraDiscountSection(
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
                        _ResultCard(
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
              _DiscountKeypad(
                activeField: state.activeField,
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

// ──────────────────────────────────────────
// 원가 입력 필드
// ──────────────────────────────────────────
class _OriginalPriceField extends StatelessWidget {
  final String value;
  final bool isActive;
  final String currencySymbol;
  final VoidCallback onTap;

  const _OriginalPriceField({
    required this.value,
    required this.isActive,
    required this.currencySymbol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '원가',
            style: AppTokens.textStyleLabelLarge.copyWith(
              color: kDiscountTextSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: AppTokens.paddingInputField,
            decoration: BoxDecoration(
              color: kDiscountFieldBg,
              borderRadius: BorderRadius.circular(AppTokens.radiusInput),
              border: Border.all(
                color: isActive
                    ? kDiscountFieldBorderActive
                    : kDiscountFieldBorder,
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                if (currencySymbol.isNotEmpty) ...[
                  Text(
                    currencySymbol,
                    style: AppTokens.textStyleResult18.copyWith(
                      color: isActive
                          ? kDiscountAccent
                          : kDiscountTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    value.isEmpty ? '0' : value,
                    style: AppTokens.textStyleResult24.copyWith(
                      color: value.isEmpty
                          ? kDiscountTextSecondary
                          : kDiscountTextPrimary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// 할인율 섹션
// ──────────────────────────────────────────
class _DiscountRateSection extends StatelessWidget {
  final String rateText;
  final int? selectedChip;
  final bool isActive;
  final List<String> chips;
  final void Function(int) onChipTap;
  final VoidCallback onFieldTap;

  const _DiscountRateSection({
    required this.rateText,
    required this.selectedChip,
    required this.isActive,
    required this.chips,
    required this.onChipTap,
    required this.onFieldTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '할인율',
          style: AppTokens.textStyleLabelLarge.copyWith(
            color: kDiscountTextSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(chips.length, (i) {
              final active = selectedChip == i;
              return Padding(
                padding: EdgeInsets.only(right: i < chips.length - 1 ? 8 : 0),
                child: GestureDetector(
                  onTap: () => onChipTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          active ? kDiscountChipActiveBg : kDiscountChipBg,
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusChip),
                      border: Border.all(
                        color: active
                            ? kDiscountChipActiveBg
                            : kDiscountFieldBorder,
                      ),
                    ),
                    child: Text(
                      chips[i],
                      style: AppTokens.textStyleChip.copyWith(
                        color: active
                            ? kDiscountChipActiveText
                            : kDiscountChipText,
                        fontWeight: active ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onFieldTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: AppTokens.paddingInputField,
            decoration: BoxDecoration(
              color: kDiscountFieldBg,
              borderRadius: BorderRadius.circular(AppTokens.radiusInput),
              border: Border.all(
                color: isActive
                    ? kDiscountFieldBorderActive
                    : kDiscountFieldBorder,
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    rateText.isEmpty ? '0' : rateText,
                    style: AppTokens.textStyleResult24.copyWith(
                      color: rateText.isEmpty
                          ? kDiscountTextSecondary
                          : kDiscountTextPrimary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '%',
                  style: AppTokens.textStyleResult18.copyWith(
                    color: isActive
                        ? kDiscountAccent
                        : kDiscountTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────
// 추가 할인 섹션
// ──────────────────────────────────────────
class _ExtraDiscountSection extends StatelessWidget {
  final bool show;
  final String rateText;
  final int? selectedChip;
  final bool isActive;
  final List<String> chips;
  final VoidCallback onToggle;
  final void Function(int) onChipTap;
  final VoidCallback onFieldTap;

  const _ExtraDiscountSection({
    required this.show,
    required this.rateText,
    required this.selectedChip,
    required this.isActive,
    required this.chips,
    required this.onToggle,
    required this.onChipTap,
    required this.onFieldTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                show ? Icons.remove_circle_outline : Icons.add_circle_outline,
                color: kDiscountAccent,
                size: AppTokens.sizeIconSmall,
              ),
              const SizedBox(width: 6),
              Text(
                show ? '추가 할인 제거' : '추가 할인 쌓기',
                style: AppTokens.textStyleSectionTitle.copyWith(
                  color: kDiscountAccent,
                ),
              ),
            ],
          ),
        ),
        if (show) ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(chips.length, (i) {
                final active = selectedChip == i;
                return Padding(
                  padding:
                      EdgeInsets.only(right: i < chips.length - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => onChipTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: AppTokens.paddingChip,
                      decoration: BoxDecoration(
                        color: active
                            ? kDiscountChipActiveBg
                            : kDiscountChipBg,
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusChip),
                        border: Border.all(
                          color: active
                              ? kDiscountChipActiveBg
                              : kDiscountFieldBorder,
                        ),
                      ),
                      child: Text(
                        chips[i],
                        style: AppTokens.textStyleChip.copyWith(
                          color: active
                              ? kDiscountChipActiveText
                              : kDiscountChipText,
                          fontWeight: active ? FontWeight.w600 : null,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onFieldTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: AppTokens.paddingInputField,
              decoration: BoxDecoration(
                color: kDiscountFieldBg,
                borderRadius: BorderRadius.circular(AppTokens.radiusInput),
                border: Border.all(
                  color: isActive
                      ? kDiscountFieldBorderActive
                      : kDiscountFieldBorder,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rateText.isEmpty ? '0' : rateText,
                      style: AppTokens.textStyleResult24.copyWith(
                        color: rateText.isEmpty
                            ? kDiscountTextSecondary
                            : kDiscountTextPrimary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '%',
                    style: AppTokens.textStyleResult18.copyWith(
                      color: isActive
                          ? kDiscountAccent
                          : kDiscountTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────
// 결과 카드
// ──────────────────────────────────────────
class _ResultCard extends StatelessWidget {
  final double originalPrice;
  final double finalPrice;
  final double savedAmount;
  final double effectiveRate;
  final double discountRate;
  final double? extraRate;
  final String currencySymbol;

  const _ResultCard({
    required this.originalPrice,
    required this.finalPrice,
    required this.savedAmount,
    required this.effectiveRate,
    required this.discountRate,
    required this.extraRate,
    required this.currencySymbol,
  });

  String _fmt(double v) => CalculateDiscountUseCase.formatPrice(v);

  @override
  Widget build(BuildContext context) {
    final hasExtra = extraRate != null && extraRate! > 0;
    final rateLabel = hasExtra
        ? '${discountRate.toStringAsFixed(discountRate % 1 == 0 ? 0 : 1)}% + ${extraRate!.toStringAsFixed(extraRate! % 1 == 0 ? 0 : 1)}%'
        : '${discountRate.toStringAsFixed(discountRate % 1 == 0 ? 0 : 1)}%';

    return Container(
      padding: AppTokens.paddingCard,
      decoration: BoxDecoration(
        color: kDiscountCardBg,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: kDiscountCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$currencySymbol${_fmt(originalPrice)}',
                style: AppTokens.textStyleBody.copyWith(
                  color: kDiscountTextSecondary,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: kDiscountTextSecondary,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward,
                  color: kDiscountTextSecondary,
                  size: AppTokens.sizeIconXSmall),
              const SizedBox(width: 8),
              Text(
                '$currencySymbol${_fmt(finalPrice)}',
                style: AppTokens.textStyleBody.copyWith(
                  color: kDiscountTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: kDiscountCardBorder, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '할인 금액',
                style: AppTokens.textStyleBody
                    .copyWith(color: kDiscountTextSecondary),
              ),
              Text(
                '- $currencySymbol${_fmt(savedAmount)}',
                style: AppTokens.textStyleBody.copyWith(
                  color: kDiscountTextSavings,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasExtra ? '실질 할인율 ($rateLabel)' : '할인율',
                style: AppTokens.textStyleBody
                    .copyWith(color: kDiscountTextSecondary),
              ),
              Text(
                '${effectiveRate.toStringAsFixed(effectiveRate % 1 == 0 ? 0 : 1)}%',
                style: AppTokens.textStyleBody.copyWith(
                  color: kDiscountTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '최종가',
                style: AppTokens.textStyleBody
                    .copyWith(color: kDiscountTextSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                '$currencySymbol${_fmt(finalPrice)}',
                style: AppTokens.textStyleResult36.copyWith(
                  color: kDiscountTextFinalPrice,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// 숫자 키패드
// ──────────────────────────────────────────
class _DiscountKeypad extends StatelessWidget {
  final ActiveField activeField;
  final void Function(String) onKey;

  const _DiscountKeypad({
    required this.activeField,
    required this.onKey,
  });

  static const _rows = [
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    ['00', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _rows.map((row) {
        return Row(
          children: row.map((key) {
            return Expanded(
              child: _KeypadButton(
                label: key,
                isSpecial: key == '⌫',
                onTap: () => onKey(key),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String label;
  final bool isSpecial;
  final VoidCallback? onTap;

  const _KeypadButton({
    required this.label,
    required this.isSpecial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSpecial ? kDiscountKeyFunction : kDiscountKeyNumber;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white10,
        highlightColor: Colors.white10,
        child: SizedBox(
          height: AppTokens.heightButtonLarge,
          child: Center(
            child: label == '⌫'
                ? Icon(Icons.backspace_outlined,
                    color: color, size: AppTokens.sizeKeypadBackspace)
                : Text(
                    label,
                    style: AppTokens.textStyleKeypadNumber
                        .copyWith(color: color),
                  ),
          ),
        ),
      ),
    );
  }
}
