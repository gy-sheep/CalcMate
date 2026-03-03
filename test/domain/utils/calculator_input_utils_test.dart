import 'package:calcmate/domain/utils/calculator_input_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('endsWithOperator', () {
    test('연산자로 끝나면 true', () {
      expect(CalculatorInputUtils.endsWithOperator('5+'), isTrue);
      expect(CalculatorInputUtils.endsWithOperator('5-'), isTrue);
      expect(CalculatorInputUtils.endsWithOperator('5×'), isTrue);
      expect(CalculatorInputUtils.endsWithOperator('5÷'), isTrue);
    });

    test('숫자로 끝나면 false', () {
      expect(CalculatorInputUtils.endsWithOperator('5'), isFalse);
      expect(CalculatorInputUtils.endsWithOperator('5+3'), isFalse);
    });

    test('빈 문자열이면 false', () {
      expect(CalculatorInputUtils.endsWithOperator(''), isFalse);
    });
  });

  group('lastNumberSegment', () {
    test('단순 숫자', () {
      expect(CalculatorInputUtils.lastNumberSegment('123'), '123');
    });

    test('수식에서 마지막 숫자', () {
      expect(CalculatorInputUtils.lastNumberSegment('5+3'), '3');
    });

    test('음수 세그먼트', () {
      expect(CalculatorInputUtils.lastNumberSegment('5+-3'), '-3');
    });
  });

  group('unclosedParenCount', () {
    test('괄호 없으면 0', () {
      expect(CalculatorInputUtils.unclosedParenCount('5+3'), 0);
    });

    test('열린 괄호 1개', () {
      expect(CalculatorInputUtils.unclosedParenCount('(5+3'), 1);
    });

    test('닫힌 괄호 포함', () {
      expect(CalculatorInputUtils.unclosedParenCount('(5+3)'), 0);
    });

    test('중첩 괄호', () {
      expect(CalculatorInputUtils.unclosedParenCount('((5+3)'), 1);
    });

    test('모든 괄호 닫힘', () {
      expect(CalculatorInputUtils.unclosedParenCount('((5+3)*(2+1))'), 0);
    });

    test('여러 개 열림', () {
      expect(CalculatorInputUtils.unclosedParenCount('((5+(3'), 3);
    });
  });

  group('isNegativePending', () {
    test('단독 마이너스', () {
      expect(CalculatorInputUtils.isNegativePending('-'), isTrue);
    });

    test('연산자 뒤 마이너스', () {
      expect(CalculatorInputUtils.isNegativePending('5×-'), isTrue);
      expect(CalculatorInputUtils.isNegativePending('5+-'), isTrue);
    });

    test('( 뒤 마이너스', () {
      expect(CalculatorInputUtils.isNegativePending('(-'), isTrue);
    });

    test('일반 상태', () {
      expect(CalculatorInputUtils.isNegativePending('5'), isFalse);
      expect(CalculatorInputUtils.isNegativePending('5+3'), isFalse);
      expect(CalculatorInputUtils.isNegativePending('5+'), isFalse);
    });

    test('-0 상태', () {
      expect(CalculatorInputUtils.isNegativePending('-0'), isTrue);
    });

    test('연산자 뒤 -0 상태', () {
      expect(CalculatorInputUtils.isNegativePending('5×-0'), isTrue);
    });
  });

  group('hasOperator', () {
    test('연산자 있으면 true', () {
      expect(CalculatorInputUtils.hasOperator('5+3'), isTrue);
      expect(CalculatorInputUtils.hasOperator('5×3'), isTrue);
    });

    test('숫자만 있으면 false', () {
      expect(CalculatorInputUtils.hasOperator('123'), isFalse);
    });

    test('음수 부호만 있으면 false', () {
      expect(CalculatorInputUtils.hasOperator('-5'), isFalse);
    });

    test('괄호는 연산자로 취급', () {
      expect(CalculatorInputUtils.hasOperator('(5+3)'), isTrue);
    });

    test('% 는 연산자로 취급', () {
      expect(CalculatorInputUtils.hasOperator('5%'), isTrue);
    });
  });

  group('resolvePercent (리라이트)', () {
    test('단독 퍼센트: 50% → 0.5', () {
      expect(CalculatorInputUtils.resolvePercent('50%'), '0.5');
    });

    test('덧셈 퍼센트: 200+50% → 200+100.0', () {
      expect(CalculatorInputUtils.resolvePercent('200+50%'), '200+100.0');
    });

    test('뺄셈 퍼센트: 200-50% → 200-100.0', () {
      expect(CalculatorInputUtils.resolvePercent('200-50%'), '200-100.0');
    });

    test('곱셈 퍼센트: 200×50% → 200×0.5', () {
      expect(CalculatorInputUtils.resolvePercent('200×50%'), '200×0.5');
    });

    test('나눗셈 퍼센트: 200÷50% → 200÷0.5', () {
      expect(CalculatorInputUtils.resolvePercent('200÷50%'), '200÷0.5');
    });

    test('mod: 50%3 → 50%3 (그대로 통과)', () {
      expect(CalculatorInputUtils.resolvePercent('50%3'), '50%3');
    });

    test('괄호 안 퍼센트: (200+50%) → (200+100.0)', () {
      expect(CalculatorInputUtils.resolvePercent('(200+50%)'), '(200+100.0)');
    });

    test('괄호 뒤 퍼센트 (단독): (5+3)% → (5+3)*0.01', () {
      expect(CalculatorInputUtils.resolvePercent('(5+3)%'), '(5+3)*0.01');
    });

    test('괄호 뒤 퍼센트 (+문맥): 5+(3+2)% → 5+5*(3+2)*0.01', () {
      expect(
        CalculatorInputUtils.resolvePercent('5+(3+2)%'),
        '5+5*(3+2)*0.01',
      );
    });

    test('괄호 뒤 퍼센트 (-문맥): 5-(3+2)% → 5-5*(3+2)*0.01', () {
      expect(
        CalculatorInputUtils.resolvePercent('5-(3+2)%'),
        '5-5*(3+2)*0.01',
      );
    });

    test('괄호 뒤 퍼센트 (×문맥): 5×(3+2)% → 5×(3+2)*0.01', () {
      expect(
        CalculatorInputUtils.resolvePercent('5×(3+2)%'),
        '5×(3+2)*0.01',
      );
    });

    test('퍼센트 없으면 그대로', () {
      expect(CalculatorInputUtils.resolvePercent('5+3'), '5+3');
    });
  });
}
