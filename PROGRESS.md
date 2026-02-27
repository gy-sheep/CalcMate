# CalcMate 개발 진행 상황

## 현재 완료 상태

### Phase 0 (진행 중)
- [x] `core/theme/app_theme.dart` — 라이트/다크 테마 정의 (Material 3, system 자동 전환)
- [x] `main.dart` — 앱 진입점, MaterialApp 설정
- [x] `assets/images/backgrounds/` 디렉토리 생성 및 `pubspec.yaml` 자산 경로 등록
- [x] `docs/git/COMMIT_CONVENTION.md` — 커밋 메시지 규칙 정의
- [x] `docs/conventions/NAMING_CONVENTION.md` — 파일명·클래스명·에셋 명명 규칙 정의
- [x] `CLAUDE.md` — Claude 작업 가이드 작성
- [ ] `pubspec.yaml` 의존성 추가 (Riverpod, Dio, Retrofit, Freezed 등) — **미완료**
- [ ] `core/di/` — Riverpod ProviderScope, Dio Provider — **미완료**
- [ ] `core/network/` — Dio 인터셉터 — **미완료**

### UI 기반 작업 (Phase 0 외 선행 구현)
- [x] `presentation/main/main_screen.dart` — 메인 화면, 13개 카드 리스트 UI
  - StatefulWidget 전환, ScrollController 기반 스크롤 감지
  - 스크롤 시 BackdropFilter blur(20) + 흰색 75% 투명 AppBar 전환
- [x] `presentation/widgets/calc_mode_card.dart` — 카드 위젯
  - 이미지 배경 + Hero fadeout 전환 애니메이션
  - flightShuttleBuilder로 확장 중 이미지 fadeout 구현
  - 그라디언트 오버레이 (좌→우, 60%→20% black)
  - 라운드 사각형 아이콘 컨테이너 (44×44, borderRadius: 10)
  - 타이틀 텍스트 4방향 외곽 그림자 (Colors.black26)
  - 우측 체브론 CircleAvatar 버튼
- [x] `presentation/calculator/basic_calculator_screen.dart` — 플레이스홀더 화면
  - Hero 도착지 분리 (투명 Container + 별도 단색 배경)
- [x] macOS Impeller 비활성화 (`macos/Runner/Info.plist`) — 셰이더 컴파일 오류 해결
- [x] Android Gradle JVM 메모리 최적화 (`android/gradle.properties`) — Xmx 8G → 2g

## 다음 작업

### Phase 0 마무리
1. `pubspec.yaml`에 의존성 추가 (flutter_riverpod, dio, retrofit, freezed, json_serializable, shared_preferences)
2. `core/di/` — Riverpod ProviderScope 설정
3. `core/network/` — Dio 인터셉터

### Phase 1 (다음 Phase)
- `CalculatorState` (Freezed), `CalculatorIntent` (sealed class) 정의
- `EvaluateExpressionUseCase` TDD 작성
- 기본 계산기 UI 구현 (결과창 + 버튼 패드)
- `CalculatorViewModel` (Riverpod Notifier)

## 프로젝트 구조 (현재)

```
lib/
├── core/
│   └── theme/
│       └── app_theme.dart       # 라이트/다크 테마
├── presentation/
│   ├── main/
│   │   └── main_screen.dart     # 메인 화면 (13개 카드 리스트)
│   ├── calculator/
│   │   └── basic_calculator_screen.dart  # 기본 계산기 (플레이스홀더)
│   └── widgets/
│       └── calc_mode_card.dart  # 공통 계산기 카드 위젯
└── main.dart
```

**상세 작업 이력**: `HISTORY.md` 참조
