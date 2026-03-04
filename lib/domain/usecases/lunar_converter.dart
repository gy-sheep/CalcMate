import 'package:korean_lunar_utils/korean_lunar_utils.dart';
// ignore: implementation_imports
import 'package:korean_lunar_utils/src/lunar_calendar.dart';

/// 음력↔양력 변환 래퍼.
/// korean_lunar_utils 패키지를 Domain 계층에서 직접 의존하지 않도록 캡슐화한다.
/// 지원 범위: 1900 ~ 2049
class LunarConverter {
  LunarConverter._();

  /// 음력 날짜를 양력 [DateTime]으로 변환한다.
  /// 범위를 벗어나거나 유효하지 않은 날짜면 null 반환.
  static DateTime? toSolar(
    int lunarYear,
    int lunarMonth,
    int lunarDay, {
    bool isLeap = false,
  }) {
    try {
      final lunarDate = LunarDate(
        lunarYear,
        lunarMonth,
        lunarDay,
        isLeapMonth: isLeap,
      );
      return LunarSolarConverter.convertLunarDateToSolar(lunarDate);
    } catch (_) {
      return null;
    }
  }

  /// 해당 음력 연·월에 윤달이 존재하면 true 반환.
  static bool hasLeapMonth(int lunarYear, int lunarMonth) {
    try {
      return LunarCalendar.leapMonthOfYear(lunarYear) == lunarMonth;
    } catch (_) {
      return false;
    }
  }

  /// 해당 음력 달의 일수(29 or 30)를 반환한다.
  /// [isLeap]이 true이면 윤달 일수를 반환.
  static int daysInMonth(int lunarYear, int lunarMonth, {bool isLeap = false}) {
    try {
      if (isLeap) {
        final days = LunarCalendar.leapMonthDays(lunarYear);
        return days > 0 ? days : 29;
      }
      return LunarCalendar.monthDays(lunarYear, lunarMonth);
    } catch (_) {
      return 29;
    }
  }
}
