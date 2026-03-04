import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../domain/models/date_calculator_state.dart';
import '../../domain/usecases/date_calculate_usecase.dart';
import 'date_calculator_viewmodel.dart';

class DateCalculatorScreen extends ConsumerStatefulWidget {
  const DateCalculatorScreen({super.key});

  @override
  ConsumerState<DateCalculatorScreen> createState() =>
      _DateCalculatorScreenState();
}

class _DateCalculatorScreenState extends ConsumerState<DateCalculatorScreen> {
  late final PageController _pageController;
  double _pageOffset = 0.0;

  static const _bg1 = Color(0xFFFBF0F0);
  static const _bg2 = Color(0xFFF5E2E2);
  static const _bg3 = Color(0xFFEDD1D1);
  static const _accent = Color(0xFF9E4A50);
  static const _cardBg = Color(0xCCFFFFFF);
  static const _cardBorder = Color(0x339E4A50);
  static const _textPrimary = Color(0xFF4A2030);
  static const _textSecondary = Color(0xFF7A4455);
  static const _textTertiary = Color(0xFFB08898);
  static const _divider = Color(0xFFE2C4CC);

  static const _weekdayNames = ['', '월', '화', '수', '목', '금', '토', '일'];

  DateCalculatorViewModel get _vm =>
      ref.read(dateCalculatorViewModelProvider.notifier);

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

  // ── 날짜 포맷 헬퍼 ──────────────────────────────────────

  String _year(DateTime d) => '${d.year}년';
  String _monthDay(DateTime d) => '${d.month}월 ${d.day}일';
  String _weekday(DateTime d) => '${_weekdayNames[d.weekday]}요일';
  String _dateShort(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  // ── 날짜 피커 ───────────────────────────────────────────

  Future<void> _pickDate(
    BuildContext context,
    DateTime initial,
    void Function(DateTime) onPicked,
  ) async {
    final safeInitial = initial.isBefore(DateTime(1900))
        ? DateTime(1900)
        : initial.isAfter(DateTime(2100))
            ? DateTime(2100)
            : initial;
    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF9E4A50),
            onPrimary: Colors.white,
            surface: Color(0xFFFBF0F0),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  // ── 모드 전환 ────────────────────────────────────────────

  void _switchMode(int index) {
    _vm.handleIntent(DateCalculatorIntent.modeChanged(index));
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    _vm.handleIntent(DateCalculatorIntent.modeChanged(index));
  }

  // ── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dateCalculatorViewModelProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bg1, _bg2, _bg3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.paddingScreenH, 0, AppTokens.paddingScreenH, 12),
                child: _buildTabBar(state),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.paddingScreenH),
                      child: _buildPeriodMode(state),
                    ),
                    SizedBox.expand(
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppTokens.paddingScreenH),
                              child: _buildDateCalcMode(state),
                            ),
                          ),
                          _buildKeypad(),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.paddingScreenH),
                      child: _buildDDayMode(state),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: _textPrimary, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        '날짜 계산기',
        style: TextStyle(
          color: _textPrimary,
          fontSize: AppTokens.fontSizeAppBarTitle,
          fontWeight: AppTokens.weightAppBarTitle,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── 탭바 ─────────────────────────────────────────────────

  Widget _buildTabBar(DateCalculatorState state) {
    const labels = ['기간 계산', '날짜 계산', 'D-Day'];
    const tabRowHeight = 40.0;

    return LayoutBuilder(builder: (context, constraints) {
      final tabWidth = constraints.maxWidth / labels.length;
      final page = _pageOffset.clamp(0.0, 2.0);
      final floor = page.floor().clamp(0, labels.length - 2);
      final fraction = (page - floor).clamp(0.0, 1.0);

      // 왼쪽 엣지: easeIn, 오른쪽 엣지: easeOut → 탄성 스트레치 효과
      final leftFraction = Curves.easeInCubic.transform(fraction);
      final rightFraction = Curves.easeOutCubic.transform(fraction);

      const chipPad = 0.18;
      final bgLeft =
          (floor + leftFraction) * tabWidth + tabWidth * chipPad;
      final bgRight =
          (floor + rightFraction) * tabWidth + tabWidth * (1.0 - chipPad);
      final bgWidth = (bgRight - bgLeft).clamp(0.0, constraints.maxWidth);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: tabRowHeight,
            child: Stack(
              children: [
                // 스트레치 배경 칩
                Positioned(
                  left: bgLeft,
                  top: 4,
                  bottom: 4,
                  child: Container(
                    width: bgWidth,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _accent.withValues(alpha: 0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withValues(alpha: 0.25),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                // 탭 레이블
                Row(
                  children: List.generate(labels.length, (i) {
                    final distance =
                        (_pageOffset - i).abs().clamp(0.0, 1.0);
                    final scale = 1.0 + (1.0 - distance) * 0.08;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _switchMode(i),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Transform.scale(
                            scale: scale,
                            child: Text(
                              labels[i],
                              style: TextStyle(
                                color: Color.lerp(
                                    _accent, _textTertiary, distance)!,
                                fontSize: AppTokens.fontSizeBody,
                                fontWeight: distance < 0.5
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          // 스트레치 언더라인
          Stack(
            children: [
              Container(height: 1, color: _divider),
              Positioned(
                left: bgLeft,
                child: Container(
                  width: bgWidth,
                  height: 2,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  // ── 공통 위젯 ──────────────────────────────────────────────

  Widget _buildDateCard(
    String label,
    DateTime date,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: _textSecondary, fontSize: AppTokens.fontSizeLabel),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(AppTokens.radiusCard),
              border: Border.all(color: _cardBorder),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _year(date),
                      style: const TextStyle(
                          color: _textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _monthDay(date),
                      style: const TextStyle(
                        color: _accent,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  _weekday(date),
                  style: const TextStyle(
                      color: _accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right,
                    color: _textTertiary, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(Widget child) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: _cardBorder),
      ),
      child: child,
    );
  }

  Widget _subText(String text) {
    return Text(
      text,
      style: const TextStyle(color: _textSecondary, fontSize: 14),
    );
  }

  // ── 모드 0: 기간 계산 ────────────────────────────────────────

  Widget _buildPeriodMode(DateCalculatorState state) {
    final vm = ref.read(dateCalculatorViewModelProvider.notifier);
    final result = vm.periodResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildResultCard(_buildPeriodResult(result)),
        const SizedBox(height: 16),
        _buildDateCard(
          '시작 날짜',
          state.periodStart,
          () => _pickDate(context, state.periodStart, (d) {
            _vm.handleIntent(DateCalculatorIntent.periodStartChanged(d));
          }),
        ),
        const SizedBox(height: 12),
        _buildDateCard(
          '종료 날짜',
          state.periodEnd,
          () => _pickDate(context, state.periodEnd, (d) {
            _vm.handleIntent(DateCalculatorIntent.periodEndChanged(d));
          }),
        ),
        const SizedBox(height: 12),
        _buildStartDayToggle(state),
        const SizedBox(height: 24),
      ],
    );
  }


  Widget _buildPeriodResult(PeriodResult r) {
    return Column(
      children: [
        Text(
          '${r.totalDays}일',
          style: const TextStyle(
            color: _accent,
            fontSize: 56,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 14),
        const Divider(color: _divider),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _subText('${r.weeks}주 ${r.remainingDaysAfterWeeks}일'),
            Container(width: 1, height: 16, color: _divider),
            _subText('${r.months}개월 ${r.remainingDaysAfterMonths}일'),
          ],
        ),
        const SizedBox(height: 6),
        _subText(
            '${r.years}년 ${r.monthsAfterYears}개월 ${r.daysAfterYearsMonths}일'),
      ],
    );
  }

  Widget _buildStartDayToggle(DateCalculatorState state) {
    final isOn = state.includeStartDay;
    return GestureDetector(
      onTap: () =>
          _vm.handleIntent(const DateCalculatorIntent.includeStartDayToggled()),
      child: Row(
        children: [
          Text(
            '시작일 포함',
            style: const TextStyle(
                color: _textSecondary, fontSize: AppTokens.fontSizeBody),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 24,
            decoration: BoxDecoration(
              color: isOn ? _accent : _divider,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment:
                  isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '기념일 계산 시 ON 권장',
            style: TextStyle(color: _textTertiary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── 모드 1: 날짜 계산 ────────────────────────────────────────

  Widget _buildDateCalcMode(DateCalculatorState state) {
    final vm = ref.read(dateCalculatorViewModelProvider.notifier);
    final result = vm.calcResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildResultCard(_buildDateCalcResult(state, result)),
        const SizedBox(height: 16),
        _buildDateCard(
          '기준 날짜',
          state.calcBase,
          () => _pickDate(context, state.calcBase, (d) {
            _vm.handleIntent(DateCalculatorIntent.calcBaseChanged(d));
          }),
        ),
        const SizedBox(height: 12),
        _buildNumberAndUnit(state),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDateCalcResult(DateCalculatorState state, DateTime result) {
    final now = DateTime.now();
    final todayNorm = DateTime(now.year, now.month, now.day);
    final isToday = state.calcBase == todayNorm;
    const unitNames = ['일', '주', '월', '년'];
    final directionStr = state.calcDirection == 0 ? '후' : '전';
    final baseStr = isToday ? '오늘' : _dateShort(state.calcBase);
    final n = ref.read(dateCalculatorViewModelProvider.notifier).calcNumber;
    final descStr = '$baseStr부터  $n${unitNames[state.calcUnit]} $directionStr';

    return Column(
      children: [
        Text(
          '${result.year}년 ${result.month}월 ${result.day}일',
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _weekday(result),
          style: const TextStyle(
              color: _accent, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        const Divider(color: _divider),
        const SizedBox(height: 10),
        Text(
          descStr,
          style: const TextStyle(
              color: _textSecondary, fontSize: AppTokens.fontSizeBody),
        ),
      ],
    );
  }

  Widget _buildNumberAndUnit(DateCalculatorState state) {
    const units = ['일', '주', '월', '년'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 부호 + 숫자 + 스텝 버튼
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              _buildStepButton(Icons.keyboard_double_arrow_left,
                  () => _vm.handleIntent(const DateCalculatorIntent.numberStepped(-5))),
              const SizedBox(width: 8),
              _buildStepButton(Icons.keyboard_arrow_left,
                  () => _vm.handleIntent(const DateCalculatorIntent.numberStepped(-1))),
              Expanded(
                child: Text(
                  '${state.calcDirection == 0 ? '+' : '−'} ${state.calcNumberInput}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),
              _buildStepButton(Icons.keyboard_arrow_right,
                  () => _vm.handleIntent(const DateCalculatorIntent.numberStepped(1))),
              const SizedBox(width: 8),
              _buildStepButton(Icons.keyboard_double_arrow_right,
                  () => _vm.handleIntent(const DateCalculatorIntent.numberStepped(5))),
            ],
          ),
        ),
        // 단위 버튼
        Row(
          children: List.generate(units.length, (i) {
            final isSelected = state.calcUnit == i;
            return Expanded(
              child: GestureDetector(
                onTap: () =>
                    _vm.handleIntent(DateCalculatorIntent.calcUnitChanged(i)),
                child: Container(
                  margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _accent.withValues(alpha: 0.15)
                        : _cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? _accent.withValues(alpha: 0.5)
                          : _cardBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      units[i],
                      style: TextStyle(
                        color: isSelected ? _accent : _textSecondary,
                        fontSize: AppTokens.fontSizeBody,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _cardBg,
          shape: BoxShape.circle,
          border: Border.all(color: _cardBorder),
        ),
        child: Icon(icon, color: _accent, size: 20),
      ),
    );
  }

  Widget _buildKeypad() {
    const buttons = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['+/-', '0', '⌫'],
    ];
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final row in buttons)
                Row(
                  children: [
                    for (final label in row)
                      Expanded(child: _buildKeyButton(label)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyButton(String label) {
    return GestureDetector(
      onTap: () => _vm.handleIntent(DateCalculatorIntent.keyPressed(label)),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Center(
          child: label == '⌫'
              ? const Icon(Icons.backspace_outlined,
                  color: _textSecondary, size: 20)
              : Text(
                  label,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }

  // ── 모드 2: D-Day ─────────────────────────────────────────────

  Widget _buildDDayMode(DateCalculatorState state) {
    final vm = ref.read(dateCalculatorViewModelProvider.notifier);
    final result = vm.ddayResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildResultCard(_buildDDayResult(result, state.ddayTarget)),
        const SizedBox(height: 16),
        _buildReferenceDateRow(state),
        const SizedBox(height: 12),
        _buildDateCard(
          '목표 날짜',
          state.ddayTarget,
          () => _pickDate(context, state.ddayTarget, (d) {
            _vm.handleIntent(DateCalculatorIntent.ddayTargetChanged(d));
          }),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildReferenceDateRow(DateCalculatorState state) {
    final label = state.ddayRefIsToday ? '기준일 (오늘)' : '기준일';
    return _buildDateCard(
      label,
      state.ddayReference,
      () => _pickDate(context, state.ddayReference, (d) {
        _vm.handleIntent(DateCalculatorIntent.ddayReferenceChanged(d));
      }),
    );
  }

  Widget _buildDDayResult(DDayResult r, DateTime target) {
    final String mainText;
    final Color mainColor;
    if (r.isToday) {
      mainText = 'D-DAY';
      mainColor = const Color(0xFFFFD54F);
    } else if (r.isPast) {
      mainText = 'D + ${r.totalDays.abs()}';
      mainColor = _accent;
    } else {
      mainText = 'D − ${r.totalDays}';
      mainColor = _accent;
    }

    final suffix = r.isPast ? '전' : '후';

    return Column(
      children: [
        Text(
          mainText,
          style: TextStyle(
            color: mainColor,
            fontSize: 48,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
        if (!r.isToday) ...[
          const SizedBox(height: 14),
          const Divider(color: _divider),
          const SizedBox(height: 10),
          _subText(
              '${r.weeks}주 ${r.remainingDaysAfterWeeks}일 $suffix  (${_dateShort(target)})'),
          const SizedBox(height: 4),
          _subText('${r.months}개월 ${r.remainingDaysAfterMonths}일 $suffix'),
        ],
      ],
    );
  }
}
