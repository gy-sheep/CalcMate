import 'dart:ui';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/currency_info.dart';
import 'currency_calculator_viewmodel.dart';

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

  String _formatLastUpdated(DateTime? dt, {required bool hasRates}) {
    if (dt == null) return hasRates ? '임시 환율 사용 중' : '환율 정보 없음';
    final isPm = dt.hour >= 12;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '${dt.year}.$month.$day. ${isPm ? '오후' : '오전'} $hour:$minute 기준';
  }

  void _showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 120,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1500), () => entry.remove());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exchangeRateViewModelProvider);
    final vm = ref.read(exchangeRateViewModelProvider.notifier);

    ref.listen(
      exchangeRateViewModelProvider.select((s) => s.toastMessage),
      (_, message) {
        if (message != null) {
          _showToast(context, message);
          vm.clearToast();
        }
      },
    );

    final fromDisplay = vm.formattedInput;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_gradientTop, _gradientBottom],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
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
                  // 통화 행들 — 부모 높이를 전부 사용
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // From 행
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _CurrencyCodeButton(
                                code: state.fromCode,
                                onTap: () => _selectCurrency(
                                  context, ref,
                                  toIndex: -1,
                                  selectedCode: state.fromCode,
                                  rates: state.rates,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _AmountDisplay(
                                  amount: fromDisplay,
                                  isActive: true,
                                ),
                              ),
                            ],
                          ),
                          // To 행 3개
                          for (int i = 0; i < state.toCodes.length; i++)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _CurrencyCodeButton(
                                  code: state.toCodes[i],
                                  onTap: () => _selectCurrency(
                                    context, ref,
                                    toIndex: i,
                                    selectedCode: state.toCodes[i],
                                    rates: state.rates,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _AmountDisplay(
                                    amount: vm.convertedDisplayAt(i),
                                    isActive: false,
                                    hint: vm.unitRateDisplayAt(i),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  // 업데이트 시간 + 새로고침
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 6),
                    child: Row(
                      children: [
                        Text(
                          _formatLastUpdated(
                            state.lastUpdated,
                            hasRates: state.rates.isNotEmpty,
                          ),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: state.isRefreshing
                              ? null
                              : () => vm.handleIntent(const ExchangeRateIntent.refreshRequested()),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: state.isRefreshing
                                ? const CupertinoActivityIndicator(
                                    radius: 10,
                                    color: Colors.white54,
                                  )
                                : const Icon(
                                    Icons.refresh,
                                    color: Colors.white54,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 구분선
                  const Divider(
                      color: _dividerColor, thickness: 0.5, height: 1),
                  // 숫자 키패드
                  _NumberPad(
                    onKeyTap: (key) => vm.handleIntent(ExchangeRateIntent.keyTapped(key)),
                    isAcState: vm.isAcState,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            // 로딩 오버레이 (화면 전체 dim + 인디케이터)
            if (state.isLoading)
              Container(
                color: Colors.black45,
              ),
            if (state.isLoading)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(width: 14),
                          Text(
                            '환율 정보를 가져오는 중...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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

  /// [toIndex] -1이면 From, 0/1/2이면 해당 To 행
  Future<void> _selectCurrency(
    BuildContext context,
    WidgetRef ref, {
    required int toIndex,
    required String selectedCode,
    required Map<String, double> rates,
  }) async {
    // rates에 있는 통화만 필터링하여 표시
    final available = rates.isEmpty
        ? kSupportedCurrencies
        : kSupportedCurrencies
            .where((c) => rates.containsKey(c.code))
            .toList();

    final state = ref.read(exchangeRateViewModelProvider);
    // From 선택: 현재 fromCode만 제외 (To 통화 선택 시 swap)
    // To 선택: fromCode + 나머지 toCodes 전체 제외
    final usedCodes = toIndex < 0
        ? {state.fromCode}
        : {state.fromCode, ...state.toCodes};

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CurrencyPickerSheet(
        currencies: available,
        selectedCode: selectedCode,
        usedCodes: usedCodes,
        fromCode: toIndex >= 0 ? state.fromCode : null,
      ),
    );
    if (result == null) return;

    final vm = ref.read(exchangeRateViewModelProvider.notifier);
    if (toIndex < 0) {
      vm.handleIntent(ExchangeRateIntent.fromCurrencyChanged(result));
    } else {
      vm.handleIntent(ExchangeRateIntent.toCurrencyChanged(toIndex, result));
    }
  }
}

// ──────────────────────────────────────────
// 통화 코드 버튼 (좌측) — 원형 국기 + 코드 세로 배치
// ──────────────────────────────────────────
class _CurrencyCodeButton extends StatelessWidget {
  final String code;
  final VoidCallback onTap;

  const _CurrencyCodeButton({required this.code, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CountryFlag.fromCurrencyCode(
              code,
              theme: const ImageTheme(
                width: 32,
                height: 32,
                shape: Circle(),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              code,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
  final String? hint;

  const _AmountDisplay({
    required this.amount,
    required this.isActive,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final amountWidget = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(
        amount,
        maxLines: 1,
        softWrap: false,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w300,
          letterSpacing: -1,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hint != null && hint!.isNotEmpty)
          Stack(
            clipBehavior: Clip.none,
            children: [
              amountWidget,
              Positioned(
                top: -16,
                right: 0,
                child: Text(
                  hint!,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          )
        else
          amountWidget,
        Container(
          height: 1.5,
          color: isActive ? Colors.white : Colors.white38,
        ),
      ],
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
      ('0', _BtnType.number),
      ('00', _BtnType.number),
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
  final Set<String> usedCodes;
  final String? fromCode;

  const _CurrencyPickerSheet({
    required this.currencies,
    required this.selectedCode,
    required this.usedCodes,
    this.fromCode,
  });

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  String _query = '';

  void _showCenterToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 1), () => entry.remove());
  }

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
                final isUsed = widget.usedCodes.contains(item.code);
                return ListTile(
                  leading: CountryFlag.fromCurrencyCode(
                    item.code,
                    theme: const ImageTheme(
                      width: 32,
                      height: 32,
                      shape: Circle(),
                    ),
                  ),
                  title: Text(
                    item.code,
                    style: TextStyle(
                      color: isUsed ? Colors.white38 : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    item.name,
                    style: TextStyle(
                      color: isUsed ? Colors.white24 : Colors.white60,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                  onTap: () {
                    if (isUsed) {
                      final message = item.code == widget.fromCode
                          ? '기준 통화로 사용 중입니다'
                          : '이미 선택된 통화입니다';
                      _showCenterToast(context, message);
                      return;
                    }
                    Navigator.pop(context, item.code);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
