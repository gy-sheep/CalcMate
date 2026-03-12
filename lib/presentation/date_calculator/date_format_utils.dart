import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/l10n/data_strings.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../l10n/app_localizations.dart';
import 'date_calculator_colors.dart';

// ── 날짜 포맷 헬퍼 ──────────────────────────────────────
String formatYear(DateTime d, AppLocalizations l10n) =>
    l10n.date_format_year(d.year);

String formatMonthDay(DateTime d, AppLocalizations l10n) =>
    l10n.date_format_md(d.month, d.day);

String formatWeekday(DateTime d, Locale locale) =>
    DataStrings.weekdayFull(d.weekday, locale);

String formatDateShort(DateTime d, Locale locale) {
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return locale.languageCode == 'ko'
      ? '${d.year}.$mm.$dd'
      : '$mm/$dd/${d.year}';
}

// ── 공통 서브텍스트 위젯 ─────────────────────────────────
Widget buildSubText(String text) {
  return Text(
    text,
    textAlign: TextAlign.center,
    overflow: TextOverflow.ellipsis,
    style: textStyleCaption.copyWith(color: kDateTextSecondary),
  );
}
