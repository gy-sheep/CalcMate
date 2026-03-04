import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../domain/models/age_calculator_state.dart';
import '../widgets/app_segment_control.dart';
import 'age_calculator_colors.dart';
import 'age_calculator_viewmodel.dart';
import 'widgets/empty_state.dart';
import 'widgets/picker_section.dart';
import 'widgets/result_scroll_view.dart';

// ─────────────────────────────────────────
// Screen
// ─────────────────────────────────────────
class AgeCalculatorScreen extends ConsumerStatefulWidget {
  const AgeCalculatorScreen({
    super.key,
    required this.title,
  });

  final String title;

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
      backgroundColor: kAgeBgStart,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: kAgeText,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: kAgeText,
            fontSize: AppTokens.fontSizeAppBarTitle,
            fontWeight: AppTokens.weightAppBarTitle,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kAgeBgStart, kAgeBgEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: AppSegmentControl<AgeCalendarType>(
                  value: state.calendarType,
                  segments: const [
                    (AgeCalendarType.solar, '양력'),
                    (AgeCalendarType.lunar, '음력'),
                  ],
                  onChanged: (t) => vm.handleIntent(
                    AgeCalculatorIntent.calendarTypeChanged(t),
                  ),
                  trackColor: kAgePickerHighlight,
                  thumbColor: Colors.white,
                  activeTextColor: kAgeAccent,
                  inactiveTextColor: kAgeSubText,
                ),
              ),
              PickerSection(
                state: state,
                vm: vm,
                yearCtrl: _yearCtrl,
                monthCtrl: _monthCtrl,
                dayCtrl: _dayCtrl,
              ),
              const Divider(color: kAgeDivider, height: 1, thickness: 1),
              Expanded(
                child: result == null
                    ? const EmptyState()
                    : ResultScrollView(state: state, result: result),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
