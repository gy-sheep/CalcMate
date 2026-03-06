import '../models/dutch_pay_state.dart';

/// 개별 계산 결과.
class IndividualSplitResult {
  final int totalAmount;

  /// participants 인덱스 순서대로 각 인원이 내야 할 금액.
  final List<int> personAmounts;

  const IndividualSplitResult({
    required this.totalAmount,
    required this.personAmounts,
  });
}

/// 개별 계산 UseCase.
///
/// 각 항목의 금액을 담당자에게 균등 배분한다.
/// 나머지(rem)는 assignees의 첫 번째 인원에게 귀속된다.
class IndividualSplitUseCase {
  IndividualSplitResult execute({
    required List<DutchParticipant> participants,
    required List<DutchItem> items,
  }) {
    final sums = List.filled(participants.length, 0);

    for (final item in items) {
      if (item.assignees.isEmpty) continue;
      final base = item.amount ~/ item.assignees.length;
      final rem = item.amount % item.assignees.length;
      for (int i = 0; i < item.assignees.length; i++) {
        final idx = item.assignees[i];
        if (idx < participants.length) {
          sums[idx] += base + (i == 0 ? rem : 0);
        }
      }
    }

    final total = items.fold(0, (s, item) => s + item.amount);

    return IndividualSplitResult(
      totalAmount: total,
      personAmounts: List.unmodifiable(sums),
    );
  }
}
