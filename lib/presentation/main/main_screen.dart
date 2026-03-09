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
        // TODO: 설정 화면으로 이동
        break;
    }
  }

  @override
  void dispose() {
    _dismissMenu();
    _scrollController.dispose();
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
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'CalcMate',
              style: AppTokens.textStyleAppBarTitle.copyWith(
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.35),
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
          ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.only(
              top: topPadding,
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: state.entries.length,
            separatorBuilder: (context, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final entry = state.entries[index];
              final screen = _buildScreen(entry);
              if (screen != null) {
                return RepaintBoundary(
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
                        onTap: openContainer,
                      );
                    },
                    openBuilder: (context, _) {
                      return EdgeSwipeBack(child: screen);
                    },
                  ),
                );
              }
              return RepaintBoundary(
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
            },
          ),
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
