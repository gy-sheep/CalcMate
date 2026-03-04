import 'package:flutter/material.dart';
import 'package:calcmate/core/theme/app_design_tokens.dart';

class DateCalculatorScreen extends StatefulWidget {
  const DateCalculatorScreen({super.key});

  @override
  State<DateCalculatorScreen> createState() => _DateCalculatorScreenState();
}

class _DateCalculatorScreenState extends State<DateCalculatorScreen> {
  int _mode = 0; // 0=기간계산, 1=날짜계산, 2=D-Day
  int _direction = 0; // 0=더하기, 1=빼기 (모드1)
  int _unit = 0; // 0=일, 1=주, 2=월, 3=년 (모드1)
  bool _showKeypad = false; // 슬라이드업 키패드 (모드1 전용)
  double _pageOffset = 0.0; // PageController 실시간 오프셋

  late final PageController _pageController;

  static const _bg1 = Color(0xFF0D1B2A);
  static const _bg2 = Color(0xFF1B2838);
  static const _bg3 = Color(0xFF243447);
  static const _accent = Color(0xFF4FC3F7);
  static const _cardBg = Color(0x14FFFFFF);
  static const _cardBorder = Color(0x33FFFFFF);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      if (mounted) {
        setState(() => _pageOffset = _pageController.page ?? _mode.toDouble());
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _switchMode(int index) {
    if (_mode == index) return;
    setState(() {
      _mode = index;
      _showKeypad = false;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _mode = index;
      _showKeypad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    AppTokens.paddingScreenH, 0, AppTokens.paddingScreenH, 0),
                child: _buildTabBar(),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.paddingScreenH),
                      child: _buildPeriodMode(),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.paddingScreenH),
                      child: _buildDateCalcMode(),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.paddingScreenH),
                      child: _buildDDayMode(),
                    ),
                  ],
                ),
              ),
              // 키패드: PageView 밖, 모드1에서만 슬라이드업
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  heightFactor: (_mode == 1 && _showKeypad) ? 1.0 : 0.0,
                  child: _buildKeypad(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        '날짜 계산기',
        style: TextStyle(
          color: Colors.white,
          fontSize: AppTokens.fontSizeAppBarTitle,
          fontWeight: AppTokens.weightAppBarTitle,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── 탭바 ───────────────────────────────────────────────

  Widget _buildTabBar() {
    const labels = ['기간 계산', '날짜 계산', 'D-Day'];
    const tabRowHeight = 40.0;

    return LayoutBuilder(builder: (context, constraints) {
      final tabWidth = constraints.maxWidth / labels.length;
      final page = _pageOffset.clamp(0.0, 2.0);
      final floor = page.floor().clamp(0, labels.length - 2);
      final fraction = (page - floor).clamp(0.0, 1.0);

      // 왼쪽 엣지: easeIn (느리게 출발 → 따라옴)
      // 오른쪽 엣지: easeOut (빠르게 출발 → 앞서감) → 탄성 스트레치 효과
      final leftFraction = Curves.easeInCubic.transform(fraction);
      final rightFraction = Curves.easeOutCubic.transform(fraction);

      // 배경 칩: 텍스트를 감싸는 크기 (탭 좌우 18% 패딩)
      const chipPad = 0.18;
      final bgLeft = (floor + leftFraction) * tabWidth + tabWidth * chipPad;
      final bgRight = (floor + rightFraction) * tabWidth + tabWidth * (1.0 - chipPad);
      final bgWidth = (bgRight - bgLeft).clamp(0.0, constraints.maxWidth);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: tabRowHeight,
            child: Stack(
              children: [
                // 스트레치 배경 칩 (글로우 포함)
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
                // 탭 레이블 (스케일 애니메이션)
                Row(
                  children: List.generate(labels.length, (i) {
                    final distance = (_pageOffset - i).abs().clamp(0.0, 1.0);
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
                                color: Color.lerp(_accent, Colors.white38, distance)!,
                                fontSize: AppTokens.fontSizeBody,
                                fontWeight: distance < 0.5 ? FontWeight.w600 : FontWeight.w400,
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
          // 스트레치 언더라인 (글로우 포함)
          Stack(
            children: [
              Container(height: 1, color: Colors.white12),
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

  // ── 공통 위젯 ──────────────────────────────────────────

  Widget _buildDateCard(String label, String year, String date, String weekday) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: AppTokens.fontSizeLabel),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    year,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                weekday,
                style: TextStyle(color: _accent, fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: _cardBorder),
      ),
      child: child,
    );
  }

  // ── 모드 0: 기간 계산 ──────────────────────────────────

  Widget _buildPeriodMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildResultCard(_buildPeriodResult()),
        const SizedBox(height: 16),
        _buildDateCard('시작 날짜', '2026년', '3월 4일', '수요일'),
        const SizedBox(height: 8),
        _buildSwapButton(),
        const SizedBox(height: 8),
        _buildDateCard('종료 날짜', '2026년', '12월 31일', '목요일'),
        const SizedBox(height: 12),
        _buildStartDayToggle(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSwapButton() {
    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _cardBg,
          border: Border.all(color: _cardBorder),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.swap_vert, color: Colors.white54, size: 18),
      ),
    );
  }

  Widget _buildPeriodResult() {
    return Column(
      children: [
        Text(
          '301일',
          style: TextStyle(
            color: _accent,
            fontSize: 56,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 14),
        const Divider(color: Colors.white12),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _subText('43주 0일'),
            Container(width: 1, height: 16, color: Colors.white12),
            _subText('9개월 27일'),
          ],
        ),
        const SizedBox(height: 6),
        _subText('0년 9개월 27일'),
      ],
    );
  }

  Widget _buildStartDayToggle() {
    return Row(
      children: [
        const Text(
          '시작일 포함',
          style: TextStyle(color: Colors.white54, fontSize: AppTokens.fontSizeBody),
        ),
        const SizedBox(width: 8),
        Container(
          width: 42,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Colors.white38,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '기념일 계산 시 ON 권장',
          style: TextStyle(color: Colors.white24, fontSize: 11),
        ),
      ],
    );
  }

  // ── 모드 1: 날짜 계산 ──────────────────────────────────

  Widget _buildDateCalcMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildResultCard(_buildDateCalcResult()),
        const SizedBox(height: 16),
        _buildDateCard('기준 날짜', '2026년', '3월 4일', '수요일'),
        const SizedBox(height: 12),
        _buildDirectionSegment(),
        const SizedBox(height: 12),
        _buildNumberAndUnit(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDirectionSegment() {
    const labels = ['+ 더하기', '− 빼기'];
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(2, (i) {
          final isSelected = _direction == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _direction = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected ? Border.all(color: Colors.white24) : null,
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white38,
                      fontSize: AppTokens.fontSizeBody,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNumberAndUnit() {
    const units = ['일', '주', '월', '년'];
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showKeypad = true),
          child: Container(
            width: 100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(AppTokens.radiusCard),
              border: Border.all(
                color: _showKeypad
                    ? _accent.withValues(alpha: 0.8)
                    : _accent.withValues(alpha: 0.5),
                width: _showKeypad ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              '100',
              style: TextStyle(
                color: _accent,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: List.generate(units.length, (i) {
              final isSelected = _unit == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _unit = i),
                  child: Container(
                    margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? _accent.withValues(alpha: 0.15) : _cardBg,
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
                          color: isSelected ? _accent : Colors.white54,
                          fontSize: AppTokens.fontSizeBody,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDateCalcResult() {
    return Column(
      children: [
        const Text(
          '2026년 6월 12일',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '금요일',
          style: TextStyle(color: _accent, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        const Divider(color: Colors.white12),
        const SizedBox(height: 10),
        const Text(
          '오늘부터  100일 후',
          style: TextStyle(color: Colors.white54, fontSize: AppTokens.fontSizeBody),
        ),
      ],
    );
  }

  Widget _buildKeypad() {
    const buttons = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['00', '0', '⌫'],
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: const Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: buttons.map((row) {
          return Row(
            children: row.map((label) {
              return Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                      bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: label == '⌫' ? Colors.white54 : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  // ── 모드 2: D-Day ──────────────────────────────────────

  Widget _buildDDayMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildResultCard(_buildDDayResult()),
        const SizedBox(height: 16),
        _buildDateCard('목표 날짜', '2027년', '1월 1일', '금요일'),
        const SizedBox(height: 12),
        _buildReferenceDateRow(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildReferenceDateRow() {
    return Row(
      children: [
        const Text(
          '기준일',
          style: TextStyle(color: Colors.white38, fontSize: AppTokens.fontSizeBody),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(AppTokens.radiusChip),
            border: Border.all(color: _cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '오늘  (2026.03.04)',
                style: TextStyle(color: Colors.white70, fontSize: AppTokens.fontSizeBody),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: Colors.white38, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDDayResult() {
    return Column(
      children: [
        Text(
          'D − 302',
          style: TextStyle(
            color: _accent,
            fontSize: 48,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 14),
        const Divider(color: Colors.white12),
        const SizedBox(height: 10),
        _subText('43주 1일 후  (2027.01.01)'),
        const SizedBox(height: 4),
        _subText('9개월 28일 후'),
      ],
    );
  }

  // ── 공통 헬퍼 ──────────────────────────────────────────

  Widget _subText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white54, fontSize: 14),
    );
  }
}
