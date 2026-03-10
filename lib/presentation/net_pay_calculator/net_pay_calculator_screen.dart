import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../domain/models/net_pay_state.dart';
import '../widgets/app_animated_tab_bar.dart';
import '../widgets/blur_status_bar_overlay.dart';
import '../widgets/scroll_fade_view.dart';
import 'net_pay_calculator_colors.dart';
import 'net_pay_calculator_viewmodel.dart';
import 'widgets/adjust_bar.dart';
import 'widgets/deduction_card.dart';
import 'widgets/dependents_bar.dart';
import 'widgets/keypad_modal.dart';
import 'widgets/result_card.dart';
import 'widgets/salary_display.dart';

// ── 슬라이더 범위 ──────────────────────────────────────────────────────────────

const _kMonthlyMin = 1000000;
const _kMonthlyMax = 10000000;
const _kAnnualMin = 24000000;
const _kAnnualMax = 100000000;

// ── Screen ────────────────────────────────────────────────────────────────────

class NetPayCalculatorScreen extends ConsumerStatefulWidget {
  final String title;
  const NetPayCalculatorScreen({super.key, required this.title});

  @override
  ConsumerState<NetPayCalculatorScreen> createState() =>
      _NetPayCalculatorScreenState();
}

class _NetPayCalculatorScreenState
    extends ConsumerState<NetPayCalculatorScreen> {
  double _pageOffset = 1.0; // 0 = 월급, 1 = 연봉

  NetPayViewModel get _vm => ref.read(netPayViewModelProvider.notifier);

  // ── 슬라이더 ──────────────────────────────────────────────────────────────

  int _sliderMin(NetPayState s) =>
      s.mode == SalaryMode.monthly ? _kMonthlyMin : _kAnnualMin;

  int _sliderMax(NetPayState s) =>
      s.mode == SalaryMode.monthly ? _kMonthlyMax : _kAnnualMax;

  double _sliderValue(NetPayState s) =>
      s.salary.clamp(_sliderMin(s), _sliderMax(s)).toDouble();

  String _sliderMinLabel(NetPayState s) =>
      s.mode == SalaryMode.monthly ? '100만' : '2,400만';

  String _sliderMaxLabel(NetPayState s) =>
      s.mode == SalaryMode.monthly ? '1,000만' : '1억';

  // ── 탭 전환 ──────────────────────────────────────────────────────────────

  void _onTabSelected(int index) {
    final mode = index == 0 ? SalaryMode.monthly : SalaryMode.annual;
    _vm.handleIntent(NetPayIntent.tabSwitched(mode));
    setState(() => _pageOffset = index.toDouble());
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(netPayViewModelProvider);
    final isAnnual = state.mode == SalaryMode.annual;

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
          style: AppTokens.textStyleAppBarTitle
              .copyWith(color: kNetPayTextPrimary),
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
                // ── 모드 탭 ─────────────────────────────────────────
                AppAnimatedTabBar(
                  labels: const ['월급', '연봉'],
                  pageOffset: _pageOffset,
                  onTabSelected: _onTabSelected,
                  accentColor: kNetPayGold,
                  dividerColor: kNetPayTabDivider,
                  inactiveColor: kNetPayTextSecondary,
                ),

                // ── 스크롤 영역 ─────────────────────────────────────
                Expanded(
                  child: ScrollFadeView(
                    fadeColor: kNetPayBgBottom,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.paddingScreenH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 28),

                        // 급여 입력 (슬라이더 포함)
                        SalaryDisplay(
                          salary: state.salary,
                          monthSalary: state.monthSalary,
                          isAnnual: isAnnual,
                          onTap: () => showSalaryKeypad(
                            context,
                            initialSalary: state.salary,
                            onConfirm: (v) => _vm.handleIntent(
                                NetPayIntent.directInput(v)),
                          ),
                          sliderValue: _sliderValue(state),
                          sliderMin: _sliderMin(state).toDouble(),
                          sliderMax: _sliderMax(state).toDouble(),
                          sliderMinLabel: _sliderMinLabel(state),
                          sliderMaxLabel: _sliderMaxLabel(state),
                          onSliderChanged: (v) => _vm.handleIntent(
                              NetPayIntent.salaryChanged(v.round())),
                        ),

                        const SizedBox(height: 16),

                        // 미세 조절 바
                        AdjustBar(
                          unit: state.unit,
                          onDecrease: state.salary > 0
                              ? () => _vm.handleIntent(
                                  const NetPayIntent.adjust(-1))
                              : null,
                          onIncrease: () => _vm.handleIntent(
                              const NetPayIntent.adjust(1)),
                          onUnitChanged: (u) => _vm.handleIntent(
                              NetPayIntent.unitChanged(u)),
                        ),

                        const SizedBox(height: 28),

                        // 결과
                        ResultCard(
                          netPay: state.netPay,
                          netPayAnnual: state.netPayAnnual,
                          isAnnual: isAnnual,
                        ),

                        const SizedBox(height: 12),

                        // 공제 내역
                        DeductionCard(
                          totalDeduction: state.totalDeduction,
                          nationalPension: state.nationalPension,
                          healthInsurance: state.healthInsurance,
                          longTermCare: state.longTermCare,
                          employmentInsurance: state.employmentInsurance,
                          incomeTax: state.incomeTax,
                          localTax: state.localTax,
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ── 고정 하단: 부양가족 ─────────────────────────────
                DependentsBar(
                  dependents: state.dependents,
                  onDecrease: state.dependents > 1
                      ? () => _vm.handleIntent(
                          NetPayIntent.dependentsChanged(
                              state.dependents - 1))
                      : null,
                  onIncrease: state.dependents < 11
                      ? () => _vm.handleIntent(
                          NetPayIntent.dependentsChanged(
                              state.dependents + 1))
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
