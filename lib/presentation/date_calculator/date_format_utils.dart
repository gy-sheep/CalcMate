import 'package:flutter/material.dart';

import '../../core/theme/app_design_tokens.dart';
import 'date_calculator_colors.dart';

// ── 요일 이름 ───────────────────────────────────────────
const kWeekdayNames = ['', '월', '화', '수', '목', '금', '토', '일'];

// ── 날짜 포맷 헬퍼 ──────────────────────────────────────
String formatYear(DateTime d) => '${d.year}년';
String formatMonthDay(DateTime d) => '${d.month}월 ${d.day}일';
String formatWeekday(DateTime d) => '${kWeekdayNames[d.weekday]}요일';
String formatDateShort(DateTime d) =>
    '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

// ── 공통 서브텍스트 위젯 ─────────────────────────────────
Widget buildSubText(String text) {
  return Text(
    text,
    style: textStyleCaption.copyWith(color: kDateTextSecondary),
  );
}
