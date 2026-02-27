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
}
