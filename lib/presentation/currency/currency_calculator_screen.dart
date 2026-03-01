import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'currency_calculator_viewmodel.dart';

// ──────────────────────────────────────────
// 통화 정보 (코드, 이름, 국기)
// ──────────────────────────────────────────
class CurrencyInfo {
  final String code;
  final String name;
  final String flag;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.flag,
  });
}

const _currencyList = [
  CurrencyInfo(code: 'KRW', name: '한국 원', flag: '\u{1F1F0}\u{1F1F7}'),
  CurrencyInfo(code: 'USD', name: '미국 달러', flag: '\u{1F1FA}\u{1F1F8}'),
  CurrencyInfo(code: 'JPY', name: '일본 엔', flag: '\u{1F1EF}\u{1F1F5}'),
  CurrencyInfo(code: 'EUR', name: '유로', flag: '\u{1F1EA}\u{1F1FA}'),
  CurrencyInfo(code: 'CNY', name: '중국 위안', flag: '\u{1F1E8}\u{1F1F3}'),
  CurrencyInfo(code: 'GBP', name: '영국 파운드', flag: '\u{1F1EC}\u{1F1E7}'),
  CurrencyInfo(code: 'AUD', name: '호주 달러', flag: '\u{1F1E6}\u{1F1FA}'),
  CurrencyInfo(code: 'CAD', name: '캐나다 달러', flag: '\u{1F1E8}\u{1F1E6}'),
  CurrencyInfo(code: 'CHF', name: '스위스 프랑', flag: '\u{1F1E8}\u{1F1ED}'),
  CurrencyInfo(code: 'HKD', name: '홍콩 달러', flag: '\u{1F1ED}\u{1F1F0}'),
  CurrencyInfo(code: 'SGD', name: '싱가포르 달러', flag: '\u{1F1F8}\u{1F1EC}'),
  CurrencyInfo(code: 'TWD', name: '대만 달러', flag: '\u{1F1F9}\u{1F1FC}'),
  CurrencyInfo(code: 'THB', name: '태국 바트', flag: '\u{1F1F9}\u{1F1ED}'),
  CurrencyInfo(code: 'VND', name: '베트남 동', flag: '\u{1F1FB}\u{1F1F3}'),
  CurrencyInfo(code: 'PHP', name: '필리핀 페소', flag: '\u{1F1F5}\u{1F1ED}'),
  CurrencyInfo(code: 'INR', name: '인도 루피', flag: '\u{1F1EE}\u{1F1F3}'),
  CurrencyInfo(code: 'MXN', name: '멕시코 페소', flag: '\u{1F1F2}\u{1F1FD}'),
  CurrencyInfo(code: 'BRL', name: '브라질 레알', flag: '\u{1F1E7}\u{1F1F7}'),
  CurrencyInfo(code: 'SEK', name: '스웨덴 크로나', flag: '\u{1F1F8}\u{1F1EA}'),
  CurrencyInfo(code: 'NOK', name: '노르웨이 크로네', flag: '\u{1F1F3}\u{1F1F4}'),
  CurrencyInfo(code: 'NZD', name: '뉴질랜드 달러', flag: '\u{1F1F3}\u{1F1FF}'),
  CurrencyInfo(code: 'TRY', name: '터키 리라', flag: '\u{1F1F9}\u{1F1F7}'),
  CurrencyInfo(code: 'RUB', name: '러시아 루블', flag: '\u{1F1F7}\u{1F1FA}'),
  CurrencyInfo(code: 'ZAR', name: '남아공 랜드', flag: '\u{1F1FF}\u{1F1E6}'),
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
// 메인 화면
// ──────────────────────────────────────────
class CurrencyCalculatorScreen extends ConsumerWidget {
  final String title;
  final IconData icon;

  const CurrencyCalculatorScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exchangeRateViewModelProvider);
    final vm = ref.read(exchangeRateViewModelProvider.notifier);

    final fromDisplay = state.isFromActive ? state.input : vm.reverseConvertedDisplay;
    final toDisplay = state.isFromActive ? vm.convertedDisplay : state.input;

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
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const Spacer(),
                        if (state.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              state.error!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        // 통화 행 + 스왑 버튼
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // From 행: 통화 코드 + 금액 (같은 Row로 정렬)
                              Row(
                                children: [
                                  _CurrencyCodeButton(
                                    code: state.fromCode,
                                    onTap: () => _selectCurrency(
                                      context, ref,
                                      isFrom: true,
                                      selectedCode: state.fromCode,
                                      rates: state.rates,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _AmountDisplay(
                                      amount: fromDisplay,
                                      isActive: state.isFromActive,
                                      onTap: () => vm.handleIntent(
                                          const ActiveRowChanged(true)),
                                    ),
                                  ),
                                ],
                              ),
                              // 스왑 버튼 (좌측 정렬)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _SwapButton(
                                    onTap: () =>
                                        vm.handleIntent(const Swapped()),
                                  ),
                                ),
                              ),
                              // To 행: 통화 코드 + 금액 (같은 Row로 정렬)
                              Row(
                                children: [
                                  _CurrencyCodeButton(
                                    code: state.toCode,
                                    onTap: () => _selectCurrency(
                                      context, ref,
                                      isFrom: false,
                                      selectedCode: state.toCode,
                                      rates: state.rates,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _AmountDisplay(
                                      amount: toDisplay,
                                      isActive: !state.isFromActive,
                                      onTap: () => vm.handleIntent(
                                          const ActiveRowChanged(false)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // 구분선
                        const Divider(
                            color: _dividerColor, thickness: 0.5, height: 1),
                        // 숫자 키패드
                        _NumberPad(
                          onKeyTap: (key) => vm.handleIntent(KeyTapped(key)),
                          isAcState: vm.isAcState,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    // 로딩 인디케이터 (화면 중앙 오버레이)
                    if (state.isLoading)
                      const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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
                tag: 'calc_icon_$title',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(icon, color: Colors.white, size: 15),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Hero(
                tag: 'calc_title_$title',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    title,
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

  Future<void> _selectCurrency(
    BuildContext context,
    WidgetRef ref, {
    required bool isFrom,
    required String selectedCode,
    required Map<String, double> rates,
  }) async {
    // rates에 있는 통화만 필터링하여 표시
    final available = rates.isEmpty
        ? _currencyList
        : _currencyList
            .where((c) => rates.containsKey(c.code))
            .toList();

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CurrencyPickerSheet(
        currencies: available,
        selectedCode: selectedCode,
      ),
    );
    if (result == null) return;

    final vm = ref.read(exchangeRateViewModelProvider.notifier);
    if (isFrom) {
      vm.handleIntent(FromCurrencyChanged(result));
    } else {
      vm.handleIntent(ToCurrencyChanged(result));
    }
  }
}

// ──────────────────────────────────────────
// 통화 코드 버튼 (좌측)
// ──────────────────────────────────────────
class _CurrencyCodeButton extends StatelessWidget {
  final String code;
  final VoidCallback onTap;

  const _CurrencyCodeButton({required this.code, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            code,
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
    );
  }
}

// ──────────────────────────────────────────
// 금액 표시 (우측)
// ──────────────────────────────────────────
class _AmountDisplay extends StatelessWidget {
  final String amount;
  final bool isActive;
  final VoidCallback onTap;

  const _AmountDisplay({
    required this.amount,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              amount,
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w300,
                letterSpacing: -1,
              ),
            ),
          ),
          Container(
            height: 1.5,
            color: isActive ? Colors.white : Colors.white38,
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
    [
      ('\u{232B}', _BtnType.function),
      ('AC', _BtnType.function),
      ('%', _BtnType.function),
      ('\u{00F7}', _BtnType.operator)
    ],
    [
      ('7', _BtnType.number),
      ('8', _BtnType.number),
      ('9', _BtnType.number),
      ('\u{00D7}', _BtnType.operator)
    ],
    [
      ('4', _BtnType.number),
      ('5', _BtnType.number),
      ('6', _BtnType.number),
      ('-', _BtnType.operator)
    ],
    [
      ('1', _BtnType.number),
      ('2', _BtnType.number),
      ('3', _BtnType.number),
      ('+', _BtnType.operator)
    ],
    [
      ('+/-', _BtnType.function),
      ('0', _BtnType.number),
      ('.', _BtnType.number),
      ('=', _BtnType.equals)
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _rows.map((row) {
        return Row(
          children: row.map((cell) {
            final label =
                cell.$1 == 'AC' ? (isAcState ? 'AC' : 'C') : cell.$1;
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
            child: label == '\u{232B}'
                ? Icon(Icons.backspace_outlined, color: _textColor, size: 26)
                : Text(
                    label,
                    style: TextStyle(
                      fontSize:
                          const ['\u{00F7}', '\u{00D7}', '-', '+', '=']
                                  .contains(label)
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
  final List<CurrencyInfo> currencies;
  final String selectedCode;

  const _CurrencyPickerSheet({
    required this.currencies,
    required this.selectedCode,
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
                final isSelected = item.code == widget.selectedCode;
                return ListTile(
                  leading:
                      Text(item.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    item.code,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(item.name,
                      style: const TextStyle(color: Colors.white60)),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                  onTap: () => Navigator.pop(context, item.code),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
