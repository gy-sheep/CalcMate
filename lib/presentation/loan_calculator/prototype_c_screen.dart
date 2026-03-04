/// 안 C — 타임라인형
/// 대출 상환 여정을 연도별 누적 바 차트로 시각화.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '_loan_calc_helper.dart';
import '_loan_shared_widgets.dart';

class PrototypeCScreen extends StatefulWidget {
  const PrototypeCScreen({super.key});

  @override
  State<PrototypeCScreen> createState() => _PrototypeCScreenState();
}

class _PrototypeCScreenState extends State<PrototypeCScreen> {
  double _loanAmount = 1e8;
  double _annualRate = 3.5;
  int _termYears = 30;
  RepayType _repayType = RepayType.annuity;
  int? _selectedBarIndex;

  int get _termMonths => _termYears * 12;

  double get _monthlyPayment =>
      calcFirstPayment(_loanAmount, _annualRate, _termMonths, _repayType);
  double get _totalInterest => calcTotalInterest(
      _loanAmount,
      calcTotalPayment(_loanAmount, _annualRate, _termMonths, _repayType));

  @override
  Widget build(BuildContext context) {
    final chartData = calcYearlyAccum(
        _loanAmount, _annualRate, _termYears, _repayType);

    return Scaffold(
      backgroundColor: kLoanBgTop,
      appBar: AppBar(
        backgroundColor: kLoanBgTop,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          '안 C — 타임라인형',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kLoanBgTop, kLoanBgBottom],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // ── ① 요약 수치 (컴팩트) ─────────────────────────
                Row(
                  children: [
                    _CompactStat(
                      label: '월 납입금',
                      value: formatWon(_monthlyPayment),
                      accent: kLoanAccent,
                    ),
                    const SizedBox(width: 8),
                    _CompactStat(
                      label: '총 이자',
                      value: formatWon(_totalInterest),
                      accent: kLoanInterestColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── ② 상환 여정 차트 ─────────────────────────────
                LoanSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '상환 여정',
                            style: TextStyle(
                              color:
                                  Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              _Legend(
                                  color: kLoanPrincipalColor,
                                  label: '원금'),
                              const SizedBox(width: 12),
                              _Legend(
                                  color: kLoanInterestColor,
                                  label: '이자'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (chartData.isEmpty)
                        const SizedBox(height: 160)
                      else
                        _RepaymentBarChart(
                          data: chartData,
                          selectedIndex: _selectedBarIndex,
                          onBarTap: (i) => setState(() {
                            _selectedBarIndex =
                                _selectedBarIndex == i ? null : i;
                          }),
                        ),
                      if (_selectedBarIndex != null &&
                          _selectedBarIndex! < chartData.length) ...[
                        const SizedBox(height: 12),
                        _BarTooltip(
                            data: chartData[_selectedBarIndex!]),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── ③ 조건 슬라이더 ─────────────────────────────
                LoanSectionCard(
                  child: Column(
                    children: [
                      LoanSliderRow(
                        label: '대출금',
                        value: shortWon(_loanAmount),
                        sliderValue: (_loanAmount - 1e7) / (1e9 - 1e7),
                        onChanged: (v) => setState(() {
                          _loanAmount =
                              ((1e7 + v * (1e9 - 1e7)) ~/ 1e7 * 1e7)
                                  .toDouble();
                          _selectedBarIndex = null;
                        }),
                        minLabel: '1천만',
                        maxLabel: '10억',
                      ),
                      const LoanDivider(),
                      LoanSliderRow(
                        label: '연 이율',
                        value: '${_annualRate.toStringAsFixed(2)}%',
                        sliderValue: (_annualRate - 0.1) / 19.9,
                        onChanged: (v) => setState(() {
                          _annualRate = double.parse(
                              (0.1 + v * 19.9).toStringAsFixed(2));
                          _selectedBarIndex = null;
                        }),
                        minLabel: '0.1%',
                        maxLabel: '20%',
                      ),
                      const LoanDivider(),
                      LoanSliderRow(
                        label: '기간',
                        value: '$_termYears년',
                        sliderValue: (_termYears - 1) / 39,
                        onChanged: (v) => setState(() {
                          _termYears =
                              (1 + (v * 39).round()).clamp(1, 40);
                          _selectedBarIndex = null;
                        }),
                        minLabel: '1년',
                        maxLabel: '40년',
                      ),
                      const LoanDivider(),
                      LoanRepayTypeSelector(
                        selected: _repayType,
                        onChanged: (t) => setState(() {
                          _repayType = t;
                          _selectedBarIndex = null;
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 차트 ──────────────────────────────────────────────────────────────

class _RepaymentBarChart extends StatelessWidget {
  final List<YearlyAccum> data;
  final int? selectedIndex;
  final ValueChanged<int> onBarTap;

  const _RepaymentBarChart({
    required this.data,
    required this.selectedIndex,
    required this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = data.isEmpty
        ? 1.0
        : data
            .map((d) => d.cumPrincipal + d.cumInterest)
            .reduce(math.max);

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Y축
          SizedBox(
            width: 32,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(shortWon(maxVal),
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 9)),
                Text(shortWon(maxVal / 2),
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 9)),
                Text('0',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 9)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // 바
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: data.asMap().entries.map((entry) {
                      final i = entry.key;
                      final d = entry.value;
                      final total = d.cumPrincipal + d.cumInterest;
                      final totalH = total / maxVal;
                      final principalFrac =
                          total > 0 ? d.cumPrincipal / total : 0.0;
                      final isSelected = selectedIndex == i;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onBarTap(i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.end,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(
                                      milliseconds: 200),
                                  height: 150 * totalH,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        const BorderRadius.vertical(
                                            top: Radius.circular(4)),
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.white54,
                                            width: 1.5)
                                        : null,
                                  ),
                                  child: ClipRRect(
                                    borderRadius:
                                        const BorderRadius.vertical(
                                            top: Radius.circular(4)),
                                    child: Column(
                                      children: [
                                        // 이자 (상단)
                                        Flexible(
                                          flex: ((1 - principalFrac) *
                                                  100)
                                              .round()
                                              .clamp(1, 99),
                                          child: Container(
                                            color: isSelected
                                                ? kLoanInterestColor
                                                : kLoanInterestColor
                                                    .withValues(
                                                        alpha: 0.75),
                                          ),
                                        ),
                                        // 원금 (하단)
                                        Flexible(
                                          flex: (principalFrac * 100)
                                              .round()
                                              .clamp(1, 99),
                                          child: Container(
                                            color: isSelected
                                                ? kLoanPrincipalColor
                                                : kLoanPrincipalColor
                                                    .withValues(
                                                        alpha: 0.75),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 4),
                // X축
                Row(
                  children: data.asMap().entries.map((entry) {
                    return Expanded(
                      child: Text(
                        '${entry.value.year}년',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selectedIndex == entry.key
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4),
                          fontSize: 9,
                          fontWeight: selectedIndex == entry.key
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarTooltip extends StatelessWidget {
  final YearlyAccum data;
  const _BarTooltip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Text(
            '${data.year}년 시점',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Spacer(),
          _TooltipChip(
              label: '원금 상환',
              value: shortWon(data.cumPrincipal),
              color: kLoanPrincipalColor),
          const SizedBox(width: 12),
          _TooltipChip(
              label: '이자 납부',
              value: shortWon(data.cumInterest),
              color: kLoanInterestColor),
        ],
      ),
    );
  }
}

class _TooltipChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TooltipChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            style: TextStyle(
                color: color.withValues(alpha: 0.8), fontSize: 10)),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _CompactStat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _CompactStat(
      {required this.label,
      required this.value,
      required this.accent});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kLoanCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                  color: accent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11)),
      ],
    );
  }
}
