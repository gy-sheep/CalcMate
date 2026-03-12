import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/models/age_calculator_state.dart';
import '../../../l10n/app_localizations.dart';
import '../age_calculator_colors.dart';
import '../age_calculator_viewmodel.dart';
import 'lunar_info.dart';
import 'picker.dart';

class PickerSection extends StatelessWidget {
  const PickerSection({
    super.key,
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

  int get _maxDay => vm.maxDaysForCurrentMonth();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6, right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    l10n.age_label_birthDate,
                    overflow: TextOverflow.ellipsis,
                    style: sectionLabel.copyWith(color: kAgeTextSecondary),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: CmCheckbox.sizeMedium,
                      height: CmCheckbox.sizeMedium,
                      child: Checkbox(
                        value: state.calendarType == AgeCalendarType.lunar,
                        onChanged: (v) => vm.handleIntent(
                          AgeCalculatorIntent.calendarTypeChanged(
                            v == true ? AgeCalendarType.lunar : AgeCalendarType.solar,
                          ),
                        ),
                        activeColor: kAgeAccent,
                        checkColor: Colors.white,
                        side: const BorderSide(color: kAgeTextSecondary, width: 1.5),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.age_label_lunar,
                      style: CmCheckbox.labelMedium.copyWith(color: kAgeTextSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radiusCard),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: SizedBox(
                  height: 136,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 글라스 틴트 배경
                      Container(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    // 선택 하이라이트 바 (글라스)
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: kAgePickerHighlight.withValues(alpha: 0.45),
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                    // 3개 피커 (ShaderMask로 상하 페이드)
                    ShaderMask(
                      shaderCallback: (Rect bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white,
                          Colors.white,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.34, 0.66, 1.0],
                      ).createShader(bounds),
                      blendMode: BlendMode.dstIn,
                      child: Row(
                        children: [
                          // 연도
                          Expanded(
                            flex: 4,
                            child: AgePicker(
                              controller: yearCtrl,
                              itemCount: _maxYear - _minYear + 1,
                              label: (i) => l10n.age_picker_year(_minYear + i),
                              onChanged: (i) => vm.handleIntent(
                                AgeCalculatorIntent.yearChanged(_minYear + i),
                              ),
                            ),
                          ),
                          // 월
                          Expanded(
                            flex: 3,
                            child: AgePicker(
                              controller: monthCtrl,
                              itemCount: 12,
                              label: (i) => l10n.age_picker_month(i + 1),
                              onChanged: (i) => vm.handleIntent(
                                AgeCalculatorIntent.monthChanged(i + 1),
                              ),
                            ),
                          ),
                          // 일
                          Expanded(
                            flex: 3,
                            child: AgePicker(
                              controller: dayCtrl,
                              itemCount: _maxDay,
                              label: (i) => l10n.age_picker_day(i + 1),
                              onChanged: (i) => vm.handleIntent(
                                AgeCalculatorIntent.dayChanged(i + 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                      // 스페큘러 하이라이트 (빛 반사)
                      Positioned(
                        top: 0, left: 0, right: 0,
                        child: IgnorePointer(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.4),
                                  Colors.white.withValues(alpha: 0),
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
            ),
          ),
          // 음력 모드 부가 정보
          if (state.calendarType == AgeCalendarType.lunar) ...[
            const SizedBox(height: 8),
            LunarInfo(state: state, vm: vm),
          ],
          // 오늘 기준일
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 8, left: 4),
            child: Text(
              l10n.age_label_asOf(_formatDate(DateTime.now(), l10n)),
              style: textStyleCaption.copyWith(color: kAgeTextSecondary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d, AppLocalizations l10n) =>
      l10n.date_format_ymd(d.year, d.month, d.day);
}
