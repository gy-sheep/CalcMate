import 'package:calcmate/domain/models/vat_calculator_state.dart';
import 'package:calcmate/domain/usecases/vat_calculate_usecase.dart';
import 'package:calcmate/domain/utils/number_formatter.dart';
import 'package:calcmate/presentation/vat_calculator/vat_calculator_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  late VatCalculatorViewModel vm;

  setUp(() {
    container = ProviderContainer();
    vm = container.read(vatCalculatorViewModelProvider.notifier);
  });

  tearDown(() => container.dispose());

  VatCalculatorState readState() =>
      container.read(vatCalculatorViewModelProvider);

  void key(String k) {
    vm.handleIntent(VatCalculatorIntent.keyTapped(k));
  }

  void keys(String input) {
    for (final k in input.split(' ')) {
      key(k);
    }
  }

  // ── 초기 상태 ──

  group('초기 상태', () {
    test('기본값', () {
      final s = readState();
      expect(s.input, '0');
      expect(s.mode, VatMode.exclusive);
      expect(s.inputTarget, InputTarget.amount);
      expect(s.taxRate, 10);
      expect(s.isResult, false);
      expect(s.taxRateInput, '');
      expect(s.toastMessage, isNull);
    });
  });

  // ── 숫자 입력 ──

  group('숫자 입력', () {
    test('단일 숫자 입력', () {
      key('5');
      expect(readState().input, '5');
    });

    test('연속 숫자 입력', () {
      keys('1 2 3');
      expect(readState().input, '123');
    });

    test('선행 0 교체', () {
      key('0');
      key('5');
      expect(readState().input, '5');
    });

    test('0 반복 입력 무시', () {
      key('0');
      key('0');
      expect(readState().input, '0');
    });

    test('00 키', () {
      keys('1 2 3 00');
      expect(readState().input, '12300');
    });

    test('00 키 — 입력이 0이면 무시', () {
      key('00');
      expect(readState().input, '0');
    });
  });

  // ── 연산자 ──

  group('연산자', () {
    test('연산자 입력', () {
      keys('5 +');
      expect(readState().input, '5+');
    });

    test('연산자 교체', () {
      keys('5 + -');
      expect(readState().input, '5-');
    });

    test('결과 후 연산자 이어서 입력', () {
      keys('5 + 3 =');
      key('+');
      expect(readState().input, '8+');
      expect(readState().isResult, false);
    });
  });

  // ── 등호 ──

  group('등호', () {
    test('수식 평가', () {
      keys('1 0 0 + 2 0 0 =');
      expect(readState().input, '300');
      expect(readState().isResult, true);
    });

    test('연산자로 끝나는 수식 — = 무시', () {
      keys('5 + 3 +');
      key('=');
      expect(readState().input, '5+3+');
      expect(readState().isResult, false);
    });

    test('오류 — 0 ÷ 0', () {
      keys('0 ÷ 0 =');
      expect(readState().input, '오류');
      expect(readState().isResult, true);
    });
  });

  // ── 클리어 ──

  group('클리어 (AC)', () {
    test('전체 초기화', () {
      keys('5 + 3');
      key('AC');
      expect(readState().input, '0');
      expect(readState().isResult, false);
    });
  });

  // ── 백스페이스 ──

  group('백스페이스', () {
    test('마지막 문자 제거', () {
      keys('1 2 3');
      key('\u{232B}');
      expect(readState().input, '12');
    });

    test('한 자리 → 0', () {
      key('5');
      key('\u{232B}');
      expect(readState().input, '0');
    });

    test('결과 상태에서 무시', () {
      keys('5 + 3 =');
      key('\u{232B}');
      expect(readState().input, '8');
      expect(readState().isResult, true);
    });
  });

  // ── 소수점 ──

  group('소수점', () {
    test('소수점 추가', () {
      keys('5 .');
      expect(readState().input, '5.');
    });

    test('중복 소수점 무시', () {
      keys('5 . 3 .');
      expect(readState().input, '5.3');
    });

    test('결과 후 소수점 → 0.', () {
      keys('5 + 3 =');
      key('.');
      expect(readState().input, '0.');
      expect(readState().isResult, false);
    });
  });

  // ── 퍼센트 ──

  group('퍼센트', () {
    test('기본 퍼센트 적용', () {
      keys('5 0 %');
      expect(readState().input, '0.5');
    });

    test('결과 상태에서 무시', () {
      keys('5 + 3 =');
      key('%');
      expect(readState().input, '8');
    });
  });

  // ── 모드 전환 ──

  group('모드 전환', () {
    test('inclusive로 전환', () {
      vm.handleIntent(
          const VatCalculatorIntent.modeChanged(VatMode.inclusive));
      expect(readState().mode, VatMode.inclusive);
    });

    test('모드 전환 시 입력값 유지', () {
      keys('1 0 0 0');
      vm.handleIntent(
          const VatCalculatorIntent.modeChanged(VatMode.inclusive));
      expect(readState().input, '1000');
    });

    test('세율 편집 중 모드 전환 → 세율 적용 후 amount로 복귀', () {
      vm.handleIntent(const VatCalculatorIntent.taxRateTapped());
      keys('2 0');
      vm.handleIntent(
          const VatCalculatorIntent.modeChanged(VatMode.inclusive));
      expect(readState().taxRate, 20);
      expect(readState().inputTarget, InputTarget.amount);
    });
  });

  // ── 세율 편집 ──

  group('세율 편집', () {
    test('세율 편집 모드 진입', () {
      vm.handleIntent(const VatCalculatorIntent.taxRateTapped());
      expect(readState().inputTarget, InputTarget.taxRate);
      expect(readState().taxRateInput, '');
    });

    test('세율 숫자 입력', () {
      vm.handleIntent(const VatCalculatorIntent.taxRateTapped());
      keys('2 2');
      expect(readState().taxRateInput, '22');
    });

    test('세율 99% 초과 → 토스트', () {
      vm.handleIntent(const VatCalculatorIntent.taxRateTapped());
      keys('9 9');
      key('9'); // 999 > 99
      expect(readState().taxRateInput, '99');
      expect(readState().toastMessage, isNotNull);
    });

    test('= 키로 세율 적용 후 amount 모드 복귀', () {
      vm.handleIntent(const VatCalculatorIntent.taxRateTapped());
      keys('1 5');
      key('=');
      expect(readState().taxRate, 15);
      expect(readState().inputTarget, InputTarget.amount);
      expect(readState().taxRateInput, '');
    });

    test('세율 AC → 입력 초기화', () {
      vm.handleIntent(const VatCalculatorIntent.taxRateTapped());
      keys('2 0');
      key('AC');
      expect(readState().taxRateInput, '');
    });

    test('세율 백스페이스', () {
      vm.handleIntent(const VatCalculatorIntent.taxRateTapped());
      keys('2 5');
      key('\u{232B}');
      expect(readState().taxRateInput, '2');
    });

    test('세율 탭 토글 — 두 번째 탭으로 종료', () {
      vm.handleIntent(const VatCalculatorIntent.taxRateTapped());
      keys('2 0');
      vm.handleIntent(const VatCalculatorIntent.taxRateTapped());
      expect(readState().taxRate, 20);
      expect(readState().inputTarget, InputTarget.amount);
    });
  });

  // ── 계산 결과 (evaluatedInput / vatResult) ──

  group('계산 결과', () {
    test('부가세 별도 — 기본', () {
      keys('1 0 0 0 0 0 0');
      final result = vm.vatResult;
      expect(result.supplyAmount, 1000000);
      expect(result.vatAmount, 100000);
      expect(result.totalAmount, 1100000);
    });

    test('부가세 포함 — 역산', () {
      vm.handleIntent(
          const VatCalculatorIntent.modeChanged(VatMode.inclusive));
      keys('1 1 0 0 0 0 0');
      final result = vm.vatResult;
      expect(result.supplyAmount, 1000000);
      expect(result.vatAmount, 100000);
      expect(result.totalAmount, 1100000);
    });

    test('연산자로 끝나는 수식 — 연산자 무시하고 계산', () {
      keys('1 0 0 +');
      final result = vm.vatResult;
      expect(result.supplyAmount, 100);
      expect(result.vatAmount, 10);
    });
  });

  // ── 포맷팅 ──

  group('포맷팅', () {
    test('천 단위 콤마', () {
      keys('1 0 0 0 0 0 0');
      expect(vm.formattedInput, '1,000,000');
    });

    test('수식 포맷팅', () {
      keys('1 0 0 + 2 0 0');
      expect(vm.formattedInput, contains('+'));
    });

    test('formatVatResult — 0', () {
      expect(NumberFormatter.formatVatResult(0), '0');
    });

    test('formatVatResult — 1000 이상 천 단위 콤마', () {
      expect(NumberFormatter.formatVatResult(1100000), '1,100,000');
    });

    test('formatVatResult — NaN → 0', () {
      expect(NumberFormatter.formatVatResult(double.nan), '0');
    });
  });

  // ── 자릿수 제한 ──

  group('자릿수 제한', () {
    test('정수 12자리 초과 → 토스트', () {
      keys('1 2 3 4 5 6 7 8 9 0 1 2');
      key('3'); // 13번째 자리
      expect(readState().toastMessage, isNotNull);
      expect(readState().input, '123456789012');
    });
  });

  // ── 토스트 ──

  group('토스트', () {
    test('clearToast', () {
      keys('1 2 3 4 5 6 7 8 9 0 1 2');
      key('3');
      expect(readState().toastMessage, isNotNull);
      vm.clearToast();
      expect(readState().toastMessage, isNull);
    });
  });
}
