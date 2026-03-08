import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../core/widgets/ad_banner_placeholder.dart';
import '../../presentation/widgets/scroll_fade_view.dart';
import 'discount_calculator_colors.dart';

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
// UI 프로토타입 — 실제 ViewModel/UseCase 없음
// ──────────────────────────────────────────

enum _ActiveField { originalPrice, discountRate, extraDiscountRate }

class DiscountCalculatorScreen extends StatefulWidget {
  final String title;
  const DiscountCalculatorScreen({super.key, required this.title});

  @override
  State<DiscountCalculatorScreen> createState() =>
      _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState extends State<DiscountCalculatorScreen>
    with SingleTickerProviderStateMixin {
  _ActiveField _activeField = _ActiveField.originalPrice;

  String _originalPrice = '';
  String _discountRate = '';
  bool _showExtra = false;
  String _extraRate = '';

  int? _selectedChip;         // 기본 할인율 칩 인덱스
  int? _selectedExtraChip;    // 추가 할인율 칩 인덱스

  static const _chips = ['5%', '10%', '20%', '30%', '50%'];

  // ── 계산 ──────────────────────────────────

  double get _price => double.tryParse(_originalPrice.replaceAll(',', '')) ?? 0;
  double get _rate => double.tryParse(_discountRate) ?? 0;
  double get _extra => double.tryParse(_extraRate) ?? 0;

  bool get _hasResult => _price > 0 && _rate > 0;

  double get _discountedPrice {
    double p = _price * (1 - _rate / 100);
    if (_showExtra && _extra > 0) p *= (1 - _extra / 100);
    return p;
  }

  double get _savedAmount => _price - _discountedPrice;

  double get _effectiveRate => (_savedAmount / _price * 100);

  String _formatPrice(double value) {
    if (value == 0) return '0';
    final parts = value.toStringAsFixed(0).split('');
    final result = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) result.write(',');
      result.write(parts[i]);
    }
    return result.toString();
  }

  String _formatInputPrice(String raw) {
    final digits = raw.replaceAll(',', '');
    if (digits.isEmpty) return '';
    final value = int.tryParse(digits);
    if (value == null) return raw;
    return _formatPrice(value.toDouble());
  }

  // ── 키패드 입력 ───────────────────────────

  void _onKey(String key) {
    setState(() {
      switch (_activeField) {
        case _ActiveField.originalPrice:
          _originalPrice = _applyKey(_originalPrice.replaceAll(',', ''), key, isPrice: true);
          _originalPrice = _formatInputPrice(_originalPrice);
        case _ActiveField.discountRate:
          _discountRate = _applyKey(_discountRate, key, isPrice: false);
          _selectedChip = _chips.indexWhere((c) => c == '$_discountRate%');
          if (_selectedChip == -1) _selectedChip = null;
        case _ActiveField.extraDiscountRate:
          _extraRate = _applyKey(_extraRate, key, isPrice: false);
          _selectedExtraChip = _chips.indexWhere((c) => c == '$_extraRate%');
          if (_selectedExtraChip == -1) _selectedExtraChip = null;
      }
    });
  }

  String _applyKey(String current, String key, {required bool isPrice}) {
    switch (key) {
      case '⌫':
        return current.isEmpty ? '' : current.substring(0, current.length - 1);
      case 'AC':
        return '';
      case '.':
        if (isPrice) return current;
        if (current.contains('.')) return current;
        return '${current.isEmpty ? '0' : current}.';
      case '00':
        if (current.isEmpty || current == '0') return current;
        return '$current${isPrice ? '00' : '00'}';
      default:
        if (isPrice) {
          final next = current + key;
          final val = int.tryParse(next);
          if (val == null || val > 9999999999) return current;
          return next;
        } else {
          final next = current + key;
          final val = double.tryParse(next);
          if (val == null || val >= 100) return current;
          return next;
        }
    }
  }

  void _selectChip(int index, {bool isExtra = false}) {
    final value = _chips[index].replaceAll('%', '');
    setState(() {
      if (isExtra) {
        _selectedExtraChip = index;
        _extraRate = value;
        _activeField = _ActiveField.extraDiscountRate;
      } else {
        _selectedChip = index;
        _discountRate = value;
        _activeField = _ActiveField.discountRate;
      }
    });
  }

  // ── Build ─────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: AppTokens.sizeAppBarBackIcon),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          widget.title,
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
              // ── 입력 + 결과 영역 ──
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
                        value: _originalPrice,
                        isActive: _activeField == _ActiveField.originalPrice,
                        currencySymbol: _getCurrencySymbol(),
                        onTap: () => setState(
                            () => _activeField = _ActiveField.originalPrice),
                      ),
                      const SizedBox(height: 20),
                      _DiscountRateSection(
                        rateText: _discountRate,
                        selectedChip: _selectedChip,
                        isActive: _activeField == _ActiveField.discountRate,
                        chips: _chips,
                        onChipTap: (i) => _selectChip(i),
                        onFieldTap: () => setState(
                            () => _activeField = _ActiveField.discountRate),
                      ),
                      const SizedBox(height: 12),
                      _ExtraDiscountSection(
                        show: _showExtra,
                        rateText: _extraRate,
                        selectedChip: _selectedExtraChip,
                        isActive: _activeField == _ActiveField.extraDiscountRate,
                        chips: _chips,
                        onToggle: () => setState(() {
                          _showExtra = !_showExtra;
                          if (_showExtra) {
                            _activeField = _ActiveField.extraDiscountRate;
                          } else {
                            _extraRate = '';
                            _selectedExtraChip = null;
                            _activeField = _ActiveField.discountRate;
                          }
                        }),
                        onChipTap: (i) => _selectChip(i, isExtra: true),
                        onFieldTap: () => setState(
                            () => _activeField = _ActiveField.extraDiscountRate),
                        onRemove: () => setState(() {
                          _showExtra = false;
                          _extraRate = '';
                          _selectedExtraChip = null;
                          _activeField = _ActiveField.discountRate;
                        }),
                      ),
                      const SizedBox(height: 24),
                      if (_hasResult)
                        _ResultCard(
                          originalPrice: _price,
                          finalPrice: _discountedPrice,
                          savedAmount: _savedAmount,
                          effectiveRate: _effectiveRate,
                          discountRate: _rate,
                          extraRate: _showExtra ? _extra : null,
                          currencySymbol: _getCurrencySymbol(),
                          formatPrice: _formatPrice,
                        ),
                    ],
                  ),
                ),
              ),
              // ── 구분선 ──
              const Divider(color: kDiscountDivider, thickness: 0.5, height: 1),
              // ── 키패드 ──
              _DiscountKeypad(
                activeField: _activeField,
                onKey: _onKey,
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
            padding:
                AppTokens.paddingInputField,
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
        // 칩 행
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
        // 직접 입력 필드
        GestureDetector(
          onTap: onFieldTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                AppTokens.paddingInputField,
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
  final VoidCallback onRemove;

  const _ExtraDiscountSection({
    required this.show,
    required this.rateText,
    required this.selectedChip,
    required this.isActive,
    required this.chips,
    required this.onToggle,
    required this.onChipTap,
    required this.onFieldTap,
    required this.onRemove,
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
          // 추가 할인 칩
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
              padding:
                  AppTokens.paddingInputField,
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
  final String Function(double) formatPrice;

  const _ResultCard({
    required this.originalPrice,
    required this.finalPrice,
    required this.savedAmount,
    required this.effectiveRate,
    required this.discountRate,
    required this.extraRate,
    required this.currencySymbol,
    required this.formatPrice,
  });

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
          // 원가 → 최종가
          Row(
            children: [
              Text(
                '$currencySymbol${formatPrice(originalPrice)}',
                style: AppTokens.textStyleBody.copyWith(
                  color: kDiscountTextSecondary,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: kDiscountTextSecondary,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward,
                  color: kDiscountTextSecondary, size: AppTokens.sizeIconXSmall),
              const SizedBox(width: 8),
              Text(
                '$currencySymbol${formatPrice(finalPrice)}',
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
          // 절약액
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '절약액',
                style: AppTokens.textStyleBody.copyWith(
                  color: kDiscountTextSecondary,
                ),
              ),
              Text(
                '- $currencySymbol${formatPrice(savedAmount)}',
                style: AppTokens.textStyleBody.copyWith(
                  color: kDiscountTextSavings,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 실질 할인율
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasExtra ? '실질 할인율 ($rateLabel)' : '할인율',
                style: AppTokens.textStyleBody.copyWith(
                  color: kDiscountTextSecondary,
                ),
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
          // 최종가
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '최종가',
                style: AppTokens.textStyleBody.copyWith(
                  color: kDiscountTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$currencySymbol${formatPrice(finalPrice)}',
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
  final _ActiveField activeField;
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
            final isSpecial = key == '⌫';
            return Expanded(
              child: _KeypadButton(
                label: key,
                isSpecial: isSpecial,
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
                ? Icon(Icons.backspace_outlined, color: color, size: AppTokens.sizeKeypadBackspace)
                : Text(
                    label,
                    style: AppTokens.textStyleKeypadNumber.copyWith(
                      color: color,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
