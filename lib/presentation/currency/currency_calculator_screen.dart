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
  _CurrencyItem(code: 'USD', name: '미국 달러', flag: '🇺🇸', rate: 0.00075),
  _CurrencyItem(code: 'JPY', name: '일본 엔', flag: '🇯🇵', rate: 0.110),
  _CurrencyItem(code: 'EUR', name: '유로', flag: '🇪🇺', rate: 0.00069),
  _CurrencyItem(code: 'CNY', name: '중국 위안', flag: '🇨🇳', rate: 0.0054),
  _CurrencyItem(code: 'GBP', name: '영국 파운드', flag: '🇬🇧', rate: 0.00059),
  _CurrencyItem(code: 'AUD', name: '호주 달러', flag: '🇦🇺', rate: 0.0011),
  _CurrencyItem(code: 'CAD', name: '캐나다 달러', flag: '🇨🇦', rate: 0.0010),
  _CurrencyItem(code: 'CHF', name: '스위스 프랑', flag: '🇨🇭', rate: 0.00066),
];

// ──────────────────────────────────────────
// 메인 화면
// ──────────────────────────────────────────
class CurrencyCalculatorScreen extends StatefulWidget {
  const CurrencyCalculatorScreen({super.key});

  @override
  State<CurrencyCalculatorScreen> createState() =>
      _CurrencyCalculatorScreenState();
}

class _CurrencyCalculatorScreenState extends State<CurrencyCalculatorScreen> {
  String _inputAmount = '0';
  final List<_CurrencyItem> _selectedCurrencies = [
    _mockCurrencies[0], // USD
    _mockCurrencies[1], // JPY
    _mockCurrencies[2], // EUR
  ];

  double get _amount =>
      double.tryParse(_inputAmount.replaceAll(',', '')) ?? 0;

  void _onKeyTap(String key) {
    setState(() {
      if (key == 'DEL') {
        if (_inputAmount.length > 1) {
          _inputAmount = _inputAmount.substring(0, _inputAmount.length - 1);
        } else {
          _inputAmount = '0';
        }
      } else if (key == 'C') {
        _inputAmount = '0';
      } else if (_inputAmount == '0' && key != '.') {
        _inputAmount = key;
      } else if (key == '.' && _inputAmount.contains('.')) {
        // 소수점 중복 방지
      } else {
        _inputAmount += key;
      }
    });
  }

  void _removeCurrency(_CurrencyItem item) {
    setState(() => _selectedCurrencies.remove(item));
  }

  Future<void> _showAddCurrencySheet() async {
    final available = _mockCurrencies
        .where((c) => !_selectedCurrencies.contains(c))
        .toList();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CurrencyPickerSheet(
        available: available,
        onSelected: (item) {
          setState(() => _selectedCurrencies.add(item));
          Navigator.pop(context);
        },
      ),
    );
  }

  String _formatAmount(double value) {
    if (value >= 1) {
      return value.toStringAsFixed(2);
    } else {
      return value.toStringAsFixed(4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('환율 계산기'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 기준 통화 입력 영역
          _BaseCurrencyCard(amount: _inputAmount),
          const SizedBox(height: 8),

          // 변환 결과 목록
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '변환 결과',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showAddCurrencySheet,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('추가'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _selectedCurrencies.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _selectedCurrencies[index];
                      final converted = _amount * item.rate;
                      return _ConvertedCurrencyCard(
                        item: item,
                        convertedAmount: _formatAmount(converted),
                        onRemove: () => _removeCurrency(item),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 숫자 키패드
          _NumberPad(onKeyTap: _onKeyTap),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// 기준 통화 카드
// ──────────────────────────────────────────
class _BaseCurrencyCard extends StatelessWidget {
  final String amount;

  const _BaseCurrencyCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🇰🇷', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'KRW - 한국 원',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              Text(
                '₩$amount',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
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
// 변환 결과 카드
// ──────────────────────────────────────────
class _ConvertedCurrencyCard extends StatelessWidget {
  final _CurrencyItem item;
  final String convertedAmount;
  final VoidCallback onRemove;

  const _ConvertedCurrencyCard({
    required this.item,
    required this.convertedAmount,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(item.flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.code} - ${item.name}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '$convertedAmount ${item.code}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
          ),
        ],
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
    ['7', '8', '9', 'DEL'],
    ['4', '5', '6', 'C'],
    ['1', '2', '3', ''],
    ['0', '00', '.', ''],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: _keys.map((row) {
          return Row(
            children: row.map((key) {
              if (key.isEmpty) return const Expanded(child: SizedBox());
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: TextButton(
                    onPressed: () => onKeyTap(key),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      key,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 통화 선택 Bottom Sheet
// ──────────────────────────────────────────
class _CurrencyPickerSheet extends StatefulWidget {
  final List<_CurrencyItem> available;
  final void Function(_CurrencyItem) onSelected;

  const _CurrencyPickerSheet({
    required this.available,
    required this.onSelected,
  });

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.available
        .where((c) =>
            c.code.toLowerCase().contains(_query.toLowerCase()) ||
            c.name.contains(_query))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '통화 검색 (USD, 달러...)',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return ListTile(
                      leading: Text(item.flag,
                          style: const TextStyle(fontSize: 24)),
                      title: Text(item.code,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(item.name),
                      onTap: () => widget.onSelected(item),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
