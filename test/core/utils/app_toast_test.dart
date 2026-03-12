import 'package:calcmate/core/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildApp({required Widget child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  /// 토스트 표시 후 입장 애니메이션 완료까지 pump
  Future<void> showAndPump(WidgetTester tester, String buttonLabel) async {
    await tester.tap(find.text(buttonLabel));
    await tester.pump(); // 오버레이 삽입
    await tester.pump(const Duration(milliseconds: 300)); // 입장 애니메이션
  }

  /// 자동 소멸 타이머 + 퇴장 애니메이션까지 pump
  Future<void> pumpUntilDismissed(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 2000)); // displayDuration
    await tester.pump(const Duration(milliseconds: 250)); // 퇴장 애니메이션
    await tester.pump(); // 오버레이 제거
  }

  group('showAppToast', () {
    testWidgets('메시지가 표시된다', (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAppToast(context, '테스트 메시지'),
            child: const Text('show'),
          ),
        ),
      ));

      await showAndPump(tester, 'show');
      expect(find.text('테스트 메시지'), findsOneWidget);

      // 타이머 소진
      await pumpUntilDismissed(tester);
    });

    testWidgets('info 타입 — info 아이콘 표시', (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAppToast(context, 'info'),
            child: const Text('show'),
          ),
        ),
      ));

      await showAndPump(tester, 'show');
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);

      await pumpUntilDismissed(tester);
    });

    testWidgets('success 타입 — check 아이콘 표시', (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () =>
                showAppToast(context, 'ok', type: ToastType.success),
            child: const Text('show'),
          ),
        ),
      ));

      await showAndPump(tester, 'show');
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);

      await pumpUntilDismissed(tester);
    });

    testWidgets('error 타입 — error 아이콘 표시', (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () =>
                showAppToast(context, 'err', type: ToastType.error),
            child: const Text('show'),
          ),
        ),
      ));

      await showAndPump(tester, 'show');
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);

      await pumpUntilDismissed(tester);
    });

    testWidgets('중복 호출 시 기존 토스트가 교체된다', (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => Column(
            children: [
              ElevatedButton(
                onPressed: () => showAppToast(context, '첫 번째'),
                child: const Text('first'),
              ),
              ElevatedButton(
                onPressed: () => showAppToast(context, '두 번째'),
                child: const Text('second'),
              ),
            ],
          ),
        ),
      ));

      await showAndPump(tester, 'first');
      expect(find.text('첫 번째'), findsOneWidget);

      await showAndPump(tester, 'second');

      // 두 번째만 보여야 한다
      expect(find.text('첫 번째'), findsNothing);
      expect(find.text('두 번째'), findsOneWidget);

      await pumpUntilDismissed(tester);
    });

    testWidgets('2초 후 자동 소멸', (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAppToast(context, '사라질 메시지'),
            child: const Text('show'),
          ),
        ),
      ));

      await showAndPump(tester, 'show');
      expect(find.text('사라질 메시지'), findsOneWidget);

      // 자동 소멸 (2000ms 타이머 + 퇴장 애니메이션)
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(find.text('사라질 메시지'), findsNothing);
    });
  });
}
