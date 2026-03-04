import 'package:flutter_test/flutter_test.dart';
import 'package:calcmate/domain/usecases/age_calculate_usecase.dart';

void main() {
  late AgeCalculateUseCase useCase;

  setUp(() {
    useCase = AgeCalculateUseCase();
  });

  // 결정론적 테스트를 위해 고정된 기준일 사용 (2026-03-04)
  final fixedToday = DateTime(2026, 3, 4);

  group('만 나이 (koreanAge)', () {
    test('생일이 이미 지난 경우 — 만 나이 = 올해 − 출생연도', () {
      final birth = DateTime(1990, 1, 1);
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.koreanAge, 36); // 2026 - 1990
    });

    test('생일이 아직 안 지난 경우 — 만 나이 = 올해 − 출생연도 − 1', () {
      final birth = DateTime(1990, 12, 31);
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.koreanAge, 35); // 2026 - 1990 - 1
    });

    test('오늘이 생일 — 만 나이 정상, isBirthdayToday = true', () {
      final birth = DateTime(1990, 3, 4);
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.koreanAge, 36);
      expect(result.isBirthdayToday, true);
    });
  });

  group('세는 나이 / 연 나이', () {
    test('세는 나이 = 올해 − 출생연도 + 1', () {
      final birth = DateTime(1990, 6, 15);
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.countingAge, 37); // 2026 - 1990 + 1
    });

    test('연 나이 = 올해 − 출생연도', () {
      final birth = DateTime(1990, 6, 15);
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.yearAge, 36); // 2026 - 1990
    });
  });

  group('윤년 생일 처리', () {
    test('2/29 생일 — 비윤년의 다음 생일은 3/1로 처리', () {
      final birth = DateTime(2000, 2, 29);
      // fixedToday = 2026-03-04
      // 2026년 생일: DateTime(2026,2,29) 불가 → 3/1
      // 2026-03-01 < 2026-03-04 이므로 이미 지남
      // 다음 생일: 2027-03-01
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.nextBirthday, DateTime(2027, 3, 1));
    });

    test('2/29 생일 — 윤년인 경우 정확한 2/29 반환', () {
      final birth = DateTime(2000, 2, 29);
      // 기준일을 2028-02-01로 설정 (2028은 윤년)
      final ref = DateTime(2028, 2, 1);
      final result = useCase.execute(birthDate: birth, today: ref);
      expect(result.nextBirthday, DateTime(2028, 2, 29));
    });
  });

  group('띠 계산 (설날 기준 보정)', () {
    test('설날(2024-02-10) 이전 출생 — 전년도(2023) 띠(토끼=3) 적용', () {
      final birth = DateTime(2024, 2, 9);
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.zodiacIndex, 3); // 토끼띠
    });

    test('설날(2024-02-10) 당일 출생 — 해당연도(2024) 띠(용=4) 적용', () {
      final birth = DateTime(2024, 2, 10);
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.zodiacIndex, 4); // 용띠
    });
  });

  group('별자리 계산', () {
    test('1/15 → 염소자리(0)', () {
      final birth = DateTime(2000, 1, 15);
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.constellationIndex, 0);
    });

    test('3/21 → 양자리(3)', () {
      final birth = DateTime(1995, 3, 21);
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.constellationIndex, 3);
    });

    test('7/20 → 게자리(6)', () {
      final birth = DateTime(1995, 7, 20);
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.constellationIndex, 6);
    });

    test('12/22 → 염소자리(0)', () {
      final birth = DateTime(1990, 12, 22);
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.constellationIndex, 0);
    });
  });

  group('살아온 날 (daysLived)', () {
    test('출생일~오늘 정확한 경과 일수', () {
      final birth = DateTime(2026, 3, 1); // 3일 전
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.daysLived, 3);
    });

    test('출생 당일 — 0일', () {
      final result = useCase.execute(
          birthDate: fixedToday, today: fixedToday);
      expect(result.daysLived, 0);
    });
  });

  group('다음 생일 D-day', () {
    test('아직 안 지난 생일 — 올해 생일 날짜 반환', () {
      final birth = DateTime(1990, 3, 10); // 6일 후
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.nextBirthday, DateTime(2026, 3, 10));
      expect(result.isBirthdayToday, false);
      expect(result.nextBirthday.difference(fixedToday).inDays, 6);
    });

    test('이미 지난 생일 — 내년 생일 날짜 반환', () {
      final birth = DateTime(1990, 1, 1);
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.nextBirthday, DateTime(2027, 1, 1));
      expect(result.isBirthdayToday, false);
    });

    test('오늘이 생일 — 오늘 날짜, isBirthdayToday = true', () {
      final birth = DateTime(2000, 3, 4);
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.nextBirthday, fixedToday);
      expect(result.isBirthdayToday, true);
    });
  });

  group('태어난 요일 (birthWeekday)', () {
    test('2000-01-01 — 토요일(6)', () {
      final birth = DateTime(2000, 1, 1);
      final result = useCase.execute(birthDate: birth, today: fixedToday);
      expect(result.birthWeekday, DateTime.saturday); // 6
    });
  });
}
