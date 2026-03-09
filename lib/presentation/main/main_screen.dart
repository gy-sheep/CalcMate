import 'dart:math' show pi, sin;
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:calcmate/domain/models/calc_mode_entry.dart';
import 'package:calcmate/core/navigation/edge_swipe_back.dart';
import 'package:calcmate/presentation/calculator/basic_calculator_screen.dart';
import 'package:calcmate/presentation/currency/currency_calculator_screen.dart';
import 'package:calcmate/presentation/unit_converter/unit_converter_screen.dart';
import 'package:calcmate/presentation/age_calculator/age_calculator_screen.dart';
import 'package:calcmate/presentation/vat_calculator/vat_calculator_screen.dart';
import 'package:calcmate/presentation/date_calculator/date_calculator_screen.dart';
import 'package:calcmate/presentation/loan_calculator/loan_prototype_hub.dart';
import 'package:calcmate/presentation/dutch_pay/dutch_pay_screen.dart';
import 'package:calcmate/presentation/discount_calculator/discount_calculator_screen.dart';
import 'package:calcmate/presentation/bmi_calculator/bmi_calculator_screen.dart';
import 'package:calcmate/presentation/net_pay_calculator/net_pay_calculator_screen.dart';
import 'package:calcmate/presentation/settings/settings_screen.dart';
import 'package:calcmate/core/config/calc_mode_config.dart';
import 'package:calcmate/core/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/calc_mode_card.dart';
import 'main_screen_viewmodel.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _settingsKey = GlobalKey();
  OverlayEntry? _menuOverlay;
  final ValueNotifier<int> _swipeResetNotifier = ValueNotifier(0);
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _precacheCardImages();
  }

  void _precacheCardImages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final entry in kCalcModeEntries) {
        precacheImage(AssetImage(entry.imagePath), context);
      }
    });
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset.clamp(0.0, double.infinity);
    });
    // 편집 모드 AppBar blur 용
    final scrolled = _scrollController.offset > 0;
    final isScrolled = ref.read(mainScreenViewModelProvider).isScrolled;
    if (scrolled != isScrolled) {
      ref
          .read(mainScreenViewModelProvider.notifier)
          .handleIntent(MainScreenIntent.scrollChanged(scrolled));
    }
  }

  void _showSettingsMenu() {
    final box =
        _settingsKey.currentContext!.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    final size = box.size;

    _menuOverlay = OverlayEntry(
      builder: (context) => _SettingsMenuOverlay(
        iconPosition: position,
        iconSize: size,
        onDismiss: _dismissMenu,
        onSelected: _onMenuSelected,
      ),
    );

    Overlay.of(context).insert(_menuOverlay!);
  }

  void _dismissMenu() {
    _menuOverlay?.remove();
    _menuOverlay = null;
  }

  void _onMenuSelected(_SettingsMenu value) {
    switch (value) {
      case _SettingsMenu.editOrder:
        ref
            .read(mainScreenViewModelProvider.notifier)
            .handleIntent(const MainScreenIntent.toggleEditMode());
      case _SettingsMenu.settings:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
    }
  }

  @override
  void dispose() {
    _dismissMenu();
    _scrollController.dispose();
    _swipeResetNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainScreenViewModelProvider);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    if (state.isEditMode) {
      final topPadding = statusBarHeight + kToolbarHeight;
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: state.isScrolled ? 20.0 : 0.0),
            duration: const Duration(milliseconds: 200),
            builder: (context, sigma, _) {
              return ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: state.isScrolled
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withValues(alpha: 0.75)
                            : Colors.white.withValues(alpha: 0.75))
                        : Theme.of(context).colorScheme.surface,
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      title: const Text('순서 편집'),
                      centerTitle: false,
                      actions: [
                        TextButton(
                          onPressed: () => ref
                              .read(mainScreenViewModelProvider.notifier)
                              .handleIntent(const MainScreenIntent.toggleEditMode()),
                          child: const Text('완료'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildEditList(context, state, topPadding),
        ),
      );
    }

    final visibleEntries = state.entries.where((e) => e.isVisible).toList();
    final topPadding = statusBarHeight + kToolbarHeight;
    final isScrolled = _scrollOffset > 0;
    final t = _scrollOffset > kToolbarHeight ? 1.0 : _scrollOffset / kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedOpacity(
          opacity: isScrolled ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AppBar(
            systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'CalcMate',
              style: AppTokens.textStyleAppBarTitle.copyWith(
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                key: _settingsKey,
                onPressed: _showSettingsMenu,
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          NotificationListener<ScrollStartNotification>(
            onNotification: (_) {
              _swipeResetNotifier.value++;
              return false;
            },
            child: ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.only(
              top: topPadding,
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: visibleEntries.length,
            separatorBuilder: (context, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final entry = visibleEntries[index];
              final screen = _buildScreen(entry);
              final canHide = visibleEntries.length > 1;

              Widget card;
              if (screen != null) {
                card = RepaintBoundary(
                  child: OpenContainer(
                    transitionDuration: const Duration(milliseconds: 400),
                    closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    closedElevation: 0,
                    openElevation: 0,
                    closedColor: Colors.transparent,
                    openColor: Colors.transparent,
                    closedBuilder: (context, openContainer) {
                      return CalcModeCard(
                        title: entry.title,
                        description: entry.description,
                        icon: entry.icon,
                        imagePath: entry.imagePath,
                        onTap: () {
                          _swipeResetNotifier.value++;
                          openContainer();
                        },
                      );
                    },
                    openBuilder: (context, _) {
                      return EdgeSwipeBack(child: screen);
                    },
                  ),
                );
              } else {
                card = RepaintBoundary(
                  child: CalcModeCard(
                    title: entry.title,
                    description: entry.description,
                    icon: entry.icon,
                    imagePath: entry.imagePath,
                    onTap: () {
                      ref
                          .read(mainScreenViewModelProvider.notifier)
                          .handleIntent(MainScreenIntent.cardTapped(entry.id));
                    },
                  ),
                );
              }

              if (!canHide) return card;

              return _SwipeToHideCard(
                key: ValueKey(entry.id),
                resetNotifier: _swipeResetNotifier,
                onHide: () => ref
                    .read(mainScreenViewModelProvider.notifier)
                    .handleIntent(
                        MainScreenIntent.toggleVisibility(entry.id)),
                child: card,
              );
            },
            ), // ListView
          ), // NotificationListener
          // 상태바 blur 오버레이 — AppBar 페이드 후 등장, 하단 그라디언트로 경계 제거
          if (isScrolled)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: statusBarHeight + 24,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.black, Colors.transparent],
                  stops: [0.0, 0.55, 1.0],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20 * t, sigmaY: 20 * t),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).colorScheme.surface.withValues(alpha: 0.75 * t),
                            Theme.of(context).colorScheme.surface.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditList(BuildContext context, MainScreenState state, double topPadding) {
    return ReorderableListView.builder(
      scrollController: _scrollController,
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: state.entries.length,
      onReorder: (oldIndex, newIndex) {
        ref
            .read(mainScreenViewModelProvider.notifier)
            .handleIntent(MainScreenIntent.reorderEntries(oldIndex, newIndex));
      },
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        child: Transform.scale(scale: 1.04, child: child),
      ),
      itemBuilder: (context, index) {
        final entry = state.entries[index];
        return Padding(
          key: ValueKey(entry.id),
          padding: const EdgeInsets.only(bottom: 16),
          child: RepaintBoundary(
            child: CalcModeCard(
              title: entry.title,
              description: entry.description,
              icon: entry.icon,
              imagePath: entry.imagePath,
              trailingOverride: Listener(
                onPointerDown: (_) => HapticFeedback.mediumImpact(),
                child: ReorderableDragStartListener(
                  index: index,
                  child: const _DragHandleIcon(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget? _buildScreen(CalcModeEntry entry) {
    switch (entry.id) {
      case 'basic_calculator':
        return BasicCalculatorScreen(
          title: entry.title,
        );
      case 'exchange_rate':
        return CurrencyCalculatorScreen(
          title: entry.title,
        );
      case 'unit_converter':
        return UnitConverterScreen(
          title: entry.title,
        );
      case 'vat_calculator':
        return VatCalculatorScreen(
          title: entry.title,
        );
      case 'age_calculator':
        return AgeCalculatorScreen(
          title: entry.title,
        );
      case 'date_calculator':
        return const DateCalculatorScreen();
      case 'loan_calculator':
        return const LoanPrototypeHub();
      case 'dutch_pay':
        return const DutchPayScreen();
      case 'salary_calculator':
        return NetPayCalculatorScreen(title: entry.title);
      case 'discount_calculator':
        return DiscountCalculatorScreen(title: entry.title);
      case 'bmi_calculator':
        return const BmiCalculatorScreen();
      default:
        return null;
    }
  }
}

// --- Enum ---

enum _SettingsMenu { editOrder, settings }

class _DragHandleIcon extends StatelessWidget {
  const _DragHandleIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 28),
      painter: _DragHandlePainter(color: Colors.white),
    );
  }
}

class _DragHandlePainter extends CustomPainter {
  final Color color;
  const _DragHandlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 라인 간격 g, 화살표↔라인 간격 2g
    // 배치: g(상단) + 화살표 + 2g + 라인 + g + 라인 + g + 라인 + 2g + 화살표 + g(하단) = 8g
    final g = size.height / 8;
    final arrowHalfW = size.width * 0.4;
    final arrowH = g * 0.9;

    // 위 화살표
    final upY = g;
    final upArrow = Path()
      ..moveTo(size.width / 2, upY - arrowH / 2)
      ..lineTo(size.width / 2 - arrowHalfW, upY + arrowH / 2)
      ..lineTo(size.width / 2 + arrowHalfW, upY + arrowH / 2)
      ..close();
    canvas.drawPath(upArrow, arrowPaint);

    // 가로 라인 3줄
    final lineYs = [g * 3, g * 4, g * 5];
    for (final y in lineYs) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // 아래 화살표
    final downY = g * 7;
    final downArrow = Path()
      ..moveTo(size.width / 2, downY + arrowH / 2)
      ..lineTo(size.width / 2 - arrowHalfW, downY - arrowH / 2)
      ..lineTo(size.width / 2 + arrowHalfW, downY - arrowH / 2)
      ..close();
    canvas.drawPath(downArrow, arrowPaint);
  }

  @override
  bool shouldRepaint(_DragHandlePainter oldDelegate) => oldDelegate.color != color;
}

// --- 스와이프 숨기기 위젯 ---

class _SwipeToHideCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onHide;
  final ValueNotifier<int>? resetNotifier;

  const _SwipeToHideCard({
    super.key,
    required this.child,
    required this.onHide,
    this.resetNotifier,
  });

  @override
  State<_SwipeToHideCard> createState() => _SwipeToHideCardState();
}

class _SwipeToHideCardState extends State<_SwipeToHideCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _anim;
  double _offset = 0;
  double _cardWidth = 0;
  bool _hapticFired = false;

  // ── 레이아웃 상수 ──
  static const double _snapWidth = 80.0; // snap 상태에서 버튼 영역 너비
  static const double _circleSize = 56.0; // 원형 버튼 크기
  static const double _circleRadius = _circleSize / 2;
  static const double _buttonPadding = 12.0; // 버튼 우측 여백
  static const double _iconPadding = 16.0; // 스트레치 시 아이콘 좌측 여백
  static const double _hapticThreshold = _dismissThresholdRatio; // dismiss 커밋 지점과 동일

  // ── 제스처 상수 ──
  static const double _dragDamping = 0.85; // 버튼 노출 구간 감쇠 계수
  static const double _snapThresholdRatio = 0.3; // snap 진입 임계 비율
  static const double _dismissThresholdRatio = 0.5; // dismiss 임계 비율
  static const double _snapVelocity = -200.0; // snap 진입 최소 속도

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _anim = Tween<double>(begin: 0, end: 0).animate(_controller);
    widget.resetNotifier?.addListener(_onResetRequested);
  }

  @override
  void didUpdateWidget(_SwipeToHideCard old) {
    super.didUpdateWidget(old);
    if (old.resetNotifier != widget.resetNotifier) {
      old.resetNotifier?.removeListener(_onResetRequested);
      widget.resetNotifier?.addListener(_onResetRequested);
    }
  }

  @override
  void dispose() {
    widget.resetNotifier?.removeListener(_onResetRequested);
    _controller.dispose();
    super.dispose();
  }

  void _onResetRequested() {
    if (_currentOffset == 0) return;
    // 진행 중 애니메이션 끊고 즉시 원위치 전환
    if (_controller.isAnimating) {
      _offset = _anim.value;
      _controller.stop();
    }
    _animateTo(0, curve: Curves.easeOutCubic, durationMs: 300);
  }

  double get _currentOffset =>
      _controller.isAnimating ? _anim.value : _offset;

  // ── 흑백 필터 매트릭스 (0.0 = 원색, 1.0 = 완전 흑백) ──
  static List<double> _grayscaleMatrix(double amount) {
    final r = 0.2126 * amount;
    final g = 0.7152 * amount;
    final b = 0.0722 * amount;
    final c = 1.0 - amount;
    return [
      r + c, g,     b,     0, 0,
      r,     g + c, b,     0, 0,
      r,     g,     b + c, 0, 0,
      0,     0,     0,     1, 0,
    ];
  }

  // ── 제스처 핸들러 ──

  void _onDragStart(DragStartDetails _) {
    _hapticFired = false;
    if (_controller.isAnimating) {
      _offset = _anim.value;
      _controller.stop();
    }
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      final factor = _offset.abs() < _snapWidth ? _dragDamping : 1.0;
      _offset = (_offset + d.delta.dx * factor)
          .clamp(double.negativeInfinity, 0.0);
    });
    if (!_hapticFired && _offset.abs() >= _cardWidth * _hapticThreshold) {
      HapticFeedback.mediumImpact();
      _hapticFired = true;
    }
  }

  void _onDragEnd(DragEndDetails d) {
    final velocity = d.velocity.pixelsPerSecond.dx;

    if (_offset.abs() > _cardWidth * _dismissThresholdRatio) {
      _animateToDismiss();
    } else if (_offset.abs() > _snapWidth * _snapThresholdRatio ||
        velocity < _snapVelocity) {
      _animateTo(-_snapWidth,
          curve: Curves.easeOutQuint, durationMs: 400);
    } else {
      _animateTo(0, curve: Curves.easeOutCubic, durationMs: 300);
    }
  }

  // ── 애니메이션 ──

  void _animateTo(
    double target, {
    VoidCallback? onDone,
    Curve curve = Curves.easeOutCubic,
    int durationMs = 300,
  }) {
    _controller.duration = Duration(milliseconds: durationMs);
    _anim = Tween<double>(begin: _offset, end: target).animate(
      CurvedAnimation(parent: _controller, curve: curve),
    );
    _controller.forward(from: 0).then((_) {
      if (mounted) {
        setState(() => _offset = target);
        onDone?.call();
      }
    });
  }

  void _animateToDismiss() {
    _animateTo(
      -(_cardWidth + 20),
      onDone: widget.onHide,
      curve: Curves.easeInCubic,
      durationMs: 250,
    );
  }

  // ── 빌드 ──

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _cardWidth = constraints.maxWidth;

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final offset = _currentOffset;
          final progress = (offset.abs() / _snapWidth).clamp(0.0, 1.0);
          final isOpen = offset < -20;
          final isStretching = offset.abs() > _snapWidth;
          final iconOnLeft = offset.abs() >= _cardWidth * _hapticThreshold;

          return GestureDetector(
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // ── 숨기기 버튼 (오른쪽 고정, pill stretch) ──
                  if (offset < 0)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: _buttonPadding),
                          child: GestureDetector(
                            onTap: _animateToDismiss,
                            child: Opacity(
                              opacity: progress,
                              child: Transform.scale(
                                scale: isStretching ? 1.0 : progress,
                                child: Container(
                                  width: isStretching
                                      ? (offset.abs() - _snapWidth + _circleSize)
                                          .clamp(_circleSize, double.infinity)
                                      : _circleSize,
                                  height: _circleSize,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius:
                                        BorderRadius.circular(_circleRadius),
                                  ),
                                  child: iconOnLeft
                                      ? const Padding(
                                          padding: EdgeInsets.only(
                                              left: _iconPadding),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Icon(
                                              Icons.visibility_off_outlined,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.visibility_off_outlined,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ── 카드 (좌측 이동 + 흑백) ──
                  Transform.translate(
                    offset: Offset(offset, 0),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(
                        _grayscaleMatrix(progress),
                      ),
                      child: widget.child,
                    ),
                  ),

                  // ── 열린 상태에서 카드 영역 탭 → 닫기 ──
                  if (isOpen)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      right: _snapWidth,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _animateTo(0),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

// --- Animated Overlay Menu ---

class _SettingsMenuOverlay extends StatefulWidget {
  final Offset iconPosition;
  final Size iconSize;
  final VoidCallback onDismiss;
  final ValueChanged<_SettingsMenu> onSelected;

  const _SettingsMenuOverlay({
    required this.iconPosition,
    required this.iconSize,
    required this.onDismiss,
    required this.onSelected,
  });

  @override
  State<_SettingsMenuOverlay> createState() => _SettingsMenuOverlayState();
}

class _SettingsMenuOverlayState extends State<_SettingsMenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _items = [
    (_SettingsMenu.editOrder, Icons.edit_outlined, '순서 편집'),
    (_SettingsMenu.settings, Icons.settings_outlined, '설정'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 아이템마다 순서대로 펼쳐지도록 구간 분할 (linear — 물리 커브는 builder에서 처리)
  Animation<double> _itemAnimation(int index) {
    final count = _items.length;
    final start = index / count;
    final end = (index + 1) / count;
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.linear),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final menuRight =
        screenWidth - widget.iconPosition.dx - widget.iconSize.width;
    final menuTop = widget.iconPosition.dy + widget.iconSize.height + 4;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onDismiss,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              right: menuRight,
              top: menuTop,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < _items.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1, thickness: 1, indent: 0, endIndent: 0),
                          _buildItem(i, context),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(int index, BuildContext context) {
    final (value, icon, label) = _items[index];
    final animation = _itemAnimation(index);
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final angle = (1 - t) * (-pi / 2);
        final heightFactor = sin(t * pi / 2);
        final shadowOpacity = (1 - t) * 0.35;
        return ClipRect(
          child: Align(
            heightFactor: heightFactor,
            alignment: Alignment.topCenter,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.003)
                ..rotateX(angle),
              alignment: Alignment.topCenter,
              child: Stack(
                children: [
                  child!,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: shadowOpacity),
                              Colors.black.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          widget.onDismiss();
          widget.onSelected(value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: colorScheme.onSurface),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
