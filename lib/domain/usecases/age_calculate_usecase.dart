import '../../core/constants/lunar_new_year_dates.dart';

// ─────────────────────────────────────────
// Result model
// ─────────────────────────────────────────
class AgeResult {
  const AgeResult({
    required this.koreanAge,
    required this.countingAge,
    required this.yearAge,
    required this.zodiacIndex,
    required this.constellationIndex,
    required this.daysLived,
    required this.birthWeekday,
    required this.nextBirthday,
    required this.isBirthdayToday,
  });

  /// 만 나이
  final int koreanAge;

  /// 세는 나이 (올해 − 출생연도 + 1)
  final int countingAge;

  /// 연 나이 (올해 − 출생연도)
  final int yearAge;

  /// 띠 인덱스 (0=쥐 … 11=돼지), 설날 기준 보정 적용
  final int zodiacIndex;

  /// 별자리 인덱스 (0=염소 … 11=사수)
  final int constellationIndex;

  /// 출생일부터 오늘까지 경과 일수
  final int daysLived;

  /// 태어난 요일 (DateTime.monday=1 … DateTime.sunday=7)
  final int birthWeekday;

  /// 다음(또는 오늘) 생일의 양력 날짜
  final DateTime nextBirthday;

  /// 오늘이 생일이면 true
  final bool isBirthdayToday;
}

// ─────────────────────────────────────────
// UseCase
// ─────────────────────────────────────────
class AgeCalculateUseCase {
  AgeResult execute({
    required DateTime birthDate,
    required DateTime today,
  }) {
    final birth = DateTime(birthDate.year, birthDate.month, birthDate.day);
    final now   = DateTime(today.year, today.month, today.day);

    // 만 나이
    int koreanAge = now.year - birth.year;
    final hadBirthday = (now.month > birth.month) ||
        (now.month == birth.month && now.day >= birth.day);
    if (!hadBirthday) koreanAge--;
    if (koreanAge < 0) koreanAge = 0;

    // 세는 나이 / 연 나이
    final countingAge = now.year - birth.year + 1;
    final yearAge     = now.year - birth.year;

    // 띠 (설날 기준 보정)
    final zodiacIndex = _zodiac(birth);

    // 별자리
    final constellationIndex = _constellation(birth.month, birth.day);

    // 살아온 날
    final daysLived = now.difference(birth).inDays;

    // 태어난 요일
    final birthWeekday = birth.weekday;

    // 다음 생일
    final (nextBirthday, isBirthdayToday) = _nextBirthday(birth, now);

    return AgeResult(
      koreanAge: koreanAge,
      countingAge: countingAge,
      yearAge: yearAge,
      zodiacIndex: zodiacIndex,
      constellationIndex: constellationIndex,
      daysLived: daysLived,
      birthWeekday: birthWeekday,
      nextBirthday: nextBirthday,
      isBirthdayToday: isBirthdayToday,
    );
  }

  // ── 띠 계산 ──────────────────────────────
  int _zodiac(DateTime birth) {
    int zodiacYear = birth.year;
    // 출생일이 해당 연도 설날 이전이면 → 전년도 띠
    final newYear = lunarNewYearDate(birth.year);
    if (newYear != null &&
        birth.isBefore(DateTime(newYear.year, newYear.month, newYear.day))) {
      zodiacYear--;
    }
    // 1900 = 쥐띠(0)
    return ((zodiacYear - 1900) % 12 + 12) % 12;
  }

  // ── 별자리 계산 ──────────────────────────
  int _constellation(int month, int day) {
    final mmdd = month * 100 + day;
    if (mmdd >= 1222 || mmdd <= 119) return 0;  // 염소자리
    if (mmdd <= 218) return 1;                   // 물병자리
    if (mmdd <= 320) return 2;                   // 물고기자리
    if (mmdd <= 419) return 3;                   // 양자리
    if (mmdd <= 520) return 4;                   // 황소자리
    if (mmdd <= 621) return 5;                   // 쌍둥이자리
    if (mmdd <= 722) return 6;                   // 게자리
    if (mmdd <= 822) return 7;                   // 사자자리
    if (mmdd <= 922) return 8;                   // 처녀자리
    if (mmdd <= 1023) return 9;                  // 천칭자리
    if (mmdd <= 1122) return 10;                 // 전갈자리
    return 11;                                   // 사수자리
  }

  // ── 다음 생일 ────────────────────────────
  (DateTime, bool) _nextBirthday(DateTime birth, DateTime now) {
    DateTime birthdayInYear(int year) {
      try {
        return DateTime(year, birth.month, birth.day);
      } catch (_) {
        // 윤년 2월 29일 → 비윤년에는 3월 1일
        return DateTime(year, 3, 1);
      }
    }

    final thisYear = birthdayInYear(now.year);
    if (thisYear == now) return (thisYear, true);
    if (thisYear.isAfter(now)) return (thisYear, false);
    return (birthdayInYear(now.year + 1), false);
  }
}

// ─────────────────────────────────────────
// 정적 데이터
// ─────────────────────────────────────────

/// 띠 (이름, 이모지) — 인덱스 0=쥐 … 11=돼지
const List<(String, String)> kZodiacs = [
  ('쥐', '🐭'), ('소', '🐮'), ('호랑이', '🐯'), ('토끼', '🐰'),
  ('용', '🐲'), ('뱀', '🐍'), ('말', '🐴'), ('양', '🐑'),
  ('원숭이', '🐵'), ('닭', '🐔'), ('개', '🐶'), ('돼지', '🐷'),
];

/// 별자리 (이름, 기호) — 인덱스 0=염소 … 11=사수
const List<(String, String)> kConstellations = [
  ('염소자리', '♑'), ('물병자리', '♒'), ('물고기자리', '♓'), ('양자리', '♈'),
  ('황소자리', '♉'), ('쌍둥이자리', '♊'), ('게자리', '♋'),  ('사자자리', '♌'),
  ('처녀자리', '♍'), ('천칭자리', '♎'), ('전갈자리', '♏'),  ('사수자리', '♐'),
];

/// 요일 이름 (weekday 1=월 … 7=일)
const List<String> kWeekdays = [
  '', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일',
];
