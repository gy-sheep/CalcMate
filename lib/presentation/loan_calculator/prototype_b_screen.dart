/// 안 B — 결과 우선형
/// 진입 즉시 기본값 결과 노출 → 슬라이더로 조건 탐색.
library;

import 'package:flutter/material.dart';

import '_loan_calc_helper.dart';
import '_loan_shared_widgets.dart';

class PrototypeBScreen extends StatefulWidget {
  const PrototypeBScreen({super.key});

  @override
  State<PrototypeBScreen> createState() => _PrototypeBScreenState();
}

class _PrototypeBScreenState extends State<PrototypeBScreen> {
  double _loanAmount = 1e8;
  double _annualRate = 3.5;
  int _termYears = 30;
  RepayType _repayType = RepayType.annuity;
  bool _scheduleExpanded = false;

  int get _termMonths => _termYears * 12;

  double get _monthlyPayment =>
      calcFirstPayment(_loanAmount, _annualRate, _termMonths, _repayType);
  double get _totalPayment =>
      calcTotalPayment(_loanAmount, _annualRate, _termMonths, _repayType);
  double get _totalInterest => calcTotalInterest(_loanAmount, _totalPayment);
  double get _principalRatio => _loanAmount / _totalPayment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLoanBgTop,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: kLoanBgTop,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          '안 B — 결과 우선형',
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
                // ── ① 결과 히어로 카드 (가장 먼저) ───────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E3A5F), Color(0xFF0D2340)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: kLoanAccent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '월 납입금',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatWon(_monthlyPayment),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LoanRatioBar(
                        principalRatio: _principalRatio,
                        principalLabel:
                            '원금 ${(_principalRatio * 100).toStringAsFixed(1)}%',
                        interestLabel:
                            '이자 ${((1 - _principalRatio) * 100).toStringAsFixed(1)}%',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _StatChip(
                            label: '총 상환금',
                            value: shortWon(_totalPayment),
                            color:
                                Colors.white.withValues(alpha: 0.1),
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: '총 이자',
                            value: shortWon(_totalInterest),
                            color: kLoanInterestColor
                                .withValues(alpha: 0.15),
                            valueColor: kLoanInterestColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── ② 조건 슬라이더 ─────────────────────────────
                LoanSectionCard(
                  child: Column(
                    children: [
                      LoanSliderRow(
                        label: '대출금',
                        value: shortWon(_loanAmount),
                        sliderValue: (_loanAmount - 1e7) / (1e9 - 1e7),
                        onChanged: (v) => setState(() => _loanAmount =
                            ((1e7 + v * (1e9 - 1e7)) ~/ 1e7 * 1e7)
                                .toDouble()),
                        minLabel: '1천만',
                        maxLabel: '10억',
                      ),
                      const LoanDivider(),
                      LoanSliderRow(
                        label: '연 이율',
                        value: '${_annualRate.toStringAsFixed(2)}%',
                        sliderValue: (_annualRate - 0.1) / 19.9,
                        onChanged: (v) => setState(() => _annualRate =
                            double.parse(
                                (0.1 + v * 19.9).toStringAsFixed(2))),
                        minLabel: '0.1%',
                        maxLabel: '20%',
                      ),
                      const LoanDivider(),
                      LoanSliderRow(
                        label: '기간',
                        value: '$_termYears년',
                        sliderValue: (_termYears - 1) / 39,
                        onChanged: (v) => setState(() =>
                            _termYears =
                                (1 + (v * 39).round()).clamp(1, 40)),
                        minLabel: '1년',
                        maxLabel: '40년',
                      ),
                      const LoanDivider(),
                      LoanRepayTypeSelector(
                        selected: _repayType,
                        onChanged: (t) =>
                            setState(() => _repayType = t),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── ③ 상환 일정 ─────────────────────────────────
                LoanSectionCard(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => setState(() =>
                            _scheduleExpanded = !_scheduleExpanded),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                '상환 일정',
                                style: TextStyle(
                                  color: Colors.white
                                      .withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                _scheduleExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Colors.white54,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_scheduleExpanded) ...[
                        const SizedBox(height: 8),
                        LoanAmortizationTable(
                          rows: calcAmortization(
                            _loanAmount,
                            _annualRate,
                            _termMonths,
                            _repayType,
                          ).take(6).toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '... 총 $_termMonths회',
                            style: TextStyle(
                                color: Colors.white
                                    .withValues(alpha: 0.4),
                                fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color? valueColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
