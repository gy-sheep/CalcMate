import 'package:flutter/material.dart';

import '../../core/theme/app_design_tokens.dart';

// ── 날짜 계산기 색상 상수 ─────────────────────────────────
const kDateBg1 = Color(0xFFFBF0F0);
const kDateBg2 = Color(0xFFF5E2E2);
const kDateBg3 = Color(0xFFEDD1D1);
const kDateAccent = Color(0xFF9E4A50);
const kDateCardBg = Color(0xCCFFFFFF);
const kDateCardBorder = Color(0x339E4A50);
const kDateTextPrimary = Color(0xFF4A2030);
const kDateTextSecondary = Color(0xFF7A4455);
const kDateTextTertiary = Color(0xFFB08898);
const kDateDivider = Color(0xFFE2C4CC);

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
