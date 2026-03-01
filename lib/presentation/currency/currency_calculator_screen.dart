import 'package:calcmate/domain/usecases/evaluate_expression_usecase.dart';
import 'package:flutter/material.dart';

// ──────────────────────────────────────────
// 테스트용 목업 데이터
// ──────────────────────────────────────────
class _CurrencyItem {
  final String code;
  final String name;
  final String flag;
  final double rate; // 1 KRW 기준 환율 (목업)

  const _CurrencyItem({
    required this.code,
    required this.name,
    required this.flag,
    required this.rate,
  });
}

const _mockCurrencies = [
  _CurrencyItem(code: 'KRW', name: '한국 원', flag: '🇰🇷', rate: 1.0),
  _CurrencyItem(code: 'USD', name: '미국 달러', flag: '🇺🇸', rate: 0.00075),
  _CurrencyItem(code: 'JPY', name: '일본 엔', flag: '🇯🇵', rate: 0.110),
  _CurrencyItem(code: 'EUR', name: '유로', flag: '🇪🇺', rate: 0.00069),
  _CurrencyItem(code: 'CNY', name: '중국 위안', flag: '🇨🇳', rate: 0.0054),
  _CurrencyItem(code: 'GBP', name: '영국 파운드', flag: '🇬🇧', rate: 0.00059),
  _CurrencyItem(code: 'AUD', name: '호주 달러', flag: '🇦🇺', rate: 0.0011),
  _CurrencyItem(code: 'CAD', name: '캐나다 달러', flag: '🇨🇦', rate: 0.0010),
];

// ──────────────────────────────────────────
// 색상 상수
// ──────────────────────────────────────────
const _gradientTop = Color(0xFF0D1B3E);
const _gradientBottom = Color(0xFF0A4D52);
const _dividerColor = Color(0x55FFFFFF);
const _colorNumber = Colors.white;
const _colorOperator = Color(0xFFFF9F7A);
const _colorFunction = Color(0xCCFFFFFF);
const _colorEquals = Color(0xFFFF6B4A);

// ──────────────────────────────────────────
// 메인 화면 V2
// ──────────────────────────────────────────
class CurrencyCalculatorScreen extends StatefulWidget {
  final String title;
  final IconData icon;

  const CurrencyCalculatorScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  State<CurrencyCalculatorScreen> createState() =>
      _CurrencyCalculatorScreenState();
}

class _CurrencyCalculatorScreenState
    extends State<CurrencyCalculatorScreen> {
  _CurrencyItem _fromCurrency = _mockCurrencies[1]; // USD
  _CurrencyItem _toCurrency = _mockCurrencies[3];   // EUR
  String _fromInput = '120';
  bool _isFromActive = true; // true: 상단 입력 중, false: 하단 입력 중
  bool _isResult = false;

  final _useCase = EvaluateExpressionUseCase();

  // 입력값을 수치로 평가 (수식 포함)
  double get _evaluatedInput {
    if (_fromInput == '오류') return 0;
    final simple = double.tryParse(_fromInput);
    if (simple != null) return simple;
    if (_endsWithOperator(_fromInput)) return 0;
    try {
      final resolved = _resolvePercent(_fromInput);
      final result = _useCase.execute(resolved.replaceAll('÷', '/').replaceAll('×', '*'));
      return (result.isNaN || result.isInfinite) ? 0 : result;
    } catch (_) {
      return 0;
    }
  }

  // 환산 결과 (역방향 포함)
  String get _toInput {
    if (!_isFromActive) return _fromInput; // 하단 직접 입력 시 원본 반환
    final inKrw = _evaluatedInput / _fromCurrency.rate;
    final result = inKrw * _toCurrency.rate;
    return _formatAmount(result);
  }

  String get _fromCalculated {
    if (_isFromActive) return _fromInput;
    final to = double.tryParse(_fromInput) ?? 0;
    final inKrw = to / _toCurrency.rate;
    final result = inKrw * _fromCurrency.rate;
    return _formatAmount(result);
  }

  String _formatAmount(double value) {
    if (value == 0) return '0';
    if (value >= 1000) return value.toStringAsFixed(0);
    if (value >= 1) return value.toStringAsFixed(2);
    return value.toStringAsFixed(4);
  }

  bool _isAcState() {
    if (_fromInput == '0' || _fromInput == '-') return true;
    if (_fromInput.length == 2 && _fromInput[0] == '0') {
      return const {'+', '-', '×', '÷'}.contains(_fromInput[1]);
    }
    return false;
  }

  void _onKeyTap(String key) {
    setState(() {
      switch (key) {
        case 'AC' || 'C':
          _fromInput = '0';
          _isResult = false;

        case '⌫':
          if (_isResult) {
            _fromInput = '0';
            _isResult = false;
            return;
          }
          if (_fromInput.length > 1) {
            _fromInput = _fromInput.substring(0, _fromInput.length - 1);
          } else {
            _fromInput = '0';
          }

        case '%':
          if (_fromInput.endsWith('%')) return;
          if (_endsWithOperator(_fromInput)) return;
          _fromInput += '%';

        case '÷' || '×' || '-' || '+':
          if (_isResult) _isResult = false;
          if (_endsWithOperator(_fromInput)) {
            _fromInput = _fromInput.substring(0, _fromInput.length - 1) + key;
          } else if (_fromInput == '0' && key == '-') {
            _fromInput = '-';
          } else if (_fromInput != '0') {
            _fromInput += key;
          }

        case '=':
          if (_endsWithOperator(_fromInput)) return;
          final resolved = _resolvePercent(_fromInput);
          final result = _useCase.execute(
              resolved.replaceAll('÷', '/').replaceAll('×', '*'));
          _fromInput = _formatResult(result);
          _isResult = true;

        case '+/-':
          final last = _lastNumberSegment(_fromInput);
          if (last.isEmpty) return;
          final prefix = _fromInput.substring(0, _fromInput.length - last.length);
          _fromInput = last.startsWith('-')
              ? prefix + last.substring(1)
              : '$prefix-$last';

        case '.':
          if (_isResult) {
            _fromInput = '0.';
            _isResult = false;
            return;
          }
          final last = _lastNumberSegment(_fromInput);
          if (!last.contains('.')) {
            if (_endsWithOperator(_fromInput) || _fromInput.isEmpty) {
              _fromInput += '0.';
            } else {
              _fromInput += '.';
            }
          }

        default: // 숫자
          if (_isResult) {
            _fromInput = key == '0' ? '0' : key;
            _isResult = false;
            return;
          }
          if (_fromInput == '0') {
            _fromInput = key;
          } else if (_fromInput == '-0') {
            _fromInput = key == '0' ? '-0' : '-$key';
          } else {
            _fromInput += key;
          }
      }
    });
  }

  bool _endsWithOperator(String s) {
    if (s.isEmpty) return false;
    final last = s[s.length - 1];
    return last == '+' || last == '-' || last == '×' || last == '÷';
  }

  String _lastNumberSegment(String s) {
    final ops = {'+', '×', '÷'};
    int i = s.length - 1;
    while (i >= 0) {
      final ch = s[i];
      if (ops.contains(ch)) break;
      if (ch == '-' && i > 0 && !ops.contains(s[i - 1])) break;
      i--;
    }
    return s.substring(i + 1);
  }

  String _resolvePercent(String raw) {
    var expr = raw;
    expr = expr.replaceAllMapped(
      RegExp(r'(-?\d+(?:\.\d*)?)([+\-])(\d+(?:\.\d*)?)%'),
      (m) {
        final left = double.tryParse(m.group(1)!) ?? 0;
        final right = double.tryParse(m.group(3)!) ?? 0;
        return '${m.group(1)}${m.group(2)}${left * right / 100}';
      },
    );
    expr = expr.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d*)?)%'),
      (m) {
        final val = double.tryParse(m.group(1)!) ?? 0;
        return '${val / 100}';
      },
    );
    return expr;
  }

  String _formatResult(double value) {
    if (value == double.infinity || value == double.negativeInfinity) return '오류';
    if (value.isNaN) return '오류';
    if (value == value.truncateToDouble()) return value.toInt().toString();
    final str = value.toStringAsFixed(10);
    return str.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _swap() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _fromInput = '0';
    });
  }

  Future<void> _selectCurrency({required bool isFrom}) async {
    final result = await showModalBottomSheet<_CurrencyItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CurrencyPickerSheet(
        currencies: _mockCurrencies,
        selected: isFrom ? _fromCurrency : _toCurrency,
      ),
    );
    if (result == null) return;
    setState(() {
      if (isFrom) {
        _fromCurrency = result;
      } else {
        _toCurrency = result;
      }
      _fromInput = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
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
              _buildAppBar(),
              Expanded(
                child: Column(
                  children: [
                    const Spacer(),
                    // 상단 통화 (FROM)
                    _CurrencyRow(
                      item: _fromCurrency,
                      amount: _isFromActive ? _fromInput : _fromCalculated,
                      isActive: _isFromActive,
                      onCurrencyTap: () => _selectCurrency(isFrom: true),
                      onAmountTap: () => setState(() => _isFromActive = true),
                    ),
                    const SizedBox(height: 12),
                    // 스왑 버튼
                    _SwapButton(onTap: _swap),
                    const SizedBox(height: 12),
                    // 하단 통화 (TO)
                    _CurrencyRow(
                      item: _toCurrency,
                      amount: _isFromActive ? _toInput : _fromInput,
                      isActive: !_isFromActive,
                      onCurrencyTap: () => _selectCurrency(isFrom: false),
                      onAmountTap: () => setState(() => _isFromActive = false),
                    ),
                    const Spacer(),
                    // 구분선
                    Divider(color: _dividerColor, thickness: 0.5, height: 1),
                    // 숫자 키패드
                    _NumberPad(onKeyTap: _onKeyTap, isAcState: _isAcState()),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
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
                    child: Icon(widget.icon, color: Colors.white, size: 15),
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
// 통화 행 (코드 + 금액 표시)
// ──────────────────────────────────────────
class _CurrencyRow extends StatelessWidget {
  final _CurrencyItem item;
  final String amount;
  final bool isActive;
  final VoidCallback onCurrencyTap;
  final VoidCallback onAmountTap;

  const _CurrencyRow({
    required this.item,
    required this.amount,
    required this.isActive,
    required this.onCurrencyTap,
    required this.onAmountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 통화 선택 버튼
          GestureDetector(
            onTap: onCurrencyTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down,
                    color: Colors.white70, size: 22),
              ],
            ),
          ),
          const Spacer(),
          // 금액 표시 + 밑줄
          GestureDetector(
            onTap: onAmountTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -1,
                  ),
                ),
                Container(
                  height: 1.5,
                  width: 180,
                  color: isActive ? Colors.white : Colors.white38,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// 스왑 버튼
// ──────────────────────────────────────────
class _SwapButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SwapButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: const Icon(
          Icons.swap_vert,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 버튼 타입
// ──────────────────────────────────────────
enum _BtnType { number, operator, function, equals }

// ──────────────────────────────────────────
// 숫자 키패드
// ──────────────────────────────────────────
class _NumberPad extends StatelessWidget {
  final void Function(String) onKeyTap;
  final bool isAcState;

  const _NumberPad({required this.onKeyTap, required this.isAcState});

  static const _rows = [
    [('⌫', _BtnType.function), ('AC', _BtnType.function), ('%', _BtnType.function), ('÷', _BtnType.operator)],
    [('7', _BtnType.number),   ('8', _BtnType.number),    ('9', _BtnType.number),   ('×', _BtnType.operator)],
    [('4', _BtnType.number),   ('5', _BtnType.number),    ('6', _BtnType.number),   ('-', _BtnType.operator)],
    [('1', _BtnType.number),   ('2', _BtnType.number),    ('3', _BtnType.number),   ('+', _BtnType.operator)],
    [('+/-', _BtnType.function), ('0', _BtnType.number),  ('.', _BtnType.number),   ('=', _BtnType.equals)],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _rows.map((row) {
        return Row(
          children: row.map((cell) {
            final label = cell.$1 == 'AC' ? (isAcState ? 'AC' : 'C') : cell.$1;
            return Expanded(
              child: _KeypadButton(
                label: label,
                type: cell.$2,
                onTap: () => onKeyTap(label),
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
        _BtnType.operator => _colorOperator,
        _BtnType.function => _colorFunction,
        _BtnType.equals => Colors.white,
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: type == _BtnType.equals ? _colorEquals : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: SizedBox(
          height: 68,
          child: Center(
            child: label == '⌫'
                ? Icon(Icons.backspace_outlined, color: _textColor, size: 26)
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: const ['÷', '×', '-', '+', '='].contains(label)
                          ? 28
                          : 22,
                      fontWeight: FontWeight.w400,
                      color: _textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 통화 선택 Bottom Sheet
// ──────────────────────────────────────────
class _CurrencyPickerSheet extends StatefulWidget {
  final List<_CurrencyItem> currencies;
  final _CurrencyItem selected;

  const _CurrencyPickerSheet({
    required this.currencies,
    required this.selected,
  });

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.currencies
        .where((c) =>
            c.code.toLowerCase().contains(_query.toLowerCase()) ||
            c.name.contains(_query))
        .toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_gradientTop, _gradientBottom],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '통화 검색 (USD, 달러...)',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white70),
              ),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                final isSelected = item.code == widget.selected.code;
                return ListTile(
                  leading: Text(item.flag,
                      style: const TextStyle(fontSize: 24)),
                  title: Text(
                    item.code,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(item.name,
                      style: const TextStyle(color: Colors.white60)),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                  onTap: () => Navigator.pop(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
