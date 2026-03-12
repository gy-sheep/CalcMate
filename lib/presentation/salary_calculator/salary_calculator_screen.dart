import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../domain/models/salary_calculator_state.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/app_animated_tab_bar.dart';
import '../widgets/blur_status_bar_overlay.dart';
import '../widgets/scroll_fade_view.dart';
import 'salary_calculator_colors.dart';
import 'salary_calculator_viewmodel.dart';
import 'widgets/deduction_card.dart';
import 'widgets/dependents_bar.dart';
import 'widgets/keypad_modal.dart';
import 'widgets/result_card.dart';
import 'widgets/salary_display.dart';

// ── 슬라이더 범위 ──────────────────────────────────────────────────────────────

const _kMonthlyMin = 1000000;
const _kMonthlyMax = 10000000;
const _kMonthlyStep = 100000; // 10만 단위
const _kAnnualMin = 20000000;
const _kAnnualMax = 300000000;
const _kAnnualStep = 1000000; // 100만 단위

// ── Screen ────────────────────────────────────────────────────────────────────

class SalaryCalculatorScreen extends ConsumerStatefulWidget {
  final String title;
  const SalaryCalculatorScreen({super.key, required this.title});

  @override
  ConsumerState<SalaryCalculatorScreen> createState() =>
      _SalaryCalculatorScreenState();
}

class _SalaryCalculatorScreenState
    extends ConsumerState<SalaryCalculatorScreen> {
  late final PageController _pageController;
  double _pageOffset = 0.0; // 0 = 월급, 1 = 연봉

  SalaryCalculatorViewModel get _vm => ref.read(salaryCalculatorViewModelProvider.notifier);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      if (mounted) {
        setState(() => _pageOffset = _pageController.page ?? _pageOffset);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── 슬라이더 ──────────────────────────────────────────────────────────────

  int _sliderMin(SalaryCalculatorState s) =>
      s.mode == SalaryMode.monthly ? _kMonthlyMin : _kAnnualMin;

  int _sliderMax(SalaryCalculatorState s) =>
      s.mode == SalaryMode.monthly ? _kMonthlyMax : _kAnnualMax;

  int _sliderDivisions(SalaryCalculatorState s) =>
      s.mode == SalaryMode.monthly
          ? (_kMonthlyMax - _kMonthlyMin) ~/ _kMonthlyStep
          : (_kAnnualMax - _kAnnualMin) ~/ _kAnnualStep;

  double _sliderValue(SalaryCalculatorState s) =>
      s.salary.clamp(_sliderMin(s), _sliderMax(s)).toDouble();

  String _sliderMinLabel(SalaryCalculatorState s, AppLocalizations l10n) =>
      s.mode == SalaryMode.monthly
          ? l10n.salary_slider_monthlyMin
          : l10n.salary_slider_annualMin;

  String _sliderMaxLabel(SalaryCalculatorState s, AppLocalizations l10n) =>
      s.mode == SalaryMode.monthly
          ? l10n.salary_slider_monthlyMax
          : l10n.salary_slider_annualMax;

  // ── 탭 전환 ──────────────────────────────────────────────────────────────

  void _onTabSelected(int index) {
    final mode = index == 0 ? SalaryMode.monthly : SalaryMode.annual;
    _vm.handleIntent(SalaryCalculatorIntent.tabSwitched(mode));
    _pageController.animateToPage(
      index,
      duration: durationAnimSlow,
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    final mode = index == 0 ? SalaryMode.monthly : SalaryMode.annual;
    _vm.handleIntent(SalaryCalculatorIntent.tabSwitched(mode));
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salaryCalculatorViewModelProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,  // 밝은 배경 → 어두운 아이콘
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: kSalaryTextPrimary, size: CmAppBar.backIconSize),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          widget.title,
          style: CmAppBar.titleText.copyWith(color: kSalaryTextPrimary),
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
                colors: [kSalaryBg1, kSalaryBg2],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── 모드 탭 ─────────────────────────────────────────
                AppAnimatedTabBar(
                  labels: [l10n.salary_tab_monthly, l10n.salary_tab_annual],
                  pageOffset: _pageOffset,
                  onTabSelected: _onTabSelected,
                  accentColor: kSalaryAccent,
                  dividerColor: kSalaryTabDivider,
                  inactiveColor: kSalaryTextSecondary,
                ),

                // ── 스와이프 영역 ─────────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: [
                      _buildContent(state, isAnnual: false),
                      _buildContent(state, isAnnual: true),
                    ],
                  ),
                ),

                // ── 고정 하단: 부양가족 ─────────────────────────────
                DependentsBar(
                  dependents: state.dependents,
                  onDecrease: state.dependents > 1
                      ? () => _vm.handleIntent(
                          SalaryCalculatorIntent.dependentsChanged(
                              state.dependents - 1))
                      : null,
                  onIncrease: state.dependents < 11
                      ? () => _vm.handleIntent(
                          SalaryCalculatorIntent.dependentsChanged(
                              state.dependents + 1))
                      : null,
                ),
              ],
            ),
          ),
          // 상단 블러 오버레이
          BlurStatusBarOverlay(
            isVisible: true,
            backgroundColor: kSalaryBg1,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SalaryCalculatorState state, {required bool isAnnual}) {
    final l10n = AppLocalizations.of(context);
    return ScrollFadeView(
      fadeColor: kSalaryBg2,
      padding: const EdgeInsets.symmetric(
          horizontal: screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: spacingSection),

          // 급여 입력 (슬라이더 포함)
          SalaryDisplay(
            salary: state.salary,
            monthSalary: state.monthSalary,
            isAnnual: isAnnual,
            onTap: () => showSalaryKeypad(
              context,
              initialSalary: state.salary,
              onConfirm: (v) => _vm.handleIntent(
                  SalaryCalculatorIntent.directInput(v)),
            ),
            sliderValue: _sliderValue(state),
            sliderMin: _sliderMin(state).toDouble(),
            sliderMax: _sliderMax(state).toDouble(),
            sliderDivisions: _sliderDivisions(state),
            sliderMinLabel: _sliderMinLabel(state, l10n),
            sliderMaxLabel: _sliderMaxLabel(state, l10n),
            onSliderChanged: (v) => _vm.handleIntent(
                SalaryCalculatorIntent.salaryChanged(v.round())),
          ),

          const SizedBox(height: spacingSection),

          // 결과
          ResultCard(
            netPay: state.netPay,
            netPayAnnual: state.netPayAnnual,
            isAnnual: isAnnual,
          ),

          const SizedBox(height: spacingSection),

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

          const SizedBox(height: spacingSection),
        ],
      ),
    );
  }
}
