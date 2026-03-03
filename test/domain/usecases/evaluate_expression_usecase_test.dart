import 'package:calcmate/domain/usecases/evaluate_expression_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EvaluateExpressionUseCase useCase;

  setUp(() {
    useCase = EvaluateExpressionUseCase();
  });

  group('덧셈', () {
    test('정수 덧셈', () {
      expect(useCase.execute('1+2'), 3.0);
    });

    test('소수 덧셈', () {
      expect(useCase.execute('1.5+2.5'), 4.0);
    });
  });

  group('뺄셈', () {
    test('정수 뺄셈', () {
      expect(useCase.execute('10-3'), 7.0);
    });

    test('음수 결과', () {
      expect(useCase.execute('3-10'), -7.0);
    });
  });

  group('곱셈', () {
    test('정수 곱셈', () {
      expect(useCase.execute('4*3'), 12.0);
    });

    test('소수 곱셈', () {
      expect(useCase.execute('2.5*4'), 10.0);
    });
  });

  group('나눗셈', () {
    test('정수 나눗셈', () {
      expect(useCase.execute('10/2'), 5.0);
    });

    test('소수 결과', () {
      expect(useCase.execute('1/3'), closeTo(0.3333, 0.0001));
    });

    test('0 나누기는 infinity 반환', () {
      expect(useCase.execute('5/0'), double.infinity);
    });
  });

  group('혼합 연산 (우선순위)', () {
    test('곱셈 우선', () {
      expect(useCase.execute('2+3*4'), 14.0);
    });

    test('나눗셈 우선', () {
      expect(useCase.execute('10-6/2'), 7.0);
    });

    test('복합 혼합', () {
      expect(useCase.execute('2*3+4*5'), 26.0);
    });
  });

  group('음수 피연산자', () {
    test('음수로 시작', () {
      expect(useCase.execute('-5+3'), -2.0);
    });

    test('음수 곱셈', () {
      expect(useCase.execute('-3*4'), -12.0);
    });
  });

  group('괄호', () {
    test('기본 괄호', () {
      expect(useCase.execute('(2+3)*4'), 20.0);
    });

    test('중첩 괄호 + 덧셈', () {
      expect(useCase.execute('((2+3)*4)+1'), 21.0);
    });

    test('괄호 안 음수', () {
      expect(useCase.execute('(-5+3)'), -2.0);
    });

    test('이중 중첩 괄호', () {
      expect(useCase.execute('((1+2)*(3+4))'), 21.0);
    });

    test('괄호 뒤 곱셈', () {
      expect(useCase.execute('(10+5)/3'), 5.0);
    });

    test('여러 괄호 그룹', () {
      expect(useCase.execute('(2+3)*(4+1)'), 25.0);
    });

    test('괄호 안 곱셈 우선순위', () {
      expect(useCase.execute('(2+3*4)'), 14.0);
    });
  });

  group('나머지 연산 (mod)', () {
    test('기본 mod', () {
      expect(useCase.execute('10%3'), 1.0);
    });

    test('mod + 덧셈', () {
      expect(useCase.execute('2+10%3'), 3.0);
    });

    test('mod 소수', () {
      expect(useCase.execute('7%2'), 1.0);
    });

    test('mod 우선순위 (곱셈과 동일)', () {
      expect(useCase.execute('3+10%3*2'), 5.0); // 3 + (10%3)*2 = 3+2 = 5
    });
  });

  group('소수점으로 끝나는 입력', () {
    test('5. 은 5로 처리', () {
      expect(useCase.execute('5.+3'), 8.0);
    });

    test('10. 은 10으로 처리', () {
      expect(useCase.execute('10.*2'), 20.0);
    });
  });

  group('잘못된 수식', () {
    test('빈 문자열은 NaN', () {
      expect(useCase.execute('').isNaN, isTrue);
    });

    test('연산자만 있는 경우 NaN', () {
      expect(useCase.execute('+').isNaN, isTrue);
    });
  });
}
