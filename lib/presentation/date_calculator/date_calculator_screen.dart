import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../core/widgets/ad_banner_placeholder.dart';
import '../../presentation/widgets/scroll_fade_view.dart';
import 'date_calculator_colors.dart';
import 'date_calculator_viewmodel.dart';
import 'widgets/date_calc_mode_view.dart';
import 'widgets/date_tab_bar.dart';
import 'widgets/dday_mode_view.dart';
import 'widgets/period_mode_view.dart';

class DateCalculatorScreen extends ConsumerStatefulWidget {
  const DateCalculatorScreen({super.key});

  @override
  ConsumerState<DateCalculatorScreen> createState() =>
      _DateCalculatorScreenState();
}

class _DateCalculatorScreenState extends ConsumerState<DateCalculatorScreen> {
  late final PageController _pageController;
  double _pageOffset = 0.0;

  final _fadeKeyPeriod = GlobalKey<ScrollFadeViewState>();
  final _fadeKeyDateCalc = GlobalKey<ScrollFadeViewState>();
  final _fadeKeyDDay = GlobalKey<ScrollFadeViewState>();

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (index) {
        case 0: _fadeKeyPeriod.currentState?.checkFade();
        case 1: _fadeKeyDateCalc.currentState?.checkFade();
        case 2: _fadeKeyDDay.currentState?.checkFade();
      }
    });
  }

  // ── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.watch(dateCalculatorViewModelProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kDateBg1, kDateBg2, kDateBg3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    screenPaddingH, 0, screenPaddingH, 12),
                child: DateTabBar(
                  pageOffset: _pageOffset,
                  onTabSelected: _switchMode,
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    ScrollFadeView(
                      key: _fadeKeyPeriod,
                      fadeColor: kDateBg3,
                      padding: const EdgeInsets.symmetric(
                          horizontal: screenPaddingH),
                      child: PeriodModeView(pickDate: _pickDate),
                    ),
                    ScrollFadeView(
                      key: _fadeKeyDateCalc,
                      fadeColor: kDateBg3,
                      padding: const EdgeInsets.symmetric(
                          horizontal: screenPaddingH),
                      child: DateCalcModeView(pickDate: _pickDate),
                    ),
                    ScrollFadeView(
                      key: _fadeKeyDDay,
                      fadeColor: kDateBg3,
                      padding: const EdgeInsets.symmetric(
                          horizontal: screenPaddingH),
                      child: DDayModeView(pickDate: _pickDate),
                    ),
                  ],
                ),
              ),
              const AdBannerPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleSpacing: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: kDateTextPrimary, size: CmAppBar.backIconSize),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        '날짜 계산기',
        style: CmAppBar.titleText.copyWith(color: kDateTextPrimary),
      ),
      centerTitle: false,
    );
  }
}
