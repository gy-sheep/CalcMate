import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/age_calculator_state.dart';
import '../../domain/utils/number_formatter.dart';
import '../../domain/usecases/age_calculate_usecase.dart';
import 'age_calculator_viewmodel.dart';

// ─────────────────────────────────────────
// 테마 상수
// ─────────────────────────────────────────
const _kBgStart         = Color(0xFFFFF8F0);
const _kBgEnd           = Color(0xFFFFE4CC);
const _kAccent          = Color(0xFFD4845A);
const _kAccentLight     = Color(0xFFF0A87A);
const _kText            = Color(0xFF3D2B1F);
const _kSubText         = Color(0xFF8B6651);
const _kPickerHighlight = Color(0xFFFFDCB8);
const _kCardShadow      = Color(0xFFD4845A);
const _kDivider         = Color(0xFFE8C9B0);

// ─────────────────────────────────────────
// Screen
// ─────────────────────────────────────────
class AgeCalculatorScreen extends ConsumerStatefulWidget {
  const AgeCalculatorScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  ConsumerState<AgeCalculatorScreen> createState() =>
      _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends ConsumerState<AgeCalculatorScreen>
    with WidgetsBindingObserver {
  static const int _minYear = 1900;

  late FixedExtentScrollController _yearCtrl;
  late FixedExtentScrollController _monthCtrl;
  late FixedExtentScrollController _dayCtrl;

  bool _syncingControllers = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final s = ref.read(ageCalculatorViewModelProvider);
    _yearCtrl  = FixedExtentScrollController(initialItem: s.year - _minYear);
    _monthCtrl = FixedExtentScrollController(initialItem: s.month - 1);
    _dayCtrl   = FixedExtentScrollController(initialItem: s.day - 1);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(ageCalculatorViewModelProvider.notifier).refreshToday();
    }
  }

  void _syncDayController(int targetDay) {
    if (_syncingControllers) return;
    _syncingControllers = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dayCtrl.hasClients && _dayCtrl.selectedItem != targetDay - 1) {
        _dayCtrl.animateToItem(
          targetDay - 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
      _syncingControllers = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ageCalculatorViewModelProvider);
    final vm    = ref.read(ageCalculatorViewModelProvider.notifier);

    // day 클램프 발생 시 컨트롤러 동기화
    ref.listen(
      ageCalculatorViewModelProvider.select((s) => s.day),
      (_, day) => _syncDayController(day),
    );

    final result = vm.ageResult;

    return Scaffold(
      backgroundColor: _kBgStart,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_kBgStart, _kBgEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _AppBarRow(title: widget.title, icon: widget.icon),
              _CalendarSegment(
                selected: state.calendarType,
                onChanged: (t) => vm.handleIntent(
                  AgeCalculatorIntent.calendarTypeChanged(t),
                ),
              ),
              _PickerSection(
                state: state,
                vm: vm,
                yearCtrl: _yearCtrl,
                monthCtrl: _monthCtrl,
                dayCtrl: _dayCtrl,
              ),
              const Divider(color: _kDivider, height: 1, thickness: 1),
              Expanded(
                child: result == null
                    ? const _EmptyState()
                    : _ResultScrollView(state: state, result: result),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// AppBar Row
// ─────────────────────────────────────────
class _AppBarRow extends StatelessWidget {
  const _AppBarRow({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: _kText,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Icon(icon, color: _kAccent, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: _kText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Calendar Type Segment
// ─────────────────────────────────────────
class _CalendarSegment extends StatelessWidget {
  const _CalendarSegment({
    required this.selected,
    required this.onChanged,
  });
  final AgeCalendarType selected;
  final ValueChanged<AgeCalendarType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: _kPickerHighlight.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: AgeCalendarType.values.map((type) {
            final isSelected = selected == type;
            final label = type == AgeCalendarType.solar ? '양력' : '음력';
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _kCardShadow.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? _kAccent : _kSubText,
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Picker Section
// ─────────────────────────────────────────
class _PickerSection extends StatelessWidget {
  const _PickerSection({
    required this.state,
    required this.vm,
    required this.yearCtrl,
    required this.monthCtrl,
    required this.dayCtrl,
  });

  final AgeCalculatorState state;
  final AgeCalculatorViewModel vm;
  final FixedExtentScrollController yearCtrl;
  final FixedExtentScrollController monthCtrl;
  final FixedExtentScrollController dayCtrl;

  static const int _minYear = 1900;
  static int get _maxYear => DateTime.now().year;

  int get _maxDay {
    try { return DateTime(state.year, state.month + 1, 0).day; }
    catch (_) { return 28; }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              state.calendarType == AgeCalendarType.solar
                  ? '생년월일'
                  : '생년월일 (음력)',
              style: const TextStyle(
                color: _kSubText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(
            height: 176,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 선택 하이라이트 바
                Container(
                  height: 44,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _kPickerHighlight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // 3개 피커
                Row(
                  children: [
                    // 연도
                    Expanded(
                      flex: 5,
                      child: _Picker(
                        controller: yearCtrl,
                        itemCount: _maxYear - _minYear + 1,
                        label: (i) => '${_minYear + i}년',
                        onChanged: (i) => vm.handleIntent(
                          AgeCalculatorIntent.yearChanged(_minYear + i),
                        ),
                      ),
                    ),
                    // 월
                    Expanded(
                      flex: 3,
                      child: _Picker(
                        controller: monthCtrl,
                        itemCount: 12,
                        label: (i) => '${i + 1}월',
                        onChanged: (i) => vm.handleIntent(
                          AgeCalculatorIntent.monthChanged(i + 1),
                        ),
                      ),
                    ),
                    // 일
                    Expanded(
                      flex: 3,
                      child: _Picker(
                        controller: dayCtrl,
                        itemCount: _maxDay,
                        label: (i) => '${i + 1}일',
                        onChanged: (i) => vm.handleIntent(
                          AgeCalculatorIntent.dayChanged(i + 1),
                        ),
                      ),
                    ),
                  ],
                ),
                // 상단 페이드
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 66,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFFF8F0), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
                // 하단 페이드
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 66,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xFFFFE4CC), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 음력 모드 부가 정보
          if (state.calendarType == AgeCalendarType.lunar) ...[
            const SizedBox(height: 8),
            _LunarInfo(state: state, vm: vm),
          ],
          // 오늘 기준일
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 8, left: 4),
            child: Text(
              '${_formatDate(DateTime.now())} 기준',
              style: const TextStyle(
                color: _kSubText,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}년 ${d.month}월 ${d.day}일';
}

// ─────────────────────────────────────────
// 단일 드럼롤 피커
// ─────────────────────────────────────────
class _Picker extends StatelessWidget {
  const _Picker({
    required this.controller,
    required this.itemCount,
    required this.label,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int index) label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 44,
      physics: const FixedExtentScrollPhysics(),
      perspective: 0.002,
      diameterRatio: 1.6,
      squeeze: 0.95,
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final isSelected = controller.hasClients &&
              controller.selectedItem == index;
          return Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                color: isSelected ? _kAccent : _kText.withValues(alpha: 0.5),
                fontSize: isSelected ? 18 : 15,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
              child: Text(label(index)),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
// 음력 부가 정보 (음력 모드에서만)
// ─────────────────────────────────────────
class _LunarInfo extends StatelessWidget {
  const _LunarInfo({required this.state, required this.vm});
  final AgeCalculatorState state;
  final AgeCalculatorViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kDivider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '음력 변환 기능은 다음 업데이트에 지원됩니다.\n현재는 양력과 동일하게 계산됩니다.',
              style: const TextStyle(color: _kSubText, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 결과 스크롤 뷰
// ─────────────────────────────────────────
class _ResultScrollView extends StatelessWidget {
  const _ResultScrollView({required this.state, required this.result});
  final AgeCalculatorState state;
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          _AgeCard(result: result),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _NextBirthdayCard(result: result)),
              const SizedBox(width: 12),
              Expanded(child: _DaysLivedCard(result: result)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ZodiacCard(result: result)),
              const SizedBox(width: 12),
              Expanded(child: _ConstellationCard(result: result)),
            ],
          ),
          const SizedBox(height: 12),
          _BirthWeekdayRow(result: result),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 나이 카드
// ─────────────────────────────────────────
class _AgeCard extends StatelessWidget {
  const _AgeCard({required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 만 나이 (primary)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${result.koreanAge}',
                  style: const TextStyle(
                    color: _kAccent,
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 6),
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    '세',
                    style: TextStyle(
                      color: _kAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '만 나이',
                    style: TextStyle(
                      color: _kAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: _kDivider, height: 1),
            const SizedBox(height: 14),
            _AgeRow(label: '세는 나이', value: '${result.countingAge}세'),
            const SizedBox(height: 10),
            _AgeRow(label: '연 나이',   value: '${result.yearAge}세'),
          ],
        ),
      ),
    );
  }
}

class _AgeRow extends StatelessWidget {
  const _AgeRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: _kSubText, fontSize: 14)),
        Text(value,
            style: const TextStyle(
                color: _kText,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ─────────────────────────────────────────
// 다음 생일 카드
// ─────────────────────────────────────────
class _NextBirthdayCard extends StatelessWidget {
  const _NextBirthdayCard({required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    if (result.isBirthdayToday) {
      return _Card(
        child: Container(
          height: 110,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('🎂', style: TextStyle(fontSize: 28)),
              SizedBox(height: 6),
              Text(
                '오늘이 생일이에요!',
                style: TextStyle(
                  color: _kAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dDays = result.nextBirthday.difference(todayOnly).inDays;
    final nb = result.nextBirthday;
    final nextDateStr =
        '${nb.month}월 ${nb.day}일 (${kWeekdays[nb.weekday].replaceAll('요일', '')})';

    return _Card(
      child: SizedBox(
        height: 110,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '다음 생일',
                style: TextStyle(
                  color: _kSubText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'D-$dDays',
                style: const TextStyle(
                  color: _kAccent,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nextDateStr,
                style: const TextStyle(color: _kSubText, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 살아온 날 카드
// ─────────────────────────────────────────
class _DaysLivedCard extends StatelessWidget {
  const _DaysLivedCard({required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    final days = result.daysLived;
    // 약 몇 년 몇 개월
    final years  = days ~/ 365;
    final months = (days % 365) ~/ 30;
    final sub = months > 0 ? '약 $years년 $months개월' : '약 $years년';

    return _Card(
      child: SizedBox(
        height: 110,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '살아온 날',
                style: TextStyle(
                  color: _kSubText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${NumberFormatter.addCommas(days.toString())}일',
                style: const TextStyle(
                  color: _kText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(sub,
                  style: const TextStyle(color: _kSubText, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 띠 카드
// ─────────────────────────────────────────
class _ZodiacCard extends StatelessWidget {
  const _ZodiacCard({required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    final (name, emoji) = kZodiacs[result.zodiacIndex];
    return _Card(
      child: SizedBox(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '띠',
                style: TextStyle(
                    color: _kSubText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                '$name띠',
                style: const TextStyle(
                    color: _kText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 별자리 카드
// ─────────────────────────────────────────
class _ConstellationCard extends StatelessWidget {
  const _ConstellationCard({required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    final (name, symbol) = kConstellations[result.constellationIndex];
    return _Card(
      child: SizedBox(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '별자리',
                style: TextStyle(
                    color: _kSubText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                symbol,
                style: const TextStyle(
                  color: _kAccentLight,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                    color: _kText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 태어난 요일 행
// ─────────────────────────────────────────
class _BirthWeekdayRow extends StatelessWidget {
  const _BirthWeekdayRow({required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '태어난 요일',
              style: TextStyle(color: _kSubText, fontSize: 14),
            ),
            Text(
              kWeekdays[result.birthWeekday],
              style: const TextStyle(
                color: _kText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 빈 상태 (미래 날짜 선택 시)
// ─────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '미래 날짜는 계산할 수 없어요',
        style: TextStyle(color: _kSubText, fontSize: 15),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 공통 카드 컨테이너
// ─────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kCardShadow.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
