/// 대출 계산기 프로토타입 공유 위젯
library;

import 'package:flutter/material.dart';

import '_loan_calc_helper.dart';

// ── 레이아웃 ──────────────────────────────────────────────────────────

class LoanSectionCard extends StatelessWidget {
  final Widget child;
  const LoanSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kLoanCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kLoanDivider),
      ),
      child: child,
    );
  }
}

class LoanDivider extends StatelessWidget {
  const LoanDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(color: kLoanDivider, height: 20);
  }
}

// ── 입력 ──────────────────────────────────────────────────────────────

class LoanSliderRow extends StatelessWidget {
  final String label;
  final String value;
  final double sliderValue;
  final ValueChanged<double> onChanged;
  final String minLabel;
  final String maxLabel;

  const LoanSliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.sliderValue,
    required this.onChanged,
    required this.minLabel,
    required this.maxLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            activeTrackColor: kLoanAccent,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
            thumbColor: Colors.white,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayColor: kLoanAccent.withValues(alpha: 0.15),
            overlayShape:
                const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: sliderValue.clamp(0, 1),
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(minLabel,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11)),
            Text(maxLabel,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

class LoanRepayTypeSelector extends StatelessWidget {
  final RepayType selected;
  final ValueChanged<RepayType> onChanged;

  const LoanRepayTypeSelector(
      {super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('상환 방식',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13)),
        const SizedBox(height: 10),
        Row(
          children: RepayType.values.map((t) {
            final isSelected = t == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(t),
                child: Container(
                  margin: EdgeInsets.only(
                      right: t != RepayType.bullet ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? kLoanAccent.withValues(alpha: 0.25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? kLoanAccent
                          : Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    t.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? kLoanAccent
                          : Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── 결과 표시 ─────────────────────────────────────────────────────────

class LoanRatioBar extends StatelessWidget {
  final double principalRatio;
  final String principalLabel;
  final String interestLabel;

  const LoanRatioBar({
    super.key,
    required this.principalRatio,
    required this.principalLabel,
    required this.interestLabel,
  });

  @override
  Widget build(BuildContext context) {
    final pRatio = principalRatio.clamp(0.0, 1.0);
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                Flexible(
                  flex: (pRatio * 100).round().clamp(1, 99),
                  child: Container(color: kLoanPrincipalColor),
                ),
                Flexible(
                  flex: ((1 - pRatio) * 100).round().clamp(1, 99),
                  child: Container(color: kLoanInterestColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _LegendItem(
                color: kLoanPrincipalColor, label: principalLabel),
            _LegendItem(
                color: kLoanInterestColor, label: interestLabel),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11)),
    ]);
  }
}

// ── 상환 일정표 ──────────────────────────────────────────────────────

class LoanAmortizationTable extends StatelessWidget {
  final List<AmortizationRow> rows;
  const LoanAmortizationTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
        color: Colors.white54,
        fontSize: 11,
        fontWeight: FontWeight.w500);
    const cellStyle = TextStyle(color: Colors.white70, fontSize: 11);

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
                width: 30,
                child: Text('회차',
                    style: headerStyle,
                    textAlign: TextAlign.center)),
            Expanded(
                child: Text('납입금',
                    style: headerStyle,
                    textAlign: TextAlign.right)),
            Expanded(
                child: Text('원금',
                    style: headerStyle,
                    textAlign: TextAlign.right)),
            Expanded(
                child: Text('이자',
                    style: headerStyle,
                    textAlign: TextAlign.right)),
            Expanded(
                child: Text('잔금',
                    style: headerStyle,
                    textAlign: TextAlign.right)),
          ],
        ),
        const SizedBox(height: 4),
        ...rows.map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                      width: 30,
                      child: Text('${r.month}',
                          style: cellStyle,
                          textAlign: TextAlign.center)),
                  Expanded(
                      child: Text(_compact(r.payment),
                          style: cellStyle,
                          textAlign: TextAlign.right)),
                  Expanded(
                      child: Text(_compact(r.principal),
                          style: const TextStyle(
                              color: kLoanPrincipalColor,
                              fontSize: 11),
                          textAlign: TextAlign.right)),
                  Expanded(
                      child: Text(_compact(r.interest),
                          style: const TextStyle(
                              color: kLoanInterestColor,
                              fontSize: 11),
                          textAlign: TextAlign.right)),
                  Expanded(
                      child: Text(_compact(r.balance),
                          style: cellStyle,
                          textAlign: TextAlign.right)),
                ],
              ),
            )),
      ],
    );
  }

  String _compact(double v) {
    if (v >= 1e8) return '${(v / 1e8).toStringAsFixed(1)}억';
    if (v >= 1e4) return '${(v / 1e4).round()}만';
    return v.round().toString();
  }
}
