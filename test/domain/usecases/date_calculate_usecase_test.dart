import 'package:flutter_test/flutter_test.dart';
import 'package:calcmate/domain/usecases/date_calculate_usecase.dart';

void main() {
  late DateCalculateUseCase useCase;

  setUp(() {
    useCase = DateCalculateUseCase();
  });

  // ─────────────────────────────────────────
  // calculatePeriod
  // ─────────────────────────────────────────

  group('calculatePeriod — totalDays', () {
    test('같은 날: 0일', () {
      final r = useCase.calculatePeriod(
        DateTime(2026, 3, 4), DateTime(2026, 3, 4), false);
      expect(r.totalDays, 0);
    });

    test('3/1 ~ 3/3, includeStartDay=false → 2일', () {
      final r = useCase.calculatePeriod(
        DateTime(2026, 3, 1), DateTime(2026, 3, 3), false);
      expect(r.totalDays, 2);
    });

    test('3/1 ~ 3/3, includeStartDay=true → 3일', () {
      final r = useCase.calculatePeriod(
        DateTime(2026, 3, 1), DateTime(2026, 3, 3), true);
      expect(r.totalDays, 3);
    });

    test('start > end 이어도 절댓값 결과 동일', () {
      final forward = useCase.calculatePeriod(
        DateTime(2026, 3, 1), DateTime(2026, 3, 10), false);
      final backward = useCase.calculatePeriod(
        DateTime(2026, 3, 10), DateTime(2026, 3, 1), false);
      expect(forward.totalDays, backward.totalDays);
    });
  });

  group('calculatePeriod — weeks', () {
    test('14일 → 2주 0일', () {
      final r = useCase.calculatePeriod(
        DateTime(2026, 1, 1), DateTime(2026, 1, 15), false);
      expect(r.totalDays, 14);
      expect(r.weeks, 2);
      expect(r.remainingDaysAfterWeeks, 0);
    });

    test('15일 → 2주 1일', () {
      final r = useCase.calculatePeriod(
        DateTime(2026, 1, 1), DateTime(2026, 1, 16), false);
      expect(r.totalDays, 15);
      expect(r.weeks, 2);
      expect(r.remainingDaysAfterWeeks, 1);
    });
  });

  group('calculatePeriod — months', () {
    test('3/4 ~ 12/31 → 9개월 27일', () {
      final r = useCase.calculatePeriod(
        DateTime(2026, 3, 4), DateTime(2026, 12, 31), false);
      expect(r.months, 9);
      expect(r.remainingDaysAfterMonths, 27);
    });

    test('1/31 ~ 2/28 → 0개월 28일 (말일 전 도달)', () {
      final r = useCase.calculatePeriod(
        DateTime(2026, 1, 31), DateTime(2026, 2, 28), false);
      expect(r.months, 0);
      expect(r.remainingDaysAfterMonths, 28);
    });

    test('1/1 ~ 12/31 → 11개월 30일', () {
      final r = useCase.calculatePeriod(
        DateTime(2026, 1, 1), DateTime(2026, 12, 31), false);
      expect(r.months, 11);
      expect(r.remainingDaysAfterMonths, 30);
    });
  });

  group('calculatePeriod — years', () {
    test('3/4 ~ 12/31 → 0년 9개월 27일', () {
      final r = useCase.calculatePeriod(
        DateTime(2026, 3, 4), DateTime(2026, 12, 31), false);
      expect(r.years, 0);
      expect(r.monthsAfterYears, 9);
      expect(r.daysAfterYearsMonths, 27);
    });

    test('2023/1/1 ~ 2025/3/4 → 2년 2개월 3일', () {
      final r = useCase.calculatePeriod(
        DateTime(2023, 1, 1), DateTime(2025, 3, 4), false);
      expect(r.years, 2);
      expect(r.monthsAfterYears, 2);
      expect(r.daysAfterYearsMonths, 3);
    });

    test('2024/3/1 ~ 2026/3/1 → 2년 0개월 0일', () {
      final r = useCase.calculatePeriod(
        DateTime(2024, 3, 1), DateTime(2026, 3, 1), false);
      expect(r.years, 2);
      expect(r.monthsAfterYears, 0);
      expect(r.daysAfterYearsMonths, 0);
    });
  });

  // ─────────────────────────────────────────
  // calculateDate
  // ─────────────────────────────────────────

  group('calculateDate — 일 단위', () {
    test('3/4 + 100일 → 6/12', () {
      final r = useCase.calculateDate(DateTime(2026, 3, 4), 100, 0, 0);
      expect(r, DateTime(2026, 6, 12));
    });

    test('3/4 − 5일 → 2/27', () {
      final r = useCase.calculateDate(DateTime(2026, 3, 4), 5, 0, 1);
      expect(r, DateTime(2026, 2, 27));
    });
  });

  group('calculateDate — 주 단위', () {
    test('3/4 + 1주 → 3/11', () {
      final r = useCase.calculateDate(DateTime(2026, 3, 4), 1, 1, 0);
      expect(r, DateTime(2026, 3, 11));
    });

    test('3/4 − 2주 → 2/18', () {
      final r = useCase.calculateDate(DateTime(2026, 3, 4), 2, 1, 1);
      expect(r, DateTime(2026, 2, 18));
    });
  });

  group('calculateDate — 월 단위', () {
    test('3/4 + 1개월 → 4/4', () {
      final r = useCase.calculateDate(DateTime(2026, 3, 4), 1, 2, 0);
      expect(r, DateTime(2026, 4, 4));
    });

    test('1/31 + 1개월 → 2/28 (말일 클램프)', () {
      final r = useCase.calculateDate(DateTime(2026, 1, 31), 1, 2, 0);
      expect(r, DateTime(2026, 2, 28)); // 2026은 윤년 아님
    });

    test('1/31 + 3개월 → 4/30 (말일 클램프)', () {
      final r = useCase.calculateDate(DateTime(2026, 1, 31), 3, 2, 0);
      expect(r, DateTime(2026, 4, 30));
    });

    test('3/4 − 1개월 → 2/4', () {
      final r = useCase.calculateDate(DateTime(2026, 3, 4), 1, 2, 1);
      expect(r, DateTime(2026, 2, 4));
    });
  });

  group('calculateDate — 년 단위', () {
    test('3/4 + 2년 → 2028/3/4', () {
      final r = useCase.calculateDate(DateTime(2026, 3, 4), 2, 3, 0);
      expect(r, DateTime(2028, 3, 4));
    });

    test('2024/2/29 + 1년 → 2025/2/28 (말일 클램프)', () {
      final r = useCase.calculateDate(DateTime(2024, 2, 29), 1, 3, 0);
      expect(r, DateTime(2025, 2, 28)); // 2025는 윤년 아님
    });
  });

  // ─────────────────────────────────────────
  // calculateDDay
  // ─────────────────────────────────────────

  group('calculateDDay', () {
    test('당일 → isToday=true, totalDays=0', () {
      final r = useCase.calculateDDay(
        DateTime(2026, 3, 4), DateTime(2026, 3, 4));
      expect(r.isToday, true);
      expect(r.totalDays, 0);
    });

    test('미래: 3/4 → 1/1/2027 → totalDays 양수, isPast=false', () {
      final r = useCase.calculateDDay(
        DateTime(2027, 1, 1), DateTime(2026, 3, 4));
      expect(r.isPast, false);
      expect(r.totalDays, greaterThan(0));
    });

    test('과거: target=1/1, reference=3/4 → isPast=true', () {
      final r = useCase.calculateDDay(
        DateTime(2026, 1, 1), DateTime(2026, 3, 4));
      expect(r.isPast, true);
      expect(r.totalDays, lessThan(0));
    });

    test('7일 후 → 1주 0일', () {
      final r = useCase.calculateDDay(
        DateTime(2026, 3, 11), DateTime(2026, 3, 4));
      expect(r.weeks, 1);
      expect(r.remainingDaysAfterWeeks, 0);
    });

    test('8일 후 → 1주 1일', () {
      final r = useCase.calculateDDay(
        DateTime(2026, 3, 12), DateTime(2026, 3, 4));
      expect(r.weeks, 1);
      expect(r.remainingDaysAfterWeeks, 1);
    });

    test('1개월 후 months=1, remainingDays=0', () {
      final r = useCase.calculateDDay(
        DateTime(2026, 4, 4), DateTime(2026, 3, 4));
      expect(r.months, 1);
      expect(r.remainingDaysAfterMonths, 0);
    });
  });
}
