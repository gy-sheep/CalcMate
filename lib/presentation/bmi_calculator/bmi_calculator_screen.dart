import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/widgets/ad_banner_placeholder.dart';
import '../../domain/usecases/bmi_calculate_usecase.dart';
import '../widgets/blur_status_bar_overlay.dart';
import '../widgets/scroll_fade_view.dart';
import 'bmi_calculator_viewmodel.dart';
import 'widgets/bmi_category_grid.dart';
import 'widgets/bmi_gauge.dart';
import 'widgets/bmi_healthy_weight_card.dart';
import 'widgets/bmi_input_slider.dart';

// ── 색상 ──────────────────────────────────────────────────────────────────────
const _kBgTop = Color(0xFF1A2E44);
const _kBgBottom = Color(0xFF0D1B2A);
const _kAccent = Color(0xFF4FC3F7);
const _kTextPrimary = Colors.white;
const _kTextSecondary = Color(0xFFB0BEC5);
const _kCardBg = Color(0xFF1E3248);

// ── Screen ────────────────────────────────────────────────────────────────────
class BmiCalculatorScreen extends ConsumerStatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  ConsumerState<BmiCalculatorScreen> createState() =>
      _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends ConsumerState<BmiCalculatorScreen>
    with SingleTickerProviderStateMixin {
  bool _isScrolled = false;
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _needleController;
  late Animation<double> _needleAnim;
  double _prevBmi = 22.4;
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _needleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _needleAnim = AlwaysStoppedAnimation(_bmiToAngle(_prevBmi));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_localeInitialized) {
      _localeInitialized = true;
      final locale = Localizations.localeOf(context);
      ref
          .read(bmiCalculatorViewModelProvider.notifier)
          .handleIntent(BmiCalculatorIntent.initialized(locale));
    }
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 0;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _needleController.dispose();
    super.dispose();
  }

  // ── 바늘 애니메이션 ─────────────────────────────────────────────────────────
  double _bmiToAngle(double bmi) {
    const min = 10.0;
    const max = 40.0;
    final t = ((bmi - min) / (max - min)).clamp(0.0, 1.0);
    return math.pi * (1 - t);
  }

  void _animateNeedle(double newBmi) {
    final from = _bmiToAngle(_prevBmi.clamp(10.0, 40.0));
    final to = _bmiToAngle(newBmi.clamp(10.0, 40.0));
    _needleAnim = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _needleController, curve: Curves.easeOutCubic),
    );
    _needleController
      ..reset()
      ..forward();
    _prevBmi = newBmi;
  }

  // ── 표시 헬퍼 ───────────────────────────────────────────────────────────────
  String _heightLabel(double cm, bool isMetric) {
    if (isMetric) return '${cm.round()} cm';
    return BmiCalculateUseCase.heightToImperial(cm);
  }

  String _weightLabel(double kg, bool isMetric) {
    if (isMetric) return '${kg.toStringAsFixed(1)} kg';
    return BmiCalculateUseCase.weightToImperial(kg);
  }

  // ── 직접 입력 다이얼로그 ────────────────────────────────────────────────────
  Future<void> _editHeight() async {
    final state = ref.read(bmiCalculatorViewModelProvider);
    final result = await _showNumberDialog(
      title: '키 입력',
      suffix: state.isMetric ? 'cm' : 'ft',
      initial: state.isMetric
          ? state.heightCm.round().toString()
          : (state.heightCm / 30.48).toStringAsFixed(1),
    );
    if (result == null) return;
    ref
        .read(bmiCalculatorViewModelProvider.notifier)
        .handleIntent(BmiCalculatorIntent.heightEdited(result));
  }

  Future<void> _editWeight() async {
    final state = ref.read(bmiCalculatorViewModelProvider);
    final result = await _showNumberDialog(
      title: '몸무게 입력',
      suffix: state.isMetric ? 'kg' : 'lb',
      initial: state.isMetric
          ? state.weightKg.toStringAsFixed(1)
          : (state.weightKg * 2.20462).toStringAsFixed(1),
    );
    if (result == null) return;
    ref
        .read(bmiCalculatorViewModelProvider.notifier)
        .handleIntent(BmiCalculatorIntent.weightEdited(result));
  }

  Future<String?> _showNumberDialog({
    required String title,
    required String suffix,
    required String initial,
  }) {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kCardBg,
        title: Text(title,
            style: textStyle16.copyWith(color: _kTextPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: textStyle16.copyWith(color: _kTextPrimary),
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle:
                textStyleCaption.copyWith(color: _kTextSecondary),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _kAccent)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _kAccent, width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('취소',
                style:
                    textStyleCaption.copyWith(color: _kTextSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: Text('확인',
                style: textStyleCaption.copyWith(color: _kAccent)),
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bmiCalculatorViewModelProvider);
    final vm = ref.read(bmiCalculatorViewModelProvider.notifier);
    final result = vm.result;

    // 바늘 애니메이션 트리거
    if (result.bmi != _prevBmi) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateNeedle(result.bmi);
      });
    }

    final isAsian = result.standard == BmiStandard.asian;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _kBgBottom,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleSpacing: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: CmAppBar.backIconSize, color: _kTextPrimary),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text('BMI 계산기',
              style: CmAppBar.titleText.copyWith(color: _kTextPrimary)),
          centerTitle: false,
          actions: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                vm.handleIntent(const BmiCalculatorIntent.unitToggled());
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: CmTab.padding,
                decoration: BoxDecoration(
                  border: Border.all(color: _kAccent.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(CmTab.radius),
                ),
                child: Text(
                  state.isMetric ? 'kg · cm' : 'lb · ft',
                  style: textStyleCaption.copyWith(color: _kAccent),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_kBgTop, _kBgBottom],
              ),
            ),
            child: Column(
          children: [
            Expanded(
              child: ScrollFadeView(
                controller: _scrollController,
                fadeColor: _kBgBottom,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight,
                  bottom: 24,
                  left: screenPaddingH,
                  right: screenPaddingH,
                ),
                child: Column(
                  children: [
                    // ── 게이지 ──────────────────────────────────────────────
                    BmiGauge(
                      bmiAnim: _needleAnim,
                      bmi: result.bmi,
                      category: result.category,
                      categories: result.categories,
                      standardLabel: isAsian
                          ? 'WHO 아시아태평양 기준 (대한비만학회 준용)'
                          : 'WHO 글로벌 기준',
                    ),

                    // ── 키 슬라이더 ─────────────────────────────────────────
                    BmiInputSlider(
                      label: '키',
                      valueLabel: _heightLabel(state.heightCm, state.isMetric),
                      value: state.heightCm,
                      min: 100,
                      max: 220,
                      divisions: 120,
                      accentColor: _kAccent,
                      onChanged: (v) => vm.handleIntent(
                          BmiCalculatorIntent.heightChanged(v)),
                      onValueTap: _editHeight,
                    ),
                    const SizedBox(height: 16),

                    // ── 몸무게 슬라이더 ─────────────────────────────────────
                    BmiInputSlider(
                      label: '몸무게',
                      valueLabel: _weightLabel(state.weightKg, state.isMetric),
                      value: state.weightKg,
                      min: 20,
                      max: 150,
                      divisions: 260,
                      accentColor: _kAccent,
                      onChanged: (v) => vm.handleIntent(
                          BmiCalculatorIntent.weightChanged(v)),
                      onValueTap: _editWeight,
                    ),
                    const SizedBox(height: 20),

                    // ── 건강 체중 범위 카드 ──────────────────────────────────
                    BmiHealthyWeightCard(
                      minKg: result.healthyWeightMinKg,
                      maxKg: result.healthyWeightMaxKg,
                      isInRange: result.isInHealthyRange,
                      isMetric: state.isMetric,
                    ),
                    const SizedBox(height: 16),

                    // ── 범주 그리드 ─────────────────────────────────────────
                    BmiCategoryGrid(
                      categories: result.categories,
                      currentCategory: result.category,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            const AdBannerPlaceholder(),
            SizedBox(height: bottomPad),
          ],
        ),
      ),
          BlurStatusBarOverlay(
            isVisible: _isScrolled,
            backgroundColor: _kBgTop,
          ),
        ],
      ),
    );
  }
}
