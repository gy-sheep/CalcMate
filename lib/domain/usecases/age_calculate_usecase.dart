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

/// 띠 이모지 — 인덱스 0=쥐 … 11=돼지
const List<String> kZodiacEmojis = [
  '🐭', '🐮', '🐯', '🐰', '🐲', '🐍',
  '🐴', '🐑', '🐵', '🐔', '🐶', '🐷',
];

/// 띠 아이콘 경로 — kZodiacs와 동일 인덱스
const List<String> kZodiacIcons = [
  'assets/icons/zodiac/zodiac_rat.png',
  'assets/icons/zodiac/zodiac_ox.png',
  'assets/icons/zodiac/zodiac_tiger.png',
  'assets/icons/zodiac/zodiac_rabbit.png',
  'assets/icons/zodiac/zodiac_dragon.png',
  'assets/icons/zodiac/zodiac_snake.png',
  'assets/icons/zodiac/zodiac_horse.png',
  'assets/icons/zodiac/zodiac_goat.png',
  'assets/icons/zodiac/zodiac_monkey.png',
  'assets/icons/zodiac/zodiac_rooster.png',
  'assets/icons/zodiac/zodiac_dog.png',
  'assets/icons/zodiac/zodiac_pig.png',
];

/// 별자리 기호 — 인덱스 0=염소 … 11=사수
const List<String> kConstellationSymbols = [
  '♑', '♒', '♓', '♈', '♉', '♊',
  '♋', '♌', '♍', '♎', '♏', '♐',
];

/// 별자리 아이콘 경로 — kConstellations와 동일 인덱스
const List<String> kConstellationIcons = [
  'assets/icons/constellation/constellation_capricorn.png',
  'assets/icons/constellation/constellation_aquarius.png',
  'assets/icons/constellation/constellation_pisces.png',
  'assets/icons/constellation/constellation_aries.png',
  'assets/icons/constellation/constellation_taurus.png',
  'assets/icons/constellation/constellation_gemini.png',
  'assets/icons/constellation/constellation_cancer.png',
  'assets/icons/constellation/constellation_leo.png',
  'assets/icons/constellation/constellation_virgo.png',
  'assets/icons/constellation/constellation_libra.png',
  'assets/icons/constellation/constellation_scorpio.png',
  'assets/icons/constellation/constellation_sagittarius.png',
];

