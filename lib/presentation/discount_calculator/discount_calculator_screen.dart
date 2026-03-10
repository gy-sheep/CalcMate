import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Colors.white, size: CmAppBar.backIconSize),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          title,
          style: CmAppBar.titleText.copyWith(color: Colors.white),
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
                    horizontal: screenPaddingH,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: CmInputCard.padding,
        decoration: BoxDecoration(
          color: kDiscountFieldBg,
          borderRadius: BorderRadius.circular(CmInputCard.radius),
          border: Border.all(
            color: isActive ? kDiscountFieldBorderActive : kDiscountFieldBorder,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('원가',
                style: CmInputCard.titleText.copyWith(
                    color: kDiscountTextSecondary)),
            const SizedBox(height: CmInputCard.titleSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value.isEmpty ? '0' : value,
                  style: CmInputCard.inputText.copyWith(
                    color: value.isEmpty ? kDiscountTextSecondary : kDiscountTextPrimary,
                  ),
                ),
                if (currencySymbol.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    currencySymbol,
                    style: CmInputCard.unitText.copyWith(
                      color: isActive ? kDiscountAccent : kDiscountTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 할인율 섹션
// ──────────────────────────────────────────
class _DiscountRateSection extends StatefulWidget {
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
  State<_DiscountRateSection> createState() => _DiscountRateSectionState();
}

class _DiscountRateSectionState extends State<_DiscountRateSection> {
  final _scrollCtrl = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    final left = pos.pixels > 0;
    final right = pos.pixels < pos.maxScrollExtent;
    if (left != _canScrollLeft || right != _canScrollRight) {
      setState(() {
        _canScrollLeft = left;
        _canScrollRight = right;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onFieldTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: CmInputCard.padding,
        decoration: BoxDecoration(
          color: kDiscountFieldBg,
          borderRadius: BorderRadius.circular(CmInputCard.radius),
          border: Border.all(
            color: widget.isActive
                ? kDiscountFieldBorderActive
                : kDiscountFieldBorder,
            width: widget.isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('할인율',
                style: CmInputCard.titleText.copyWith(
                    color: kDiscountTextSecondary)),
            const SizedBox(height: CmInputCard.titleSpacing),
            Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollCtrl,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(widget.chips.length, (i) {
                      final active = widget.selectedChip == i;
                      return Padding(
                        padding: EdgeInsets.only(
                            right: i < widget.chips.length - 1 ? 8 : 0),
                        child: GestureDetector(
                          onTap: () => widget.onChipTap(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: CmTab.padding,
                            decoration: BoxDecoration(
                              color: active
                                  ? kDiscountChipActiveBg
                                  : kDiscountChipBg,
                              borderRadius:
                                  BorderRadius.circular(CmTab.radius),
                              border: Border.all(
                                color: active
                                    ? kDiscountChipActiveBg
                                    : kDiscountFieldBorder,
                              ),
                            ),
                            child: Text(
                              widget.chips[i],
                              style: CmTab.text.copyWith(
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
                if (_canScrollLeft)
                  Positioned(
                    left: 0, top: 0, bottom: 0, width: 32,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              kDiscountFieldBg,
                              kDiscountFieldBg.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_canScrollRight)
                  Positioned(
                    right: 0, top: 0, bottom: 0, width: 32,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              kDiscountFieldBg,
                              kDiscountFieldBg.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  widget.rateText.isEmpty ? '0' : widget.rateText,
                  style: CmInputCard.inputText.copyWith(
                    color: widget.rateText.isEmpty
                        ? kDiscountTextSecondary
                        : kDiscountTextPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '%',
                  style: CmInputCard.unitText.copyWith(
                    color: widget.isActive
                        ? kDiscountAccent
                        : kDiscountTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 추가 할인 섹션
// ──────────────────────────────────────────
class _ExtraDiscountSection extends StatefulWidget {
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
  State<_ExtraDiscountSection> createState() => _ExtraDiscountSectionState();
}

class _ExtraDiscountSectionState extends State<_ExtraDiscountSection> {
  final _scrollCtrl = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    final left = pos.pixels > 0;
    final right = pos.pixels < pos.maxScrollExtent;
    if (left != _canScrollLeft || right != _canScrollRight) {
      setState(() {
        _canScrollLeft = left;
        _canScrollRight = right;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.onToggle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.show
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
                color: kDiscountAccent,
                size: CmIcon.small,
              ),
              const SizedBox(width: 6),
              Text(
                widget.show ? '추가 할인 제거' : '추가 할인',
                style: rowLabel.copyWith(color: kDiscountAccent),
              ),
            ],
          ),
        ),
        if (widget.show) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: widget.onFieldTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: CmInputCard.padding,
              decoration: BoxDecoration(
                color: kDiscountFieldBg,
                borderRadius: BorderRadius.circular(CmInputCard.radius),
                border: Border.all(
                  color: widget.isActive
                      ? kDiscountFieldBorderActive
                      : kDiscountFieldBorder,
                  width: widget.isActive ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('추가 할인율',
                      style: CmInputCard.titleText.copyWith(
                          color: kDiscountTextSecondary)),
                  const SizedBox(height: CmInputCard.titleSpacing),
                  Stack(
                    children: [
                      SingleChildScrollView(
                        controller: _scrollCtrl,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(widget.chips.length, (i) {
                            final active = widget.selectedChip == i;
                            return Padding(
                              padding: EdgeInsets.only(
                                  right: i < widget.chips.length - 1 ? 8 : 0),
                              child: GestureDetector(
                                onTap: () => widget.onChipTap(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: CmTab.padding,
                                  decoration: BoxDecoration(
                                    color: active
                                        ? kDiscountChipActiveBg
                                        : kDiscountChipBg,
                                    borderRadius:
                                        BorderRadius.circular(CmTab.radius),
                                    border: Border.all(
                                      color: active
                                          ? kDiscountChipActiveBg
                                          : kDiscountFieldBorder,
                                    ),
                                  ),
                                  child: Text(
                                    widget.chips[i],
                                    style: CmTab.text.copyWith(
                                      color: active
                                          ? kDiscountChipActiveText
                                          : kDiscountChipText,
                                      fontWeight:
                                          active ? FontWeight.w600 : null,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      if (_canScrollLeft)
                        Positioned(
                          left: 0, top: 0, bottom: 0, width: 32,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    kDiscountFieldBg,
                                    kDiscountFieldBg.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_canScrollRight)
                        Positioned(
                          right: 0, top: 0, bottom: 0, width: 32,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [
                                    kDiscountFieldBg,
                                    kDiscountFieldBg.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.rateText.isEmpty ? '0' : widget.rateText,
                        style: CmInputCard.inputText.copyWith(
                          color: widget.rateText.isEmpty
                              ? kDiscountTextSecondary
                              : kDiscountTextPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '%',
                        style: CmInputCard.unitText.copyWith(
                          color: widget.isActive
                              ? kDiscountAccent
                              : kDiscountTextSecondary,
                        ),
                      ),
                    ],
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
      padding: CmResultCard.padding,
      decoration: BoxDecoration(
        color: kDiscountCardBg,
        borderRadius: BorderRadius.circular(CmResultCard.radius),
        border: Border.all(color: kDiscountCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${_fmt(originalPrice)}$currencySymbol',
                style: CmResultCard.unitText.copyWith(
                  color: kDiscountTextSecondary,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: kDiscountTextSecondary,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward,
                  color: kDiscountTextSecondary,
                  size: CmTab.iconSize),
              const SizedBox(width: 8),
              Text(
                '${_fmt(finalPrice)}$currencySymbol',
                style: CmResultCard.unitText.copyWith(
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
                style: CmResultCard.unitText.copyWith(
                    color: kDiscountTextSecondary),
              ),
              Text(
                '- ${_fmt(savedAmount)}$currencySymbol',
                style: CmResultCard.unitText.copyWith(
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
                style: CmResultCard.unitText.copyWith(
                    color: kDiscountTextSecondary),
              ),
              Text(
                '${effectiveRate.toStringAsFixed(effectiveRate % 1 == 0 ? 0 : 1)}%',
                style: CmResultCard.unitText.copyWith(
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
                style: CmResultCard.unitText.copyWith(
                    color: kDiscountTextSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                '${_fmt(finalPrice)}$currencySymbol',
                style: CmResultCard.resultText.copyWith(
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
          height: keypadButtonHeightLarge,
          child: Center(
            child: label == '⌫'
                ? Icon(Icons.backspace_outlined,
                    color: color, size: keypadBackspaceSize)
                : Text(
                    label,
                    style: keypadNumberText
                        .copyWith(color: color),
                  ),
          ),
        ),
      ),
    );
  }
}
