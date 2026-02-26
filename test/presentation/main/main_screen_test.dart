import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calcmate/presentation/main/main_screen.dart';
import 'package:calcmate/core/theme/app_theme.dart';

void main() {
  // 테스트를 위한 앱 래퍼 위젯입니다.
  // MaterialApp을 포함하여 테마와 같은 앱 전체 설정을 적용해줍니다.
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: child,
    );
  }

  group('MainScreen 위젯 테스트', () {
    testWidgets('AppBar에 제목과 설정 아이콘이 올바르게 표시된다.', (WidgetTester tester) async {
      // 1. 테스트할 위젯을 빌드합니다.
      await tester.pumpWidget(makeTestableWidget(const MainScreen()));

      // 2. 검증합니다.
      // - AppBar의 제목 'Calcmate'를 찾습니다.
      expect(find.text('Calcmate'), findsOneWidget);

      // - 설정 아이콘을 찾습니다.
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('6개의 계산기 모드 카드가 리스트에 표시된다.', (WidgetTester tester) async {
      // 1. 테스트할 위젯을 빌드합니다.
      await tester.pumpWidget(makeTestableWidget(const MainScreen()));

      // 2. 검증합니다.
      // - '기본 계산기' 텍스트를 가진 위젯을 찾습니다.
      expect(find.text('기본 계산기'), findsOneWidget);

      // - '환율 계산기' 텍스트를 가진 위젯을 찾습니다.
      expect(find.text('환율 계산기'), findsOneWidget);

      // - ListView 위젯이 존재하는지 확인합니다.
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
