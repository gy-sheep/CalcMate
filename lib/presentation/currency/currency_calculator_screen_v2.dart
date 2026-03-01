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
const _gradientTop = Color(0xFF3B1466);
const _gradientBottom = Color(0xFF7B1E2E);
const _keypadBg = Colors.transparent;
const _dividerColor = Color(0x55FFFFFF);

// ──────────────────────────────────────────
// 메인 화면 V2
// ──────────────────────────────────────────
class CurrencyCalculatorScreenV2 extends StatefulWidget {
  const CurrencyCalculatorScreenV2({super.key});

  @override
  State<CurrencyCalculatorScreenV2> createState() =>
      _CurrencyCalculatorScreenV2State();
}

class _CurrencyCalculatorScreenV2State
    extends State<CurrencyCalculatorScreenV2> {
  _CurrencyItem _fromCurrency = _mockCurrencies[1]; // USD
  _CurrencyItem _toCurrency = _mockCurrencies[3];   // EUR
  String _fromInput = '120';
  bool _isFromActive = true; // true: 상단 입력 중, false: 하단 입력 중

  // 현재 활성 입력값
  String get _activeInput => _isFromActive ? _fromInput : _toInput;

  // 환산 결과 (역방향 포함)
  String get _toInput {
    if (!_isFromActive) return _fromInput; // 하단 직접 입력 시 원본 반환
    final from = double.tryParse(_fromInput) ?? 0;
    // from → KRW → to 변환
    final inKrw = from / _fromCurrency.rate;
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

  void _onKeyTap(String key) {
    setState(() {
      if (key == 'C') {
        _fromInput = '0';
        return;
      }

      if (key == 'DEL') {
        if (_fromInput.length > 1) {
          _fromInput = _fromInput.substring(0, _fromInput.length - 1);
        } else {
          _fromInput = '0';
        }
        return;
      }

      if (_fromInput == '0' && key != '.') {
        _fromInput = key;
      } else if (key == '.' && _fromInput.contains('.')) {
        // 소수점 중복 방지
      } else {
        _fromInput += key;
      }
    });
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
                    _NumberPad(onKeyTap: _onKeyTap),
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
          const Text(
            'Currency Converter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
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
// 숫자 키패드
// ──────────────────────────────────────────
class _NumberPad extends StatelessWidget {
  final void Function(String) onKeyTap;

  const _NumberPad({required this.onKeyTap});

  static const _keys = [
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    ['C', '0', '.'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _keys.map((row) {
        return Row(
          children: row.map((key) {
            final isSpecial = key == 'C';
            return Expanded(
              child: _KeypadButton(
                label: key,
                isSpecial: isSpecial,
                onTap: () => onKeyTap(key),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String label;
  final bool isSpecial;
  final VoidCallback onTap;

  const _KeypadButton({
    required this.label,
    required this.isSpecial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white24,
          child: Container(
            height: 64,
            decoration: const BoxDecoration(
              color: _keypadBg,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isSpecial ? Colors.redAccent[100] : Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w400,
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
