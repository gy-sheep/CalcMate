import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calcmate/presentation/main/main_screen.dart';
import 'package:calcmate/core/theme/app_theme.dart';
import 'package:calcmate/l10n/app_localizations.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        locale: const Locale('ko', 'KR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: child,
      ),
    );
  }

  group('MainScreen 위젯 테스트', () {
    testWidgets('AppBar에 제목과 메뉴 아이콘이 올바르게 표시된다.', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(const MainScreen()));

      expect(find.text('CalcMate'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
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
