import 'package:calcmate/domain/models/dutch_pay_state.dart';
import 'package:calcmate/domain/usecases/dutch_pay_individual_split_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late IndividualSplitUseCase useCase;

  const a = DutchParticipant(name: 'A');
  const b = DutchParticipant(name: 'B');
  const c = DutchParticipant(name: 'C');

  setUp(() {
    useCase = IndividualSplitUseCase();
  });

  // ── 기본 케이스 ─────────────────────────────────────────

  group('기본 계산', () {
    test('각자 다른 메뉴 — 담당자 1명씩', () {
      final r = useCase.execute(
        participants: [a, b, c],
        items: [
          const DutchItem(name: '삼겹살', amount: 20000, assignees: [0]),
          const DutchItem(name: '냉면', amount: 12000, assignees: [1]),
          const DutchItem(name: '소주', amount: 8000, assignees: [2]),
        ],
      );
      expect(r.totalAmount, 40000);
      expect(r.personAmounts[0], 20000);
      expect(r.personAmounts[1], 12000);
      expect(r.personAmounts[2], 8000);
    });

    test('하나의 항목을 모두 나눔 — 균등 분배', () {
      final r = useCase.execute(
        participants: [a, b, c],
        items: [
          const DutchItem(name: '삼겹살', amount: 30000, assignees: [0, 1, 2]),
        ],
      );
      expect(r.totalAmount, 30000);
      expect(r.personAmounts[0], 10000);
      expect(r.personAmounts[1], 10000);
      expect(r.personAmounts[2], 10000);
    });

    test('나머지 발생 — 첫 번째 담당자에게 귀속', () {
      // 10001원을 3명으로 나누면 3333, 3333, 3335 — 첫 번째가 rem 2 포함
      final r = useCase.execute(
        participants: [a, b, c],
        items: [
          const DutchItem(name: '테스트', amount: 10001, assignees: [0, 1, 2]),
        ],
      );
      expect(r.totalAmount, 10001);
      final base = 10001 ~/ 3; // 3333
      final rem = 10001 % 3;   // 2
      expect(r.personAmounts[0], base + rem); // 3335
      expect(r.personAmounts[1], base);        // 3333
      expect(r.personAmounts[2], base);        // 3333
    });
  });

  // ── 스펙 예시 ────────────────────────────────────────────

  group('스펙 예시 — 삼겹살/냉면/소주', () {
    test('삼겹살 36,000(A·B) + 냉면 12,000(C) + 소주 6,000(A·B·C)', () {
      final r = useCase.execute(
        participants: [a, b, c],
        items: [
          const DutchItem(name: '삼겹살', amount: 36000, assignees: [0, 1]),
          const DutchItem(name: '냉면', amount: 12000, assignees: [2]),
          const DutchItem(name: '소주', amount: 6000, assignees: [0, 1, 2]),
        ],
      );
      expect(r.totalAmount, 54000);
      // A: 삼겹살 18000 + 소주 2000 = 20000
      // B: 삼겹살 18000 + 소주 2000 = 20000
      // C: 냉면 12000 + 소주 2000 = 14000
      expect(r.personAmounts[0], 20000);
      expect(r.personAmounts[1], 20000);
      expect(r.personAmounts[2], 14000);
    });
  });

  // ── 엣지 케이스 ─────────────────────────────────────────

  group('엣지 케이스', () {
    test('항목 없음 — 모두 0', () {
      final r = useCase.execute(
        participants: [a, b],
        items: [],
      );
      expect(r.totalAmount, 0);
      expect(r.personAmounts[0], 0);
      expect(r.personAmounts[1], 0);
    });

    test('담당자가 없는 항목은 무시', () {
      final r = useCase.execute(
        participants: [a, b],
        items: [
          const DutchItem(name: '빈항목', amount: 5000, assignees: []),
          const DutchItem(name: '정상', amount: 10000, assignees: [0]),
        ],
      );
      expect(r.totalAmount, 15000); // 총액은 포함
      expect(r.personAmounts[0], 10000);
      expect(r.personAmounts[1], 0);
    });

    test('2명 — 홀수 금액 나머지 처리', () {
      final r = useCase.execute(
        participants: [a, b],
        items: [
          const DutchItem(name: '커피', amount: 9000, assignees: [0, 1]),
        ],
      );
      expect(r.totalAmount, 9000);
      expect(r.personAmounts[0], 4500); // 9000 ~/ 2 + rem(0) = 4500
      expect(r.personAmounts[1], 4500);
    });

    test('2명 — 홀수 금액 9,001원', () {
      final r = useCase.execute(
        participants: [a, b],
        items: [
          const DutchItem(name: '커피', amount: 9001, assignees: [0, 1]),
        ],
      );
      expect(r.totalAmount, 9001);
      expect(r.personAmounts[0], 4501); // rem 1 → A에게
      expect(r.personAmounts[1], 4500);
    });

    test('한 명이 여러 항목 담당', () {
      final r = useCase.execute(
        participants: [a, b],
        items: [
          const DutchItem(name: '메뉴1', amount: 10000, assignees: [0]),
          const DutchItem(name: '메뉴2', amount: 5000, assignees: [0]),
          const DutchItem(name: '메뉴3', amount: 8000, assignees: [1]),
        ],
      );
      expect(r.totalAmount, 23000);
      expect(r.personAmounts[0], 15000);
      expect(r.personAmounts[1], 8000);
    });
  });
}
