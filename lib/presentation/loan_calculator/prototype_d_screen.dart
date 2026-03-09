/// 안 D — 목표 역산형
/// "월 얼마 낼 수 있어?" 에서 시작 → 최대 대출 가능금액 역산.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '_loan_calc_helper.dart';
import '_loan_shared_widgets.dart';

enum _CalcMode { maxLoan, monthly }

class PrototypeDScreen extends StatefulWidget {
  const PrototypeDScreen({super.key});

  @override
  State<PrototypeDScreen> createState() => _PrototypeDScreenState();
}

class _PrototypeDScreenState extends State<PrototypeDScreen> {
  _CalcMode _mode = _CalcMode.maxLoan;

  double _monthlyBudget = 1200000;
  double _loanAmount = 1e8;
  double _annualRate = 3.5;
  int _termYears = 30;
  RepayType _repayType = RepayType.annuity;

  int get _termMonths => _termYears * 12;

  double get _maxLoan =>
      calcMaxLoan(_monthlyBudget, _annualRate, _termMonths);

  double get _monthlyPayment =>
      calcFirstPayment(_loanAmount, _annualRate, _termMonths, _repayType);

  double get _totalPayment => _mode == _CalcMode.maxLoan
      ? calcTotalPayment(_maxLoan, _annualRate, _termMonths, _repayType)
      : calcTotalPayment(_loanAmount, _annualRate, _termMonths, _repayType);

  double get _principalRatio {
    final principal =
        _mode == _CalcMode.maxLoan ? _maxLoan : _loanAmount;
    return _totalPayment > 0 ? principal / _totalPayment : 0;
  }

  late final TextEditingController _budgetCtrl;

  @override
  void initState() {
    super.initState();
    _budgetCtrl = TextEditingController(
        text: _formatNumber(_monthlyBudget.toInt()));
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    super.dispose();
  }

  static String _formatNumber(int n) => n
      .toString()
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  void _onBudgetChanged(String raw) {
    final digits = raw.replaceAll(',', '');
    final val = double.tryParse(digits);
    if (val != null) setState(() => _monthlyBudget = val);
  }

  bool get _isInsufficientBudget =>
      _mode == _CalcMode.maxLoan && _maxLoan <= 0 && _annualRate > 0;

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
          '안 D — 목표 역산형',
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
                // ── ① 모드 탭 ────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _ModeTab(
                        label: '최대 대출금 계산',
                        selected: _mode == _CalcMode.maxLoan,
                        onTap: () =>
                            setState(() => _mode = _CalcMode.maxLoan),
                      ),
                      _ModeTab(
                        label: '납입금 계산',
                        selected: _mode == _CalcMode.monthly,
                        onTap: () =>
                            setState(() => _mode = _CalcMode.monthly),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── ② 메인 입력 ──────────────────────────────
                LoanSectionCard(
                  child: _mode == _CalcMode.maxLoan
                      ? _BudgetInput(
                          controller: _budgetCtrl,
                          onChanged: _onBudgetChanged,
                        )
                      : LoanSliderRow(
                          label: '대출 원금',
                          value: shortWon(_loanAmount),
                          sliderValue: (_loanAmount - 1e7) / (1e9 - 1e7),
                          onChanged: (v) => setState(() => _loanAmount =
                              ((1e7 + v * (1e9 - 1e7)) ~/ 1e7 * 1e7)
                                  .toDouble()),
                          minLabel: '1천만',
                          maxLabel: '10억',
                        ),
                ),
                const SizedBox(height: 12),

                // ── ③ 공통 조건 ──────────────────────────────
                LoanSectionCard(
                  child: Column(
                    children: [
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

                // ── ④ 결과 ──────────────────────────────────
                if (_isInsufficientBudget)
                  _ErrorCard(
                    message:
                        '납입 예산이 월 이자보다 적습니다.\n예산을 늘리거나 이율·기간을 조정해 주세요.',
                  )
                else
                  _ResultCard(
                    mode: _mode,
                    maxLoan: _maxLoan,
                    monthlyPayment: _monthlyPayment,
                    totalPayment: _totalPayment,
                    totalInterest: calcTotalInterest(
                      _mode == _CalcMode.maxLoan
                          ? _maxLoan
                          : _loanAmount,
                      _totalPayment,
                    ),
                    principalRatio: _principalRatio,
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

// ── 위젯 ───────────────────────────────────────────────────────────────

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? kLoanAccent.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: selected
                ? Border.all(
                    color: kLoanAccent.withValues(alpha: 0.5))
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? kLoanAccent
                  : Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _BudgetInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _BudgetInput(
      {required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '매달 낼 수 있는 금액은?',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _ThousandsSepFormatter(),
          ],
          onChanged: onChanged,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixText: '₩  ',
            prefixStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: kLoanAccent, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.15)),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [50, 100, 150, 200, 300].map((amount) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    final val = amount * 10000.0;
                    final formatted = val
                        .toInt()
                        .toString()
                        .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (m) => '${m[1]},');
                    controller.text = formatted;
                    onChanged(formatted);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Text(
                      '${amount}만',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final _CalcMode mode;
  final double maxLoan;
  final double monthlyPayment;
  final double totalPayment;
  final double totalInterest;
  final double principalRatio;

  const _ResultCard({
    required this.mode,
    required this.maxLoan,
    required this.monthlyPayment,
    required this.totalPayment,
    required this.totalInterest,
    required this.principalRatio,
  });

  @override
  Widget build(BuildContext context) {
    final isMaxLoan = mode == _CalcMode.maxLoan;
    final heroLabel = isMaxLoan ? '최대 대출 가능금액' : '월 납입금';
    final heroValue = isMaxLoan
        ? formatWon(maxLoan)
        : formatWon(monthlyPayment);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E1A3B), Color(0xFF1A0F26)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFFAB47BC).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            heroLabel,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            heroValue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          LoanRatioBar(
            principalRatio: principalRatio,
            principalLabel:
                '원금 ${(principalRatio * 100).toStringAsFixed(1)}%',
            interestLabel:
                '이자 ${((1 - principalRatio) * 100).toStringAsFixed(1)}%',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Chip(label: '총 상환금', value: shortWon(totalPayment)),
              const SizedBox(width: 8),
              _Chip(
                  label: '총 이자',
                  value: shortWon(totalInterest),
                  valueColor: kLoanInterestColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Chip(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kLoanInterestColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: kLoanInterestColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: kLoanInterestColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThousandsSepFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(',', '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final n = int.tryParse(digits);
    if (n == null) return oldValue;
    final formatted = n
        .toString()
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},');
    return TextEditingValue(
      text: formatted,
      selection:
          TextSelection.collapsed(offset: formatted.length),
    );
  }
}
