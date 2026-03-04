// ─────────────────────────────────────────
// Result types
// ─────────────────────────────────────────

class PeriodResult {
  const PeriodResult({
    required this.totalDays,
    required this.weeks,
    required this.remainingDaysAfterWeeks,
    required this.months,
    required this.remainingDaysAfterMonths,
    required this.years,
    required this.monthsAfterYears,
    required this.daysAfterYearsMonths,
  });

  /// 총 일수 (includeStartDay 반영)
  final int totalDays;
  final int weeks;
  final int remainingDaysAfterWeeks;

  /// 달력 기준 전체 개월 수
  final int months;

  /// months 개월 이후 남은 일수
  final int remainingDaysAfterMonths;

  /// 달력 기준 전체 연수
  final int years;

  /// years 년 이후 남은 개월 수
  final int monthsAfterYears;

  /// years 년 + monthsAfterYears 개월 이후 남은 일수
  final int daysAfterYearsMonths;
}

class DDayResult {
  const DDayResult({
    required this.totalDays,
    required this.isToday,
    required this.isPast,
    required this.weeks,
    required this.remainingDaysAfterWeeks,
    required this.months,
    required this.remainingDaysAfterMonths,
  });

  /// 부호 포함 (양수=미래, 음수=과거, 0=당일)
  final int totalDays;
  final bool isToday;
  final bool isPast;

  /// abs(totalDays) 기반
  final int weeks;
  final int remainingDaysAfterWeeks;

  /// 달력 기준 전체 개월 수 (절댓값 기반)
  final int months;
  final int remainingDaysAfterMonths;
}

// ─────────────────────────────────────────
// UseCase
// ─────────────────────────────────────────

class DateCalculateUseCase {
  /// 두 날짜 사이의 기간 계산.
  /// start > end 이어도 절댓값으로 계산 (내부 swap).
  PeriodResult calculatePeriod(
    DateTime start,
    DateTime end,
    bool includeStartDay,
  ) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    final from = s.isAfter(e) ? e : s;
    final to = s.isAfter(e) ? s : e;

    final totalDays = to.difference(from).inDays + (includeStartDay ? 1 : 0);
    final weeks = totalDays ~/ 7;
    final remainingDaysAfterWeeks = totalDays % 7;

    // 달력 기준 개월 분해
    final months = _fullMonths(from, to);
    final afterMonths = _addMonths(from, months);
    final remainingDaysAfterMonths = to.difference(afterMonths).inDays;

    // 달력 기준 연+월+일 분해
    int years = to.year - from.year;
    if (to.month < from.month ||
        (to.month == from.month && to.day < from.day)) {
      years--;
    }
    if (years < 0) years = 0;

    final afterYears = _addMonths(from, years * 12);
    final monthsAfterYears = _fullMonths(afterYears, to);
    final afterYearsMonths = _addMonths(afterYears, monthsAfterYears);
    final daysAfterYearsMonths = to.difference(afterYearsMonths).inDays;

    return PeriodResult(
      totalDays: totalDays,
      weeks: weeks,
      remainingDaysAfterWeeks: remainingDaysAfterWeeks,
      months: months,
      remainingDaysAfterMonths: remainingDaysAfterMonths,
      years: years,
      monthsAfterYears: monthsAfterYears,
      daysAfterYearsMonths: daysAfterYearsMonths,
    );
  }

  /// 기준일에서 n단위 더하기/빼기.
  /// unit: 0=일, 1=주, 2=월, 3=년 / direction: 0=더하기, 1=빼기
  DateTime calculateDate(
    DateTime base,
    int number,
    int unit,
    int direction,
  ) {
    final b = DateTime(base.year, base.month, base.day);
    final n = direction == 1 ? -number : number;
    switch (unit) {
      case 0:
        return b.add(Duration(days: n));
      case 1:
        return b.add(Duration(days: n * 7));
      case 2:
        return _addMonths(b, n);
      case 3:
        return _addMonths(b, n * 12);
      default:
        return b;
    }
  }

  /// D-Day 계산.
  /// totalDays: 양수=미래, 음수=과거, 0=당일
  DDayResult calculateDDay(DateTime target, DateTime reference) {
    final t = DateTime(target.year, target.month, target.day);
    final r = DateTime(reference.year, reference.month, reference.day);
    final totalDays = t.difference(r).inDays;
    final isToday = totalDays == 0;
    final isPast = totalDays < 0;
    final absDays = totalDays.abs();
    final weeks = absDays ~/ 7;
    final remainingDaysAfterWeeks = absDays % 7;

    final from = isPast ? t : r;
    final to = isPast ? r : t;
    final months = isToday ? 0 : _fullMonths(from, to);
    final afterMonths = _addMonths(from, months);
    final remainingDaysAfterMonths =
        isToday ? 0 : to.difference(afterMonths).inDays;

    return DDayResult(
      totalDays: totalDays,
      isToday: isToday,
      isPast: isPast,
      weeks: weeks,
      remainingDaysAfterWeeks: remainingDaysAfterWeeks,
      months: months,
      remainingDaysAfterMonths: remainingDaysAfterMonths,
    );
  }

  // ── 내부 헬퍼 ────────────────────────────────────────

  /// from → to 사이의 완전한 달력 개월 수
  int _fullMonths(DateTime from, DateTime to) {
    int m = (to.year - from.year) * 12 + (to.month - from.month);
    if (to.day < from.day) m--;
    return m < 0 ? 0 : m;
  }

  /// date 에 n 개월 더하기 (음수 가능). 말일 초과 시 해당 월 마지막 날로 클램프.
  DateTime _addMonths(DateTime date, int n) {
    final raw = date.year * 12 + (date.month - 1) + n;
    final totalMonths = raw < 0 ? 0 : raw;
    final y = totalMonths ~/ 12;
    final m = totalMonths % 12 + 1;
    final maxDay = DateTime(y, m + 1, 0).day;
    final d = date.day.clamp(1, maxDay);
    return DateTime(y, m, d);
  }
}
