import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/unit_definitions.dart';
import '../../domain/models/unit_converter_state.dart';
import '../../domain/models/unit_definition.dart';
import 'unit_converter_viewmodel.dart';

// ──────────────────────────────────────────
// 색상 상수
// ──────────────────────────────────────────
const _gradientTop = Color(0xFF1B2838);
const _gradientBottom = Color(0xFF2C3E50);
const _activeRowColor = Color(0x33E94560);
const _chipSelectedColor = Color(0xFFF0A500);
const _chipDefaultColor = Color(0x44FFFFFF);
const _dividerColor = Color(0x55FFFFFF);
const _colorNumber = Colors.white;
const _colorFunction = Color(0xCCFFFFFF);

// ──────────────────────────────────────────
// 메인 화면
// ──────────────────────────────────────────
class UnitConverterScreen extends ConsumerStatefulWidget {
  final String title;
  final IconData icon;

  const UnitConverterScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  ConsumerState<UnitConverterScreen> createState() =>
      _UnitConverterScreenState();
}

class _UnitConverterScreenState extends ConsumerState<UnitConverterScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final _scrollControllers = <int, ScrollController>{};
  final _itemKeys = <int, Map<int, GlobalKey>>{};
  int _lastReportedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: unitCategories.length,
      vsync: this,
    );
    _tabController.animation!.addListener(_onTabAnimation);
  }

  @override
  void dispose() {
    _tabController.animation!.removeListener(_onTabAnimation);
    _tabController.dispose();
    for (final c in _scrollControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabAnimation() {
    // 칩 탭 등 프로그래밍 방식 animateTo 중에는 무시 (ViewModel이 이미 업데이트됨)
    if (_tabController.indexIsChanging) return;

    final rounded = _tabController.animation!.value.round();
    if (rounded != _lastReportedIndex) {
      _lastReportedIndex = rounded;
      final vm = ref.read(unitConverterViewModelProvider.notifier);
      vm.handleIntent(UnitConverterIntent.categorySelected(rounded));
    }
  }

  ScrollController _scrollControllerFor(int categoryIndex) {
    return _scrollControllers.putIfAbsent(
      categoryIndex,
      () => ScrollController(),
    );
  }

  Map<int, GlobalKey> _itemKeysFor(int categoryIndex) {
    return _itemKeys.putIfAbsent(categoryIndex, () => {});
  }

  void _ensureActiveVisible(int categoryIndex, int unitIndex, int direction) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keys = _itemKeysFor(categoryIndex);
      final key = keys[unitIndex];
      if (key == null || key.currentContext == null) return;
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignmentPolicy: direction > 0
            ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
            : ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unitConverterViewModelProvider);
    final vm = ref.read(unitConverterViewModelProvider.notifier);

    // 카테고리 인덱스 변경 시 탭 컨트롤러와 동기화
    ref.listen(
      unitConverterViewModelProvider.select((s) => s.selectedCategoryIndex),
      (prev, next) {
        _lastReportedIndex = next;
        if (_tabController.index != next) {
          _tabController.animateTo(next);
        }
      },
    );

    // 토스트 메시지
    ref.listen(
      unitConverterViewModelProvider.select((s) => s.toastMessage),
      (_, message) {
        if (message != null) {
          _showToast(context, message);
          vm.clearToast();
        }
      },
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_gradientTop, _gradientBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _CategoryTabs(
                tabController: _tabController,
                selectedIndex: state.selectedCategoryIndex,
                onSelected: (index) => vm.handleIntent(
                  UnitConverterIntent.categorySelected(index),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(unitCategories.length, (catIndex) {
                    return _UnitList(
                      category: unitCategories[catIndex],
                      state: state,
                      isActive: catIndex == state.selectedCategoryIndex,
                      formattedInput: vm.formattedInput,
                      onUnitTapped: (code) => vm.handleIntent(
                        UnitConverterIntent.unitTapped(code),
                      ),
                      scrollController: _scrollControllerFor(catIndex),
                      itemKeys: _itemKeysFor(catIndex),
                    );
                  }),
                ),
              ),
              const Divider(color: _dividerColor, thickness: 0.5, height: 1),
              _NumberPad(
                isTemperature: unitCategories[state.selectedCategoryIndex].name == '온도',
                onKey: (key) => vm.handleIntent(
                  UnitConverterIntent.keyTapped(key),
                ),
                onArrow: (dir) {
                  vm.handleIntent(UnitConverterIntent.arrowTapped(dir));
                  // 자동 스크롤
                  final category = unitCategories[state.selectedCategoryIndex];
                  final currentIdx = category.units
                      .indexWhere((u) => u.code == state.activeUnitCode);
                  final newIdx = currentIdx + dir;
                  if (newIdx >= 0 && newIdx < category.units.length) {
                    _ensureActiveVisible(
                      state.selectedCategoryIndex,
                      newIdx,
                      dir,
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'calc_icon_${widget.title}',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child:
                        Icon(widget.icon, color: Colors.white, size: 15),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Hero(
                tag: 'calc_title_${widget.title}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 320,
        left: 40,
        right: 40,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), entry.remove);
  }
}

// ──────────────────────────────────────────
// 카테고리 탭
// ──────────────────────────────────────────
class _CategoryTabs extends StatefulWidget {
  final TabController tabController;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _CategoryTabs({
    required this.tabController,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<_CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<_CategoryTabs> {
  final _chipKeys = <int, GlobalKey>{};

  @override
  void didUpdateWidget(covariant _CategoryTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollToSelected(widget.selectedIndex);
    }
  }

  void _scrollToSelected(int index) {
    final key = _chipKeys[index];
    if (key == null || key.currentContext == null) return;
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: 0.3,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: unitCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == widget.selectedIndex;
          final category = unitCategories[index];
          final key = _chipKeys.putIfAbsent(index, () => GlobalKey());
          return GestureDetector(
            key: key,
            onTap: () => widget.onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _chipSelectedColor : _chipDefaultColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.white60,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────
// 단위 리스트
// ──────────────────────────────────────────
class _UnitList extends StatefulWidget {
  final UnitCategory category;
  final UnitConverterState state;
  final bool isActive;
  final String formattedInput;
  final ValueChanged<String> onUnitTapped;
  final ScrollController scrollController;
  final Map<int, GlobalKey> itemKeys;

  const _UnitList({
    required this.category,
    required this.state,
    required this.isActive,
    required this.formattedInput,
    required this.onUnitTapped,
    required this.scrollController,
    required this.itemKeys,
  });

  @override
  State<_UnitList> createState() => _UnitListState();
}

class _UnitListState extends State<_UnitList> {
  bool _showBottomFade = true;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFade());
  }

  @override
  void didUpdateWidget(covariant _UnitList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_onScroll);
      widget.scrollController.addListener(_onScroll);
    }
    if (oldWidget.category != widget.category) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkFade());
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() => _checkFade();

  void _checkFade() {
    if (!widget.scrollController.hasClients) return;
    final pos = widget.scrollController.position;
    final atBottom = pos.pixels >= pos.maxScrollExtent - 8;
    final canScroll = pos.maxScrollExtent > 0;
    if (_showBottomFade != (canScroll && !atBottom)) {
      setState(() => _showBottomFade = canScroll && !atBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final units = widget.category.units;

    return Stack(
      children: [
        ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: units.length,
          itemBuilder: (context, index) {
            final unit = units[index];
            final isActiveUnit = unit.code == widget.state.activeUnitCode;
            final key =
                widget.itemKeys.putIfAbsent(index, () => GlobalKey());

            // 활성 행: 포맷팅된 입력값 표시, 비활성 행: 변환 결과 표시
            final displayValue = (widget.isActive && isActiveUnit)
                ? widget.formattedInput
                : (widget.state.convertedValues[unit.code] ?? '0');

            return GestureDetector(
              key: key,
              onTap: () => widget.onUnitTapped(unit.code),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: (widget.isActive && isActiveUnit)
                      ? _activeRowColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: (widget.isActive && isActiveUnit)
                      ? Border.all(
                          color: _chipSelectedColor.withValues(alpha: 0.4),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        unit.code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: (widget.isActive && isActiveUnit)
                              ? _chipSelectedColor
                              : Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        unit.label,
                        style: TextStyle(
                          color: (widget.isActive && isActiveUnit)
                              ? Colors.white
                              : Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      displayValue,
                      style: TextStyle(
                        color: (widget.isActive && isActiveUnit)
                            ? Colors.white
                            : Colors.white70,
                        fontSize: 18,
                        fontWeight: (widget.isActive && isActiveUnit)
                            ? FontWeight.w500
                            : FontWeight.w300,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // 하단 페이드 그라디언트
        if (_showBottomFade)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 48,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.6, 1.0],
                    colors: [
                      _gradientBottom.withValues(alpha: 0),
                      _gradientBottom.withValues(alpha: 0.7),
                      _gradientBottom,
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ──────────────────────────────────────────
// 버튼 타입
// ──────────────────────────────────────────
enum _BtnType { number, function }

// ──────────────────────────────────────────
// 숫자 키패드 (4×4)
// ──────────────────────────────────────────
class _NumberPad extends StatelessWidget {
  final bool isTemperature;
  final ValueChanged<String> onKey;
  final ValueChanged<int> onArrow;

  const _NumberPad({
    required this.isTemperature,
    required this.onKey,
    required this.onArrow,
  });

  List<List<(String, _BtnType)>> get _rows => [
    [('7', _BtnType.number), ('8', _BtnType.number), ('9', _BtnType.number), ('\u{232B}', _BtnType.function)],
    [('4', _BtnType.number), ('5', _BtnType.number), ('6', _BtnType.number), ('AC', _BtnType.function)],
    [('1', _BtnType.number), ('2', _BtnType.number), ('3', _BtnType.number), ('▲', _BtnType.function)],
    [(isTemperature ? '+/-' : '00', isTemperature ? _BtnType.function : _BtnType.number), ('0', _BtnType.number), ('.', _BtnType.number), ('▼', _BtnType.function)],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _rows.map((row) {
        return Row(
          children: row.map((cell) {
            return Expanded(
              child: _KeypadButton(
                label: cell.$1,
                type: cell.$2,
                onTap: cell.$1 == '▲'
                    ? () => onArrow(-1)
                    : cell.$1 == '▼'
                        ? () => onArrow(1)
                        : cell.$1 == '\u{232B}'
                            ? () => onKey('⌫')
                            : () => onKey(cell.$1),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

// ──────────────────────────────────────────
// 단일 버튼
// ──────────────────────────────────────────
class _KeypadButton extends StatelessWidget {
  final String label;
  final _BtnType type;
  final VoidCallback onTap;

  const _KeypadButton({
    required this.label,
    required this.type,
    required this.onTap,
  });

  Color get _textColor => switch (type) {
        _BtnType.number => _colorNumber,
        _BtnType.function => _colorFunction,
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: SizedBox(
          height: 56,
          child: Center(
            child: label == '\u{232B}'
                ? Icon(Icons.backspace_outlined, color: _textColor, size: 24)
                : label == '▲'
                    ? Icon(Icons.keyboard_arrow_up, color: _textColor, size: 28)
                    : label == '▼'
                        ? Icon(Icons.keyboard_arrow_down, color: _textColor, size: 28)
                        : label == '+/-'
                            ? _buildPlusMinusLabel(_textColor)
                            : Text(
                                label,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  color: _textColor,
                                ),
                              ),
          ),
        ),
      ),
    );
  }

  static Widget _buildPlusMinusLabel(Color color) {
    const style = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, -2),
          child: Text('+', style: style.copyWith(color: color)),
        ),
        Text('/', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: color)),
        Transform.translate(
          offset: const Offset(0, 2),
          child: Text('-', style: style.copyWith(color: color, fontSize: 24)),
        ),
      ],
    );
  }
}
