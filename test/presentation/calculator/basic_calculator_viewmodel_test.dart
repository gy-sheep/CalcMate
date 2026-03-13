import 'package:calcmate/domain/models/calculator_state.dart';
import 'package:calcmate/presentation/calculator/basic_calculator_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  late BasicCalculatorViewModel vm;

  setUp(() {
    container = ProviderContainer();
    vm = container.read(basicCalculatorViewModelProvider.notifier);
  });

  tearDown(() => container.dispose());

  CalculatorState readState() =>
      container.read(basicCalculatorViewModelProvider);

  void press(String label) {
    switch (label) {
      case '0' || '1' || '2' || '3' || '4' || '5' || '6' || '7' || '8' || '9':
        vm.handleIntent(CalculatorIntent.numberPressed(label));
      case '+' || '-' || '×' || '÷':
        vm.handleIntent(CalculatorIntent.operatorPressed(label));
      case '=':
        vm.handleIntent(const CalculatorIntent.equalsPressed());
      case 'AC':
        vm.handleIntent(const CalculatorIntent.clearPressed());
      case '⌫':
        vm.handleIntent(const CalculatorIntent.backspacePressed());
      case '.':
        vm.handleIntent(const CalculatorIntent.decimalPressed());
      case '%':
        vm.handleIntent(const CalculatorIntent.percentPressed());
      case '()':
        vm.handleIntent(const CalculatorIntent.parenthesesPressed());
    }
  }

  void pressAll(String keys) {
    for (final key in keys.split(' ')) {
      press(key);
    }
  }

  // ── 클리어 ──

  group('클리어 (AC)', () {
    test('항상 전체 초기화', () {
      pressAll('5 + 3');
      press('AC');
      expect(readState().input, '0');
      expect(readState().isResult, false);
    });

    test('결과 상태에서도 전체 초기화', () {
      pressAll('5 + 3 =');
      press('AC');
      expect(readState().input, '0');
      expect(readState().isResult, false);
    });
  });

  // ── 숫자 입력 ──

  group('숫자 입력', () {
    test('초기 상태에서 숫자', () {
      press('5');
      expect(readState().input, '5');
    });

    test('초기 0에서 숫자 대체', () {
      press('3');
      expect(readState().input, '3');
    });

    test('결과 후 숫자 → 새 수식', () {
      pressAll('5 + 3 =');
      press('2');
      expect(readState().input, '2');
      expect(readState().isResult, false);
    });

    test(') 뒤 숫자 → 암묵적 × 삽입', () {
      pressAll('() 5 + 3 () 5'); // ( 5 + 3 ) × 5
      expect(readState().input, '(5+3)×5');
    });
  });

  // ── 연산자 입력 ──

  group('연산자 입력', () {
    test('기본 연산자 추가', () {
      pressAll('5 +');
      expect(readState().input, '5+');
    });

    test('초기 0에서 - → 음수 모드', () {
      press('-');
      expect(readState().input, '-');
    });

    test('초기 0에서 + × ÷ → 무시', () {
      press('+');
      expect(readState().input, '0');
      press('×');
      expect(readState().input, '0');
      press('÷');
      expect(readState().input, '0');
    });

    test('연산자 뒤 - → 연산자 교체', () {
      pressAll('5 × -');
      expect(readState().input, '5-');
    });

    test('연산자 교체 (다른 연산자)', () {
      pressAll('5 + ×');
      expect(readState().input, '5×');
    });

    test('같은 연산자 다시 → 무시', () {
      pressAll('5 +');
      press('+');
      expect(readState().input, '5+');
    });

    test('음수 대기에서 다른 연산자 → 취소+교체', () {
      pressAll('5 × - +');
      expect(readState().input, '5+');
    });

    test('( 뒤 - → 음수 입력', () {
      pressAll('() -');
      expect(readState().input, '(-');
    });

    test('( 뒤 + × ÷ → 무시', () {
      press('()');
      press('+');
      expect(readState().input, '(');
      press('×');
      expect(readState().input, '(');
    });

    test('결과 상태에서 연산자 → 이어서 수식', () {
      pressAll('5 + 3 =');
      press('+');
      expect(readState().input, '8+');
      expect(readState().isResult, false);
    });

    test('소수점으로 끝나는 상태에서 연산자', () {
      pressAll('5 . +');
      expect(readState().input, '5.+');
    });
  });

  // ── 소수점 ──

  group('소수점', () {
    test('기본 소수점', () {
      pressAll('5 .');
      expect(readState().input, '5.');
    });

    test('중복 소수점 방지', () {
      pressAll('5 . .');
      expect(readState().input, '5.');
    });

    test('연산자 뒤 → 0.', () {
      pressAll('5 + .');
      expect(readState().input, '5+0.');
    });

    test('( 뒤 → 0.', () {
      pressAll('() .');
      expect(readState().input, '(0.');
    });

    test('음수 대기에서 → -0.', () {
      pressAll('5 × - .');
      expect(readState().input, '5-0.');
    });

    test(') 뒤 → ×0.', () {
      pressAll('() 5 + 3 () .');
      expect(readState().input, '(5+3)×0.');
    });

    test('% 뒤 → ×0.', () {
      pressAll('5 0 % .');
      expect(readState().input, '50%×0.');
    });

    test('결과에서 소수점 → 0.', () {
      pressAll('5 + 3 =');
      press('.');
      expect(readState().input, '0.');
      expect(readState().isResult, false);
    });
  });

  // ── 괄호 ──

  group('괄호', () {
    test('초기 상태 → (', () {
      press('()');
      expect(readState().input, '(');
    });

    test('( 뒤 → (( (중첩)', () {
      pressAll('() ()');
      expect(readState().input, '((');
    });

    test('숫자 뒤 + 미닫힌 괄호 → )', () {
      pressAll('() 5 + 3 ()');
      expect(readState().input, '(5+3)');
    });

    test('연산자 뒤 → (', () {
      pressAll('() 5 + ()');
      expect(readState().input, '(5+(');
    });

    test('숫자 뒤 + 미닫힌 없음 → ×(', () {
      pressAll('5 ()');
      expect(readState().input, '5×(');
    });

    test(') 뒤 → ×(', () {
      pressAll('() 3 + 2 () ()');
      expect(readState().input, '(3+2)×(');
    });

    test('결과 상태에서 → 결과×(', () {
      pressAll('5 + 3 =');
      press('()');
      expect(readState().input, '8×(');
      expect(readState().isResult, false);
    });

    test('연산자 뒤에서 ) 불가', () {
      pressAll('() 5 + ()');
      // (5+( 인 상태 — 연산자 뒤이므로 ( 추가
      expect(readState().input, '(5+(');
    });
  });

  // ── 퍼센트 ──

  group('퍼센트', () {
    test('숫자 뒤 %', () {
      pressAll('5 0 %');
      expect(readState().input, '50%');
    });

    test('( 뒤 % → 무시', () {
      pressAll('() %');
      expect(readState().input, '(');
    });

    test(') 뒤 % 허용', () {
      pressAll('() 3 + 2 () %');
      expect(readState().input, '(3+2)%');
    });

    test('연산자 뒤 % → 연산자를 %로 교체', () {
      pressAll('5 + %');
      expect(readState().input, '5%');
    });

    test('% 중복 → 괄호 감싸기', () {
      pressAll('5 % %');
      expect(readState().input, '(5%)%');
    });

    test('% 중복 — 수식 중간: 5×9% → 5×(9%)%', () {
      pressAll('5 × 9 % %');
      expect(readState().input, '5×(9%)%');
    });

    test('% 중복 — 삼중: 5% → (5%)% → ((5%)%)%', () {
      pressAll('5 % % %');
      expect(readState().input, '((5%)%)%');
    });

    test('결과에서 % → 결과에 % 붙이기', () {
      pressAll('5 + 3 =');
      press('%');
      expect(readState().input, '8%');
      expect(readState().expression, '');
    });

    test('음수 대기에서 % → 무시', () {
      pressAll('() - %');
      expect(readState().input, '(-');
    });
  });

  // ── 백스페이스 ──

  group('백스페이스', () {
    test('한 글자 지우기', () {
      pressAll('5 3');
      press('⌫');
      expect(readState().input, '5');
    });

    test('한 자리이면 0', () {
      press('5');
      press('⌫');
      expect(readState().input, '0');
    });

    test('결과 상태에서 → 전체 초기화', () {
      pressAll('5 + 3 =');
      press('⌫');
      expect(readState().input, '0');
      expect(readState().isResult, false);
    });
  });

  // ── = ──

  group('계산 (=)', () {
    test('기본 계산', () {
      pressAll('5 + 3 =');
      expect(readState().input, '8');
      expect(readState().isResult, true);
    });

    test('숫자만 → 무시', () {
      pressAll('5 =');
      expect(readState().input, '5');
      expect(readState().isResult, false);
    });

    test('연산자로 끝 → 무시', () {
      pressAll('5 + =');
      expect(readState().input, '5+');
      expect(readState().isResult, false);
    });

    test('음수 대기 상태 → 무시', () {
      pressAll('() - =');
      expect(readState().input, '(-');
      expect(readState().isResult, false);
    });

    test('미닫힌 괄호 자동 닫기', () {
      pressAll('() 5 + 3 =');
      expect(readState().input, '8');
      expect(readState().isResult, true);
    });

    test('반복 =', () {
      pressAll('5 + 3 =');
      expect(readState().input, '8');
      press('=');
      expect(readState().input, '11');
      press('=');
      expect(readState().input, '14');
    });

    test('괄호 수식 계산', () {
      pressAll('() 2 + 3 () × 4 =');
      expect(readState().input, '20');
      expect(readState().isResult, true);
    });
  });
}
