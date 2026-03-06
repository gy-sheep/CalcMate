import '../models/dutch_pay_state.dart';

/// 균등 분배 계산 결과.
class EqualSplitResult {
  /// 총 금액 (팁 미포함)
  final int total;

  /// 인원 수
  final int people;

  /// 팁 포함 총 금액 (KR에서는 total과 동일)
  final double totalWithTip;

  /// 나머지 인원이 내는 금액 (단위 내림, KR 전용)
  final int rounded;

  /// 계산한 사람이 내는 금액 (KR 전용)
  final int organizer;

  /// 모두 동일 금액인지 (나눠떨어짐)
  final bool isEven;

  /// 1인당 금액 (Non-KR: 팁 포함 후 균등 분배)
  final double perPersonWithTip;

  const EqualSplitResult({
    required this.total,
    required this.people,
    required this.totalWithTip,
    required this.rounded,
    required this.organizer,
    required this.isEven,
    required this.perPersonWithTip,
  });
}

/// 균등 분배 계산 UseCase.
class EqualSplitUseCase {
  EqualSplitResult execute({
    required int total,
    required int people,
    required RemUnit remUnit,
    required double tipRate,
    required bool isKorea,
  }) {
    assert(people >= 2);

    if (isKorea) {
      // KR: 단위 내림 후 계산한 사람이 나머지 부담
      final rounded =
          (total / people / remUnit.value).floor() * remUnit.value;
      final organizer = total - rounded * (people - 1);
      return EqualSplitResult(
        total: total,
        people: people,
        totalWithTip: total.toDouble(),
        rounded: rounded,
        organizer: organizer,
        isEven: rounded == organizer,
        perPersonWithTip: total / people,
      );
    } else {
      // Non-KR: 팁 포함 후 균등 분배
      final totalWithTip = total * (1 + tipRate / 100);
      final perPerson = totalWithTip / people;
      return EqualSplitResult(
        total: total,
        people: people,
        totalWithTip: totalWithTip,
        rounded: 0,
        organizer: 0,
        isEven: true,
        perPersonWithTip: perPerson,
      );
    }
  }
}
