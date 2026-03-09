/// 안 A — 표준 입력형
/// 조건 입력 → 결과 확인. 전통적인 계산기 흐름.
library;

import 'package:flutter/material.dart';

import '_loan_calc_helper.dart';
import '_loan_shared_widgets.dart';

class PrototypeAScreen extends StatefulWidget {
  const PrototypeAScreen({super.key});

  @override
  State<PrototypeAScreen> createState() => _PrototypeAScreenState();
}

class _PrototypeAScreenState extends State<PrototypeAScreen> {
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
          '안 A — 표준 입력형',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 입력 섹션 ──────────────────────────────────
                LoanSectionCard(
                  child: Column(
                    children: [
                      LoanSliderRow(
                        label: '대출 원금',
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
                        label: '대출 기간',
                        value: '$_termYears년',
                        sliderValue: (_termYears - 1) / 39,
                        onChanged: (v) => setState(() =>
                            _termYears =
                                (1 + (v * 39).round()).clamp(1, 40)),
                        minLabel: '1년',
                        maxLabel: '40년',
                      ),
                      const LoanDivider(),
                      const SizedBox(height: 4),
                      LoanRepayTypeSelector(
                        selected: _repayType,
                        onChanged: (t) =>
                            setState(() => _repayType = t),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── 결과 섹션 ──────────────────────────────────
                LoanSectionCard(
                  child: Column(
                    children: [
                      _ResultRow(
                        label: '월 납입금',
                        value: formatWon(_monthlyPayment),
                        highlight: true,
                      ),
                      const LoanDivider(),
                      _ResultRow(
                        label: '총 상환금',
                        value: formatWon(_totalPayment),
                      ),
                      const LoanDivider(),
                      _ResultRow(
                        label: '총 이자',
                        value: formatWon(_totalInterest),
                        valueColor: kLoanInterestColor,
                      ),
                      const SizedBox(height: 12),
                      LoanRatioBar(
                        principalRatio: _principalRatio,
                        principalLabel:
                            '원금 ${(_principalRatio * 100).toStringAsFixed(1)}%',
                        interestLabel:
                            '이자 ${((1 - _principalRatio) * 100).toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── 상환 일정 ──────────────────────────────────
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
                                color:
                                    Colors.white.withValues(alpha: 0.4),
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

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final Color? valueColor;

  const _ResultRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: highlight ? 0.9 : 0.6),
            fontSize: highlight ? 15 : 13,
            fontWeight:
                highlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: highlight ? 22 : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
