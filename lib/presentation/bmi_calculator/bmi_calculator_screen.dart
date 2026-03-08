import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_design_tokens.dart';
import '../widgets/scroll_fade_view.dart';

// ── 색상 ──────────────────────────────────────────────────────────────────────
const _kBgTop = Color(0xFF1A2E44);
const _kBgBottom = Color(0xFF0D1B2A);
const _kAccent = Color(0xFF4FC3F7);
const _kTextPrimary = Colors.white;
const _kTextSecondary = Color(0xFFB0BEC5);
const _kCardBg = Color(0xFF1E3248);
const _kSliderTrack = Color(0xFF2A4060);

// ── BMI 기준 ──────────────────────────────────────────────────────────────────

/// 범주 정의 (기준마다 개수·임계값 다름)
class BmiCategoryDef {
  const BmiCategoryDef({
    required this.label,
    required this.rangeLabel,
    required this.color,
    required this.min,
    required this.max, // 마지막 범주는 double.infinity
  });

  final String label;
  final String rangeLabel;
  final Color color;
  final double min;
  final double max;

  bool contains(double bmi) => bmi >= min && bmi < max;
}

/// WHO 글로벌 기준 (4범주)
const _kGlobalCategories = [
  BmiCategoryDef(
    label: '저체중', rangeLabel: '18.5 미만',
    color: Color(0xFF5B9BD5), min: 0, max: 18.5,
  ),
  BmiCategoryDef(
    label: '정상 체중', rangeLabel: '18.5 – 24.9',
    color: Color(0xFF4CAF50), min: 18.5, max: 25.0,
  ),
  BmiCategoryDef(
    label: '과체중', rangeLabel: '25.0 – 29.9',
    color: Color(0xFFFF9800), min: 25.0, max: 30.0,
  ),
  BmiCategoryDef(
    label: '비만', rangeLabel: '30.0 이상',
    color: Color(0xFFF44336), min: 30.0, max: double.infinity,
  ),
];

/// WHO 아시아태평양 기준 (대한비만학회 준용, 5범주)
const _kAsianCategories = [
  BmiCategoryDef(
    label: '저체중', rangeLabel: '18.5 미만',
    color: Color(0xFF5B9BD5), min: 0, max: 18.5,
  ),
  BmiCategoryDef(
    label: '정상', rangeLabel: '18.5 – 22.9',
    color: Color(0xFF4CAF50), min: 18.5, max: 23.0,
  ),
  BmiCategoryDef(
    label: '과체중', rangeLabel: '23.0 – 24.9',
    color: Color(0xFFFFCC02), min: 23.0, max: 25.0,
  ),
  BmiCategoryDef(
    label: '비만 1단계', rangeLabel: '25.0 – 29.9',
    color: Color(0xFFFF9800), min: 25.0, max: 30.0,
  ),
  BmiCategoryDef(
    label: '비만 2단계', rangeLabel: '30.0 이상',
    color: Color(0xFFF44336), min: 30.0, max: double.infinity,
  ),
];

/// 아시아태평양 기준을 적용할 국가코드 목록
const _kAsianCountryCodes = {
  'KR', 'JP', 'CN', 'TW', 'HK', 'MO', 'SG',
  'MY', 'TH', 'VN', 'PH', 'ID', 'KH', 'MM', 'BD',
};

List<BmiCategoryDef> _categoriesForLocale(Locale locale) {
  final code = locale.countryCode ?? '';
  return _kAsianCountryCodes.contains(code)
      ? _kAsianCategories
      : _kGlobalCategories;
}

BmiCategoryDef _categoryOf(double bmi, List<BmiCategoryDef> cats) {
  return cats.lastWhere((c) => bmi >= c.min, orElse: () => cats.first);
}

// ── Screen ────────────────────────────────────────────────────────────────────
class BmiCalculatorScreen extends StatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen>
    with SingleTickerProviderStateMixin {
  double _heightCm = 170;
  double _weightKg = 65;
  bool _isMetric = true;
  bool _isScrolled = false;

  final ScrollController _scrollController = ScrollController();
  late final AnimationController _needleController;
  late Animation<double> _needleAnim;
  double _prevBmi = 22.4;

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

  // ── 계산 ───────────────────────────────────────────────────────────────────
  double get _bmi {
    final hm = _heightCm / 100;
    if (hm <= 0) return 0;
    return _weightKg / (hm * hm);
  }

  double _healthyMin(List<BmiCategoryDef> cats) {
    // 정상 범주의 min
    final normal = cats.firstWhere((c) => c.label.startsWith('정상'));
    return normal.min * (_heightCm / 100) * (_heightCm / 100);
  }

  double _healthyMax(List<BmiCategoryDef> cats) {
    // 정상 범주의 max
    final normal = cats.firstWhere((c) => c.label.startsWith('정상'));
    final maxBmi = normal.max == double.infinity ? 24.9 : normal.max;
    return maxBmi * (_heightCm / 100) * (_heightCm / 100);
  }

  bool _inHealthyRange(List<BmiCategoryDef> cats) {
    return _weightKg >= _healthyMin(cats) && _weightKg <= _healthyMax(cats);
  }

  void _onBmiChanged() {
    final newBmi = _bmi;
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

  double _bmiToAngle(double bmi) {
    const min = 10.0;
    const max = 40.0;
    final t = ((bmi - min) / (max - min)).clamp(0.0, 1.0);
    return math.pi * (1 - t);
  }

  // ── 단위 ───────────────────────────────────────────────────────────────────
  String get _heightLabel {
    if (_isMetric) return '${_heightCm.round()} cm';
    final totalIn = _heightCm / 2.54;
    final ft = totalIn ~/ 12;
    final inch = (totalIn % 12).round();
    return '$ft ft $inch in';
  }

  String get _weightLabel {
    if (_isMetric) return '${_weightKg.toStringAsFixed(1)} kg';
    return '${(_weightKg * 2.20462).toStringAsFixed(1)} lb';
  }

  void _setHeight(double v) {
    setState(() => _heightCm = v);
    _onBmiChanged();
  }

  void _setWeight(double v) {
    setState(() => _weightKg = v);
    _onBmiChanged();
  }

  void _toggleUnit() {
    HapticFeedback.lightImpact();
    setState(() => _isMetric = !_isMetric);
  }

  // ── 직접 입력 ───────────────────────────────────────────────────────────────
  Future<void> _editHeight() async {
    final result = await _showNumberDialog(
      title: '키 입력',
      suffix: _isMetric ? 'cm' : 'ft',
      initial: _isMetric
          ? _heightCm.round().toString()
          : (_heightCm / 30.48).toStringAsFixed(1),
    );
    if (result == null) return;
    final v = double.tryParse(result);
    if (v == null) return;
    final cm = _isMetric ? v : v * 30.48;
    _setHeight(cm.clamp(100, 220).toDouble());
  }

  Future<void> _editWeight() async {
    final result = await _showNumberDialog(
      title: '몸무게 입력',
      suffix: _isMetric ? 'kg' : 'lb',
      initial: _isMetric
          ? _weightKg.toStringAsFixed(1)
          : (_weightKg * 2.20462).toStringAsFixed(1),
    );
    if (result == null) return;
    final v = double.tryParse(result);
    if (v == null) return;
    final kg = _isMetric ? v : v / 2.20462;
    _setWeight(kg.clamp(20, 150).toDouble());
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
            style: AppTokens.textStyleValue.copyWith(color: _kTextPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTokens.textStyleValue.copyWith(color: _kTextPrimary),
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle:
                AppTokens.textStyleCaption.copyWith(color: _kTextSecondary),
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
                    AppTokens.textStyleCaption.copyWith(color: _kTextSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: Text('확인',
                style: AppTokens.textStyleCaption.copyWith(color: _kAccent)),
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final categories = _categoriesForLocale(locale);
    final isAsian = categories.length == 5;

    final bmi = _bmi;
    final category = _categoryOf(bmi, categories);
    final healthyMin = _healthyMin(categories);
    final healthyMax = _healthyMax(categories);
    final inRange = _inHealthyRange(categories);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _kBgBottom,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: _isScrolled
                ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: _isScrolled
                  ? _kBgTop.withValues(alpha: 0.85)
                  : Colors.transparent,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      size: AppTokens.sizeAppBarBackIcon, color: _kTextPrimary),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                title: Text('BMI 계산기',
                    style: AppTokens.textStyleAppBarTitle
                        .copyWith(color: _kTextPrimary)),
                centerTitle: true,
                actions: [
                  GestureDetector(
                    onTap: _toggleUnit,
                    child: Container(
                      margin: const EdgeInsets.only(
                          right: AppTokens.paddingAppBarH),
                      padding: AppTokens.paddingChip,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _kAccent.withValues(alpha: 0.5)),
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusChip),
                      ),
                      child: Text(
                        _isMetric ? 'kg · cm' : 'lb · ft',
                        style: AppTokens.textStyleCaption
                            .copyWith(color: _kAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_kBgTop, _kBgBottom],
          ),
        ),
        child: ScrollFadeView(
          controller: _scrollController,
          fadeColor: _kBgBottom,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
            bottom: bottomPad + 24,
            left: AppTokens.paddingScreenH,
            right: AppTokens.paddingScreenH,
          ),
          child: Column(
            children: [
              // ── 게이지 ────────────────────────────────────────────────────
              _BmiGauge(
                bmiAnim: _needleAnim,
                bmi: bmi,
                category: category,
                categories: categories,
                standardLabel: isAsian
                    ? 'WHO 아시아태평양 기준 (대한비만학회 준용)'
                    : 'WHO 글로벌 기준',
              ),

              // ── 키 슬라이더 ───────────────────────────────────────────────
              _InputSlider(
                label: '키',
                valueLabel: _heightLabel,
                value: _heightCm,
                min: 100,
                max: 220,
                divisions: 120,
                accentColor: _kAccent,
                onChanged: _setHeight,
                onValueTap: _editHeight,
              ),
              const SizedBox(height: 16),

              // ── 몸무게 슬라이더 ───────────────────────────────────────────
              _InputSlider(
                label: '몸무게',
                valueLabel: _weightLabel,
                value: _weightKg,
                min: 20,
                max: 150,
                divisions: 260,
                accentColor: _kAccent,
                onChanged: _setWeight,
                onValueTap: _editWeight,
              ),
              const SizedBox(height: 20),

              // ── 건강 체중 범위 카드 ────────────────────────────────────────
              _HealthyWeightCard(
                minKg: healthyMin,
                maxKg: healthyMax,
                isInRange: inRange,
                isMetric: _isMetric,
              ),
              const SizedBox(height: 16),

              // ── 범주 그리드 ───────────────────────────────────────────────
              _CategoryGrid(
                categories: categories,
                currentCategory: category,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── BMI 게이지 ─────────────────────────────────────────────────────────────────
class _BmiGauge extends StatelessWidget {
  const _BmiGauge({
    required this.bmiAnim,
    required this.bmi,
    required this.category,
    required this.categories,
    required this.standardLabel,
  });

  final Animation<double> bmiAnim;
  final double bmi;
  final BmiCategoryDef category;
  final List<BmiCategoryDef> categories;
  final String standardLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
    // 아크 지름 = 카드 width, 높이 = 반지름 + 상단 여백 8px
    final gaugeHeight = constraints.maxWidth / 2 + 8;
    return SizedBox(
      height: gaugeHeight,
      child: AnimatedBuilder(
        animation: bmiAnim,
        builder: (context0, _) => Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _GaugePainter(
                  needleAngle: bmiAnim.value,
                  categories: categories,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: bmi),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    builder: (context1, v, _) => Text(
                      v.toStringAsFixed(1),
                      textAlign: TextAlign.center,
                      style: AppTokens.textStyleResult52
                          .copyWith(color: _kTextPrimary),
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      category.label,
                      key: ValueKey(category.label),
                      textAlign: TextAlign.center,
                      style: AppTokens.textStyleValue
                          .copyWith(color: category.color),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    standardLabel,
                    textAlign: TextAlign.center,
                    style: AppTokens.textStyleLabelSmall
                        .copyWith(color: _kTextSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    });
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.needleAngle,
    required this.categories,
  });

  final double needleAngle;
  final List<BmiCategoryDef> categories;

  static const _bmiMin = 10.0;
  static const _bmiMax = 40.0;

  /// 수학 좌표계 (y-up): 바늘·경계선용. π(좌) → 0(우), 상반원.
  double _bmiToRad(double bmi) {
    final t = ((bmi - _bmiMin) / (_bmiMax - _bmiMin)).clamp(0.0, 1.0);
    return math.pi * (1 - t);
  }

  /// Flutter canvas (y-down, clockwise): drawArc용. π(좌) → 2π(우), 상반원.
  double _bmiToArc(double bmi) {
    final t = ((bmi - _bmiMin) / (_bmiMax - _bmiMin)).clamp(0.0, 1.0);
    return math.pi * (1 + t);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // 캔버스 하단 끝 = 반원 상단만 노출 (SizedBox가 자동 클리핑)
    final cy = size.height;
    final outerR = size.width / 2 - 8;
    final innerR = outerR * 0.72;
    final arcR = (outerR + innerR) / 2;
    final arcW = outerR - innerR;

    // 트랙 배경
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: arcR),
      math.pi, math.pi, false,
      Paint()
        ..color = _kSliderTrack
        ..style = PaintingStyle.stroke
        ..strokeWidth = arcW
        ..strokeCap = StrokeCap.butt,
    );

    // 컬러 구간 (drawArc용 Flutter canvas 각도 사용)
    for (final cat in categories) {
      final fromBmi = cat.min.clamp(_bmiMin, _bmiMax);
      final toBmi = cat.max == double.infinity
          ? _bmiMax
          : cat.max.clamp(_bmiMin, _bmiMax);
      final startAngle = _bmiToArc(fromBmi);
      final sweepAngle = _bmiToArc(toBmi) - _bmiToArc(fromBmi);

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: arcR),
        startAngle, sweepAngle, false,
        Paint()
          ..color = cat.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = arcW - 3
          ..strokeCap = StrokeCap.butt,
      );
    }

    // 구간 경계선
    for (final cat in categories.skip(1)) {
      final angle = _bmiToRad(cat.min);
      final ox = cx + outerR * math.cos(angle);
      final oy = cy - outerR * math.sin(angle);
      final ix = cx + innerR * math.cos(angle);
      final iy = cy - innerR * math.sin(angle);
      canvas.drawLine(
        Offset(ix, iy), Offset(ox, oy),
        Paint()
          ..color = _kBgBottom.withValues(alpha: 0.7)
          ..strokeWidth = 2,
      );
    }

    // 바늘
    final nx = cx + outerR * 0.95 * math.cos(needleAngle);
    final ny = cy - outerR * 0.95 * math.sin(needleAngle);
    final bx = cx + innerR * 0.55 * math.cos(needleAngle);
    final by = cy - innerR * 0.55 * math.sin(needleAngle);
    canvas.drawLine(
      Offset(bx, by), Offset(nx, ny),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(cx, cy), 6, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = _kBgBottom);

    // 아크 위 레이블은 하단 _CategoryGrid에서 표시하므로 생략
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.needleAngle != needleAngle || old.categories != categories;
}

// ── 슬라이더 ───────────────────────────────────────────────────────────────────
class _InputSlider extends StatelessWidget {
  const _InputSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.accentColor,
    required this.onChanged,
    required this.onValueTap,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color accentColor;
  final ValueChanged<double> onChanged;
  final VoidCallback onValueTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTokens.paddingCard,
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: AppTokens.textStyleSectionTitle
                      .copyWith(color: _kTextSecondary)),
              GestureDetector(
                onTap: onValueTap,
                child: Container(
                  padding: AppTokens.paddingChip,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppTokens.radiusChip),
                    border: Border.all(
                        color: accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(valueLabel,
                          style: AppTokens.textStyleValue
                              .copyWith(color: accentColor)),
                      const SizedBox(width: 4),
                      Icon(Icons.edit_outlined,
                          size: AppTokens.sizeIconXSmall,
                          color: accentColor.withValues(alpha: 0.7)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: accentColor,
              inactiveTrackColor: _kSliderTrack,
              thumbColor: Colors.white,
              overlayColor: accentColor.withValues(alpha: 0.15),
              thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: AppTokens.radiusSliderThumb),
              trackHeight: AppTokens.heightSliderTrack,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${min.round()}',
                  style: AppTokens.textStyleCaption
                      .copyWith(color: _kTextSecondary)),
              Text('${max.round()}',
                  style: AppTokens.textStyleCaption
                      .copyWith(color: _kTextSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 건강 체중 범위 카드 ────────────────────────────────────────────────────────
class _HealthyWeightCard extends StatelessWidget {
  const _HealthyWeightCard({
    required this.minKg,
    required this.maxKg,
    required this.isInRange,
    required this.isMetric,
  });

  final double minKg;
  final double maxKg;
  final bool isInRange;
  final bool isMetric;

  String _fmt(double kg) => isMetric
      ? '${kg.toStringAsFixed(1)} kg'
      : '${(kg * 2.20462).toStringAsFixed(1)} lb';

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);
    return Container(
      padding: AppTokens.paddingCard,
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(
          color: isInRange
              ? green.withValues(alpha: 0.4)
              : _kTextSecondary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: AppTokens.sizeIconContainer,
            height: AppTokens.sizeIconContainer,
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTokens.radiusIconContainer),
            ),
            child: Icon(
              isInRange
                  ? Icons.check_circle_outline
                  : Icons.monitor_weight_outlined,
              color: isInRange ? green : _kTextSecondary,
              size: AppTokens.sizeIconMedium,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('건강 체중 범위',
                    style: AppTokens.textStyleSectionTitle
                        .copyWith(color: _kTextSecondary)),
                const SizedBox(height: 2),
                Text('${_fmt(minKg)} – ${_fmt(maxKg)}',
                    style: AppTokens.textStyleValue
                        .copyWith(color: _kTextPrimary)),
                if (isInRange) ...[
                  const SizedBox(height: 2),
                  Text('현재 체중이 건강 범위 안에 있습니다',
                      style: AppTokens.textStyleCaption
                          .copyWith(color: green)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 범주 그리드 ───────────────────────────────────────────────────────────────
class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.currentCategory,
  });

  final List<BmiCategoryDef> categories;
  final BmiCategoryDef currentCategory;

  @override
  Widget build(BuildContext context) {
    // 5개 이상이면 2행, 4개면 1행
    final use2Row = categories.length > 4;
    if (use2Row) {
      final row1 = categories.sublist(0, 3);
      final row2 = categories.sublist(3);
      return Column(
        children: [
          _buildRow(row1),
          const SizedBox(height: 8),
          _buildRow(row2),
        ],
      );
    }
    return _buildRow(categories);
  }

  Widget _buildRow(List<BmiCategoryDef> cats) {
    return Row(
      children: cats.map((cat) {
        final isActive = cat.label == currentCategory.label;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding:
                const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? cat.color.withValues(alpha: 0.18)
                  : _kCardBg,
              borderRadius:
                  BorderRadius.circular(AppTokens.radiusInput),
              border: Border.all(
                color: isActive
                    ? cat.color.withValues(alpha: 0.6)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  cat.label,
                  textAlign: TextAlign.center,
                  style: AppTokens.textStyleCaption.copyWith(
                    color: isActive ? cat.color : _kTextSecondary,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  cat.rangeLabel,
                  textAlign: TextAlign.center,
                  style: AppTokens.textStyleLabelMedium.copyWith(
                    color: isActive
                        ? cat.color.withValues(alpha: 0.8)
                        : _kTextSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
