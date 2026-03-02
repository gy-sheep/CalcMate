import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
// 더미 데이터
// ──────────────────────────────────────────

class _UnitCategory {
  final String name;
  final IconData icon;
  final List<_UnitItem> units;
  final String defaultCode;

  const _UnitCategory({
    required this.name,
    required this.icon,
    required this.units,
    required this.defaultCode,
  });
}

class _UnitItem {
  final String code;
  final String label;
  final String value;

  const _UnitItem({
    required this.code,
    required this.label,
    required this.value,
  });
}

const _categories = [
  _UnitCategory(
    name: '길이',
    icon: Icons.straighten,
    defaultCode: 'cm',
    units: [
      _UnitItem(value: '0', code: 'mm', label: '밀리미터'),
      _UnitItem(value: '0', code: 'cm', label: '센티미터'),
      _UnitItem(value: '0', code: 'm', label: '미터'),
      _UnitItem(value: '0', code: 'km', label: '킬로미터'),
      _UnitItem(value: '0', code: 'in', label: '인치'),
      _UnitItem(value: '0', code: 'ft', label: '피트'),
      _UnitItem(value: '0', code: 'yd', label: '야드'),
      _UnitItem(value: '0', code: 'mi', label: '마일'),
    ],
  ),
  _UnitCategory(
    name: '질량',
    icon: Icons.fitness_center,
    defaultCode: 'kg',
    units: [
      _UnitItem(value: '0', code: 'mg', label: '밀리그램'),
      _UnitItem(value: '0', code: 'g', label: '그램'),
      _UnitItem(value: '0', code: 'kg', label: '킬로그램'),
      _UnitItem(value: '0', code: 't', label: '톤'),
      _UnitItem(value: '0', code: 'oz', label: '온스'),
      _UnitItem(value: '0', code: 'lb', label: '파운드'),
    ],
  ),
  _UnitCategory(
    name: '온도',
    icon: Icons.thermostat,
    defaultCode: '°C',
    units: [
      _UnitItem(value: '0', code: '°C', label: '섭씨'),
      _UnitItem(value: '0', code: '°F', label: '화씨'),
      _UnitItem(value: '0', code: 'K', label: '켈빈'),
    ],
  ),
  _UnitCategory(
    name: '넓이',
    icon: Icons.crop_square,
    defaultCode: 'm²',
    units: [
      _UnitItem(value: '0', code: 'mm²', label: '제곱밀리미터'),
      _UnitItem(value: '0', code: 'cm²', label: '제곱센티미터'),
      _UnitItem(value: '0', code: 'm²', label: '제곱미터'),
      _UnitItem(value: '0', code: 'km²', label: '제곱킬로미터'),
      _UnitItem(value: '0', code: 'ha', label: '헥타르'),
      _UnitItem(value: '0', code: 'ac', label: '에이커'),
      _UnitItem(value: '0', code: 'ft²', label: '제곱피트'),
      _UnitItem(value: '0', code: '평', label: '평'),
    ],
  ),
  _UnitCategory(
    name: '시간',
    icon: Icons.access_time,
    defaultCode: 'h',
    units: [
      _UnitItem(value: '0', code: 'ms', label: '밀리초'),
      _UnitItem(value: '0', code: 's', label: '초'),
      _UnitItem(value: '0', code: 'min', label: '분'),
      _UnitItem(value: '0', code: 'h', label: '시간'),
      _UnitItem(value: '0', code: 'day', label: '일'),
      _UnitItem(value: '0', code: 'week', label: '주'),
      _UnitItem(value: '0', code: 'month', label: '개월'),
      _UnitItem(value: '0', code: 'year', label: '년'),
    ],
  ),
  _UnitCategory(
    name: '부피',
    icon: Icons.local_drink,
    defaultCode: 'L',
    units: [
      _UnitItem(value: '0', code: 'mL', label: '밀리리터'),
      _UnitItem(value: '0', code: 'L', label: '리터'),
      _UnitItem(value: '0', code: 'm³', label: '세제곱미터'),
      _UnitItem(value: '0', code: 'gal', label: '갤런(US)'),
      _UnitItem(value: '0', code: 'qt', label: '쿼트(US)'),
      _UnitItem(value: '0', code: 'pt', label: '파인트(US)'),
      _UnitItem(value: '0', code: 'fl oz', label: '액량온스(US)'),
      _UnitItem(value: '0', code: 'cup', label: '컵(US)'),
    ],
  ),
  _UnitCategory(
    name: '속도',
    icon: Icons.directions_car,
    defaultCode: 'km/h',
    units: [
      _UnitItem(value: '0', code: 'm/s', label: '미터/초'),
      _UnitItem(value: '0', code: 'km/h', label: '킬로미터/시'),
      _UnitItem(value: '0', code: 'mph', label: '마일/시'),
      _UnitItem(value: '0', code: 'kn', label: '노트'),
      _UnitItem(value: '0', code: 'ft/s', label: '피트/초'),
    ],
  ),
  _UnitCategory(
    name: '연비',
    icon: Icons.local_gas_station,
    defaultCode: 'km/L',
    units: [
      _UnitItem(value: '0', code: 'km/L', label: '킬로미터/리터'),
      _UnitItem(value: '0', code: 'L/100km', label: '리터/100킬로미터'),
      _UnitItem(value: '0', code: 'mpg(US)', label: '마일/갤런(US)'),
      _UnitItem(value: '0', code: 'mpg(UK)', label: '마일/갤런(UK)'),
    ],
  ),
  _UnitCategory(
    name: '데이터',
    icon: Icons.storage,
    defaultCode: 'GB',
    units: [
      _UnitItem(value: '0', code: 'bit', label: '비트'),
      _UnitItem(value: '0', code: 'B', label: '바이트'),
      _UnitItem(value: '0', code: 'KB', label: '킬로바이트'),
      _UnitItem(value: '0', code: 'MB', label: '메가바이트'),
      _UnitItem(value: '0', code: 'GB', label: '기가바이트'),
      _UnitItem(value: '0', code: 'TB', label: '테라바이트'),
      _UnitItem(value: '0', code: 'PB', label: '페타바이트'),
    ],
  ),
  _UnitCategory(
    name: '압력',
    icon: Icons.speed,
    defaultCode: 'atm',
    units: [
      _UnitItem(value: '0', code: 'Pa', label: '파스칼'),
      _UnitItem(value: '0', code: 'kPa', label: '킬로파스칼'),
      _UnitItem(value: '0', code: 'MPa', label: '메가파스칼'),
      _UnitItem(value: '0', code: 'bar', label: '바'),
      _UnitItem(value: '0', code: 'atm', label: '기압'),
      _UnitItem(value: '0', code: 'mmHg', label: '수은주밀리미터'),
      _UnitItem(value: '0', code: 'psi', label: '제곱인치당파운드'),
    ],
  ),
];

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

class _UnitConverterScreenState extends ConsumerState<UnitConverterScreen> {
  int _selectedCategoryIndex = 0;
  late String _activeUnitCode;
  final _scrollController = ScrollController();

  final _itemKeys = <int, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    _activeUnitCode = _categories[0].defaultCode;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _activeUnitCode = _categories[index].defaultCode;
      _itemKeys.clear();
    });
    _scrollController.jumpTo(0);
  }

  void _onUnitTapped(String code) {
    setState(() {
      _activeUnitCode = code;
    });
  }

  void _moveActiveUnit(int direction) {
    final units = _categories[_selectedCategoryIndex].units;
    final currentIndex = units.indexWhere((u) => u.code == _activeUnitCode);
    if (currentIndex < 0) return;

    final newIndex = currentIndex + direction;
    if (newIndex < 0 || newIndex >= units.length) return;

    setState(() {
      _activeUnitCode = units[newIndex].code;
    });

    // 자동 스크롤: 활성 행이 보이도록
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _itemKeys[newIndex];
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
    final category = _categories[_selectedCategoryIndex];

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
                categories: _categories,
                selectedIndex: _selectedCategoryIndex,
                onSelected: _onCategorySelected,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _UnitList(
                  units: category.units,
                  activeCode: _activeUnitCode,
                  onUnitTapped: _onUnitTapped,
                  scrollController: _scrollController,
                  itemKeys: _itemKeys,
                ),
              ),
              const Divider(color: _dividerColor, thickness: 0.5, height: 1),
              _NumberPad(onArrow: _moveActiveUnit),
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
}

// ──────────────────────────────────────────
// 카테고리 탭
// ──────────────────────────────────────────
class _CategoryTabs extends StatelessWidget {
  final List<_UnitCategory> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _CategoryTabs({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final category = categories[index];
          return GestureDetector(
            onTap: () => onSelected(index),
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
  final List<_UnitItem> units;
  final String activeCode;
  final ValueChanged<String> onUnitTapped;
  final ScrollController scrollController;
  final Map<int, GlobalKey> itemKeys;

  const _UnitList({
    required this.units,
    required this.activeCode,
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
    if (oldWidget.units != widget.units) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkFade());
    }
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
    return Stack(
      children: [
        ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: widget.units.length,
          itemBuilder: (context, index) {
            final unit = widget.units[index];
            final isActive = unit.code == widget.activeCode;
            final key = widget.itemKeys.putIfAbsent(index, () => GlobalKey());
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
                  color: isActive ? _activeRowColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isActive
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
                          color:
                              isActive ? _chipSelectedColor : Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        unit.label,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      unit.value,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white70,
                        fontSize: 18,
                        fontWeight:
                            isActive ? FontWeight.w500 : FontWeight.w300,
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
  final ValueChanged<int> onArrow;

  const _NumberPad({required this.onArrow});

  static const _rows = [
    [('7', _BtnType.number), ('8', _BtnType.number), ('9', _BtnType.number), ('\u{232B}', _BtnType.function)],
    [('4', _BtnType.number), ('5', _BtnType.number), ('6', _BtnType.number), ('AC', _BtnType.function)],
    [('1', _BtnType.number), ('2', _BtnType.number), ('3', _BtnType.number), ('▲', _BtnType.function)],
    [('+/-', _BtnType.function), ('0', _BtnType.number), ('.', _BtnType.number), ('▼', _BtnType.function)],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _rows.map((row) {
        return Row(
          children: row.map((cell) {
            if (cell.$1.isEmpty) {
              return const Expanded(child: SizedBox(height: 56));
            }
            return Expanded(
              child: _KeypadButton(
                label: cell.$1,
                type: cell.$2,
                onTap: cell.$1 == '▲'
                    ? () => onArrow(-1)
                    : cell.$1 == '▼'
                        ? () => onArrow(1)
                        : () {}, // 나머지 키는 추후 ViewModel 연결
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
