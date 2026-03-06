import 'package:calcmate/domain/models/dutch_pay_state.dart';
import 'package:calcmate/domain/usecases/dutch_pay_equal_split_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EqualSplitUseCase useCase;

  setUp(() {
    useCase = EqualSplitUseCase();
  });

  // ── KR 모드 (나머지 처리) ────────────────────────────────

  group('KR — 100원 단위', () {
    test('나눠떨어지는 경우 — isEven true', () {
      final r = useCase.execute(
        total: 40000,
        people: 4,
        remUnit: RemUnit.hundred,
        tipRate: 0,
        isKorea: true,
      );
      expect(r.rounded, 10000);
      expect(r.organizer, 10000);
      expect(r.isEven, true);
    });

    test('38,300원 ÷ 5명 — 나머지 4명 7,600원, 계산한 사람 7,900원', () {
      // floor(38300/5/100)*100 = floor(76.6)*100 = 7600
      // organizer = 38300 - 7600*4 = 7900
      final r = useCase.execute(
        total: 38300,
        people: 5,
        remUnit: RemUnit.hundred,
        tipRate: 0,
        isKorea: true,
      );
      expect(r.rounded, 7600);
      expect(r.organizer, 7900);
      expect(r.isEven, false);
    });

    test('87,000원 ÷ 4명 — 나머지 3명 21,700원, 계산한 사람 21,900원', () {
      final r = useCase.execute(
        total: 87000,
        people: 4,
        remUnit: RemUnit.hundred,
        tipRate: 0,
        isKorea: true,
      );
      expect(r.rounded, 21700);
      expect(r.organizer, 87000 - 21700 * 3); // 21900
      expect(r.isEven, false);
    });

    test('총액 0 — rounded·organizer 모두 0', () {
      final r = useCase.execute(
        total: 0,
        people: 3,
        remUnit: RemUnit.hundred,
        tipRate: 0,
        isKorea: true,
      );
      expect(r.rounded, 0);
      expect(r.organizer, 0);
      expect(r.isEven, true);
    });
  });

  group('KR — 1,000원 단위', () {
    test('38,300원 ÷ 5명 — 나머지 4명 7,000원, 계산한 사람 10,300원', () {
      final r = useCase.execute(
        total: 38300,
        people: 5,
        remUnit: RemUnit.thousand,
        tipRate: 0,
        isKorea: true,
      );
      expect(r.rounded, 7000);
      expect(r.organizer, 38300 - 7000 * 4); // 10300
      expect(r.isEven, false);
    });

    test('30,000원 ÷ 3명 — isEven true', () {
      final r = useCase.execute(
        total: 30000,
        people: 3,
        remUnit: RemUnit.thousand,
        tipRate: 0,
        isKorea: true,
      );
      expect(r.rounded, 10000);
      expect(r.organizer, 10000);
      expect(r.isEven, true);
    });
  });

  group('KR — 2명 엣지', () {
    test('2명 — 계산한 사람이 1명이므로 organizer = total - rounded', () {
      final r = useCase.execute(
        total: 15500,
        people: 2,
        remUnit: RemUnit.hundred,
        tipRate: 0,
        isKorea: true,
      );
      expect(r.rounded, 7700); // floor(15500/2/100)*100
      expect(r.organizer, 15500 - 7700); // 7800
      expect(r.isEven, false);
    });
  });

  // ── Non-KR 모드 (팁 추가) ───────────────────────────────

  group('Non-KR — 팁 없음', () {
    test('팁 0% — 1인당 = total / people', () {
      final r = useCase.execute(
        total: 10000,
        people: 4,
        remUnit: RemUnit.hundred,
        tipRate: 0,
        isKorea: false,
      );
      expect(r.perPersonWithTip, 2500.0);
      expect(r.totalWithTip, 10000.0);
    });
  });

  group('Non-KR — 팁 포함', () {
    test('팁 10% — 1인당 (total * 1.1) / people', () {
      final r = useCase.execute(
        total: 10000,
        people: 4,
        remUnit: RemUnit.hundred,
        tipRate: 10,
        isKorea: false,
      );
      expect(r.totalWithTip, 11000.0);
      expect(r.perPersonWithTip, 2750.0);
    });

    test('팁 15% — 100달러, 4명', () {
      final r = useCase.execute(
        total: 10000,
        people: 4,
        remUnit: RemUnit.hundred,
        tipRate: 15,
        isKorea: false,
      );
      expect(r.totalWithTip, closeTo(11500.0, 0.01));
      expect(r.perPersonWithTip, closeTo(2875.0, 0.01));
    });

    test('팁 20%', () {
      final r = useCase.execute(
        total: 10000,
        people: 4,
        remUnit: RemUnit.hundred,
        tipRate: 20,
        isKorea: false,
      );
      expect(r.totalWithTip, 12000.0);
      expect(r.perPersonWithTip, 3000.0);
    });

    test('팁 직접입력 18%', () {
      final r = useCase.execute(
        total: 10000,
        people: 5,
        remUnit: RemUnit.hundred,
        tipRate: 18,
        isKorea: false,
      );
      expect(r.totalWithTip, 11800.0);
      expect(r.perPersonWithTip, 2360.0);
    });
  });
}
