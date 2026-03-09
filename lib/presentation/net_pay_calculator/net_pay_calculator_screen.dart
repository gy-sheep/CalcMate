import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_design_tokens.dart';
import '../widgets/app_animated_tab_bar.dart';
import '../widgets/blur_status_bar_overlay.dart';
import '../widgets/scroll_fade_view.dart';
import 'net_pay_calculator_colors.dart';

// ── 슬라이더 범위 ──────────────────────────────────────────────────────────────

const _kMonthlyMin = 1000000;
const _kMonthlyMax = 10000000;
const _kAnnualMin  = 24000000;
const _kAnnualMax  = 100000000;

// ── Screen ────────────────────────────────────────────────────────────────────

class NetPayCalculatorScreen extends StatefulWidget {
  final String title;
  const NetPayCalculatorScreen({super.key, required this.title});

  @override
  State<NetPayCalculatorScreen> createState() => _NetPayCalculatorScreenState();
}

class _NetPayCalculatorScreenState extends State<NetPayCalculatorScreen> {
  final _pageController = PageController(initialPage: 1);
  double _pageOffset = 1.0; // 0 = 월급, 1 = 연봉

  int _currentTab = 1;
  int _salary = 45000000;
  int _dependents = 1;

  // ── 계산 (더미 - 프리뷰용) ──────────────────────────────────────────────────

  int get _monthSalary =>
      _currentTab == 0 ? _salary : (_salary / 12).round();

  int get _nationalPension =>
      (_monthSalary.clamp(370000, 6170000) * 0.045).floor();

  int get _healthInsurance =>
      (_monthSalary * 0.03545).floor() ~/ 10 * 10;

  int get _longTermCare =>
      (_healthInsurance * 0.1295).floor();

  int get _employmentInsurance =>
      (_monthSalary * 0.009).floor();

  // 소득세: 간이세액표 기반 더미값 (월급 구간별 간략 근사)
  int get _incomeTax {
    if (_monthSalary <= 0) return 0;
    if (_monthSalary < 1060000) return 0;
    if (_monthSalary < 1500000) return 5060;
    if (_monthSalary < 2000000) return 16520;
    if (_monthSalary < 2500000) return 38960;
    if (_monthSalary < 3000000) return 62050;
    if (_monthSalary < 3500000) return 82370;
    if (_monthSalary < 4000000) return 148830;
    if (_monthSalary < 4500000) return 228430;
    if (_monthSalary < 5000000) return 303540;
    if (_monthSalary < 6000000) return 416200;
    if (_monthSalary < 7000000) return 596990;
    return 827440;
  }

  int get _localTax => (_incomeTax * 0.1).floor();

  int get _totalDeduction =>
      _nationalPension + _healthInsurance + _longTermCare +
      _employmentInsurance + _incomeTax + _localTax;

  int get _netPay =>
      _monthSalary > 0 ? (_monthSalary - _totalDeduction).clamp(0, 999999999) : 0;

  int get _netPayAnnual => _netPay * 12;

  // ── 슬라이더 ───────────────────────────────────────────────────────────────

  int get _sliderMin => _currentTab == 0 ? _kMonthlyMin : _kAnnualMin;
  int get _sliderMax => _currentTab == 0 ? _kMonthlyMax : _kAnnualMax;
  double get _sliderValue =>
      _salary.clamp(_sliderMin, _sliderMax).toDouble();

  // ── 포맷 ───────────────────────────────────────────────────────────────────

  String _fmt(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String get _sliderMinLabel =>
      _currentTab == 0 ? '100만' : '2,400만';
  String get _sliderMaxLabel =>
      _currentTab == 0 ? '1,000만' : '1억';

  // ── 탭 전환 ────────────────────────────────────────────────────────────────

  void _onTabSelected(int index) {
    if (_currentTab == index) return;
    setState(() {
      if (_currentTab == 0 && index == 1) {
        _salary = (_salary * 12).clamp(_kAnnualMin, _kAnnualMax);
      } else if (_currentTab == 1 && index == 0) {
        _salary = (_salary / 12).round().clamp(_kMonthlyMin, _kMonthlyMax);
      }
      _currentTab = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  // ── 키패드 모달 ────────────────────────────────────────────────────────────

  void _showKeypadModal() {
    String _input = _salary > 0 ? _salary.toString() : '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) {
          void append(String digit) {
            setModal(() {
              if (_input.length >= 10) return;
              if (_input.isEmpty && digit == '0') return;
              _input += digit;
            });
          }

          void backspace() {
            setModal(() {
              if (_input.isNotEmpty) {
                _input = _input.substring(0, _input.length - 1);
              }
            });
          }

          void confirm() {
            final val = int.tryParse(_input) ?? 0;
            setState(() => _salary = val.clamp(0, 9999999999));
            Navigator.pop(ctx);
          }

          String displayText() {
            if (_input.isEmpty) return '0 원';
            final n = int.tryParse(_input) ?? 0;
            return '${_fmt(n)} 원';
          }

          return Container(
            decoration: const BoxDecoration(
              color: kNetPayBgTop,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppTokens.radiusBottomSheet)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 핸들
                Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: kNetPayCardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 입력 표시
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: kNetPayDeductionBg,
                    borderRadius: BorderRadius.circular(AppTokens.radiusInput),
                    border: Border.all(color: kNetPayGold.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    displayText(),
                    textAlign: TextAlign.right,
                    style: AppTokens.textStyleResult36.copyWith(
                      color: kNetPayTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 키패드
                ...([
                  ['7', '8', '9'],
                  ['4', '5', '6'],
                  ['1', '2', '3'],
                  ['00', '0', '⌫'],
                ].map((row) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: row.map((key) {
                          final isBack = key == '⌫';
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: isBack
                                      ? backspace
                                      : () => append(key),
                                  onLongPress: isBack
                                      ? () => setModal(() => _input = '')
                                      : null,
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: isBack
                                          ? kNetPayGoldSoft
                                          : kNetPayCardBg,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isBack
                                            ? kNetPayGold.withValues(alpha: 0.4)
                                            : kNetPayCardBorder,
                                      ),
                                    ),
                                    child: Center(
                                      child: isBack
                                          ? Icon(Icons.backspace_outlined,
                                              color: kNetPayGold,
                                              size: AppTokens.sizeKeypadBackspace)
                                          : Text(
                                              key,
                                              style: AppTokens.textStyleKeypadNumber
                                                  .copyWith(color: kNetPayTextPrimary),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ))),
                // 확인 버튼
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      0, 8, 0, MediaQuery.of(ctx).padding.bottom + 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kNetPayAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: confirm,
                      child: Text(
                        '확인',
                        style: AppTokens.textStyleBody.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pageController.addListener(
        () => setState(() => _pageOffset = _pageController.page ?? 1.0));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
              color: kNetPayTextPrimary, size: AppTokens.sizeAppBarBackIcon),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          widget.title,
          style: AppTokens.textStyleAppBarTitle.copyWith(color: kNetPayTextPrimary),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // 배경 그라디언트
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kNetPayBgTop, kNetPayBgBottom],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── 모드 탭 ───────────────────────────────────────────────
                AppAnimatedTabBar(
                  labels: const ['월급', '연봉'],
                  pageOffset: _pageOffset,
                  onTabSelected: _onTabSelected,
                  accentColor: kNetPayGold,
                  dividerColor: kNetPayTabDivider,
                  inactiveColor: kNetPayTextSecondary,
                ),

                // ── 스크롤 영역 ───────────────────────────────────────────
                Expanded(
                  child: ScrollFadeView(
                    fadeColor: kNetPayBgBottom,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.paddingScreenH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 28),

                        // 급여 입력 표시 (슬라이더 포함)
                        _SalaryDisplay(
                          salary: _salary,
                          monthSalary: _monthSalary,
                          isAnnual: _currentTab == 1,
                          fmt: _fmt,
                          onTap: _showKeypadModal,
                          title: _currentTab == 1 ? '연봉' : '월급',
                          sliderValue: _sliderValue,
                          sliderMin: _sliderMin.toDouble(),
                          sliderMax: _sliderMax.toDouble(),
                          sliderMinLabel: _sliderMinLabel,
                          sliderMaxLabel: _sliderMaxLabel,
                          onSliderChanged: (v) => setState(() => _salary = v.round()),
                        ),

                        const SizedBox(height: 28),

                        // 결과
                        _ResultCard(
                          netPay: _netPay,
                          netPayAnnual: _netPayAnnual,
                          isAnnual: _currentTab == 1,
                          fmt: _fmt,
                        ),

                        const SizedBox(height: 12),

                        // 공제 내역
                        _DeductionCard(
                          totalDeduction: _totalDeduction,
                          nationalPension: _nationalPension,
                          healthInsurance: _healthInsurance,
                          longTermCare: _longTermCare,
                          employmentInsurance: _employmentInsurance,
                          incomeTax: _incomeTax,
                          localTax: _localTax,
                          fmt: _fmt,
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ── 고정 하단: 부양가족 ───────────────────────────────────
                _DependentsBar(
                  dependents: _dependents,
                  onDecrease: _dependents > 1
                      ? () => setState(() => _dependents--)
                      : null,
                  onIncrease: _dependents < 11
                      ? () => setState(() => _dependents++)
                      : null,
                ),
              ],
            ),
          ),
          // 상단 블러 오버레이
          BlurStatusBarOverlay(
            isVisible: true,
            backgroundColor: kNetPayBgTop,
          ),

        ],
      ),
    );
  }
}

// ── 급여 입력 표시 ─────────────────────────────────────────────────────────────

class _SalaryDisplay extends StatelessWidget {
  const _SalaryDisplay({
    required this.salary,
    required this.monthSalary,
    required this.isAnnual,
    required this.fmt,
    required this.onTap,
    required this.sliderValue,
    required this.sliderMin,
    required this.sliderMax,
    required this.sliderMinLabel,
    required this.sliderMaxLabel,
    required this.onSliderChanged,
    this.title,
  });

  final int salary;
  final int monthSalary;
  final bool isAnnual;
  final String Function(int) fmt;
  final VoidCallback onTap;
  final double sliderValue;
  final double sliderMin;
  final double sliderMax;
  final String sliderMinLabel;
  final String sliderMaxLabel;
  final ValueChanged<double> onSliderChanged;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: CmInputCard.padding,
        decoration: BoxDecoration(
          color: kNetPayCardBg,
          borderRadius: BorderRadius.circular(CmInputCard.radius),
          border: Border.all(color: kNetPayCardBorder),
          boxShadow: const [
            BoxShadow(color: kNetPayCardShadow, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (title != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title!,
                    style: CmInputCard.titleText.copyWith(color: kNetPayTextSecondary),
                  ),
                  const Icon(Icons.edit_outlined,
                      color: kNetPayTextSecondary, size: CmIcon.inputCard),
                ],
              ),
              const SizedBox(height: CmInputCard.titleSpacing),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    salary > 0 ? fmt(salary) : '0',
                    style: CmInputCard.inputText.copyWith(
                      color: kNetPayTextPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '원',
                  style: CmInputCard.unitText.copyWith(
                      color: kNetPayTextSecondary),
                ),
              ],
            ),
            if (isAnnual && salary > 0) ...[
              const SizedBox(height: CmInputCard.subSpacing),
              Text(
                '월 ${fmt(monthSalary)} 원',
                style: CmInputCard.subText
                    .copyWith(color: kNetPayTextSecondary),
              ),
            ],
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: CmSlider.trackHeight,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: CmSlider.thumbRadius),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: CmSlider.overlayRadius),
                activeTrackColor: kNetPayGold,
                inactiveTrackColor: kNetPaySliderTrack,
                thumbColor: kNetPayGold,
                overlayColor: kNetPayGoldSoft,
              ),
              child: Slider(
                value: sliderValue,
                min: sliderMin,
                max: sliderMax,
                onChanged: onSliderChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(sliderMinLabel,
                      style: CmSlider.rangeLabel.copyWith(color: kNetPayTextSecondary)),
                  Text(sliderMaxLabel,
                      style: CmSlider.rangeLabel.copyWith(color: kNetPayTextSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 결과 카드 ─────────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.netPay,
    required this.netPayAnnual,
    required this.isAnnual,
    required this.fmt,
  });

  final int netPay;
  final int netPayAnnual;
  final bool isAnnual;
  final String Function(int) fmt;

  @override
  Widget build(BuildContext context) {
    final subLabel = isAnnual ? '연 실수령' : '연 환산';
    final subValue = netPayAnnual;

    return Container(
      padding: CmResultCard.padding,
      decoration: BoxDecoration(
        color: kNetPayResultBg,
        borderRadius: BorderRadius.circular(CmResultCard.radius),
        border: Border.all(color: kNetPayResultBorder),
        boxShadow: const [
          BoxShadow(color: kNetPayCardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '실수령액',
              style: CmResultCard.titleText.copyWith(color: kNetPayTextSecondary),
            ),
          ),
          const SizedBox(height: CmResultCard.titleSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  netPay > 0 ? fmt(netPay) : '—',
                  style: CmResultCard.resultText.copyWith(
                    color: kNetPayGold,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              if (netPay > 0) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '원',
                    style: CmResultCard.unitText.copyWith(color: kNetPayTextSecondary),
                  ),
                ),
              ],
            ],
          ),
          if (netPay > 0) ...[
            const SizedBox(height: CmResultCard.subSpacing),
            Text(
              '$subLabel  ${fmt(subValue)} 원',
              style: CmResultCard.subText.copyWith(color: kNetPayTextSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 공제 내역 카드 ────────────────────────────────────────────────────────────

class _DeductionCard extends StatelessWidget {
  const _DeductionCard({
    required this.totalDeduction,
    required this.nationalPension,
    required this.healthInsurance,
    required this.longTermCare,
    required this.employmentInsurance,
    required this.incomeTax,
    required this.localTax,
    required this.fmt,
  });

  final int totalDeduction;
  final int nationalPension;
  final int healthInsurance;
  final int longTermCare;
  final int employmentInsurance;
  final int incomeTax;
  final int localTax;
  final String Function(int) fmt;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('국민연금', nationalPension),
      ('건강보험', healthInsurance),
      ('장기요양', longTermCare),
      ('고용보험', employmentInsurance),
      ('소득세', incomeTax),
      ('지방소득세', localTax),
    ];

    return Container(
      decoration: BoxDecoration(
        color: kNetPayDeductionBg,
        borderRadius: BorderRadius.circular(CmListCard.radius),
        border: Border.all(color: kNetPayDeductionLine),
        boxShadow: const [
          BoxShadow(color: kNetPayCardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          Padding(
            padding: CmListCard.headerPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '공제 합계',
                  style: CmListCard.headerLabel.copyWith(color: kNetPayTextSecondary),
                ),
                Text(
                  totalDeduction > 0 ? '${fmt(totalDeduction)} 원' : '—',
                  style: CmListCard.headerValue.copyWith(color: kNetPayTextPrimary),
                ),
              ],
            ),
          ),
          // 구분선
          Container(height: 1, color: kNetPayDeductionLine),
          // 항목 리스트
          ...items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            final (label, amount) = e.value;
            return Column(
              children: [
                Padding(
                  padding: CmListCard.itemPadding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: CmListCard.itemLabel.copyWith(color: kNetPayTextSecondary),
                      ),
                      Text(
                        amount > 0 ? '${fmt(amount)} 원' : '—',
                        style: CmListCard.itemValue.copyWith(color: kNetPayTextPrimary),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: kNetPayDeductionLine),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── 부양가족 바 (고정 하단) ───────────────────────────────────────────────────

class _DependentsBar extends StatelessWidget {
  const _DependentsBar({
    required this.dependents,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int dependents;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: kNetPayCardBg,
        border: const Border(top: BorderSide(color: kNetPayCardBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '부양가족 수',
                style: rowLabel.copyWith(color: kNetPayTextPrimary),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: '본인 포함 기준, 소득세 계산에 반영됩니다',
                child: Icon(Icons.info_outline,
                    size: CmIcon.tooltip, color: kNetPayTextSecondary),
              ),
            ],
          ),
          Row(
            children: [
              _StepButton(
                icon: Icons.remove,
                enabled: onDecrease != null,
                onTap: onDecrease,
              ),
              Container(
                width: CmStepValue.width,
                margin: EdgeInsets.symmetric(horizontal: CmStepValue.horizontalMargin),
                child: Text(
                  '$dependents명',
                  textAlign: TextAlign.center,
                  style: CmStepValue.text.copyWith(color: kNetPayGold),
                ),
              ),
              _StepButton(
                icon: Icons.add,
                enabled: onIncrease != null,
                onTap: onIncrease,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: CmRoundButton.medium.size,
        height: CmRoundButton.medium.size,
        decoration: BoxDecoration(
          color: enabled ? kNetPayGoldSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(CmRoundButton.medium.radius),
          border: Border.all(
            color: enabled
                ? kNetPayGold.withValues(alpha: 0.4)
                : kNetPayTextDisabled,
          ),
        ),
        child: Icon(
          icon,
          size: CmRoundButton.medium.iconSize,
          color: enabled ? kNetPayGold : kNetPayTextDisabled,
        ),
      ),
    );
  }
}
