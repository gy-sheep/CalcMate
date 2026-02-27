# CalcMate 개발 진행 상황

## 현재 완료 상태

### Phase 0 — 완료
- [x] `core/theme/app_theme.dart` — 라이트/다크 테마 정의 (Material 3, system 자동 전환)
- [x] `main.dart` — 앱 진입점, ProviderScope 래핑, MaterialApp 설정
- [x] `pubspec.yaml` 의존성 추가 (flutter_riverpod, dio, retrofit, freezed, json_serializable, shared_preferences)
- [x] `core/di/providers.dart` — dioProvider (LogInterceptor + ErrorInterceptor)
- [x] `core/network/error_interceptor.dart` — 공통 오류 처리 인터셉터
- [x] `assets/images/backgrounds/` 디렉토리 생성 및 `pubspec.yaml` 자산 경로 등록
- [x] `docs/git/COMMIT_CONVENTION.md` — 커밋 메시지 규칙 정의
- [x] `docs/conventions/NAMING_CONVENTION.md` — 파일명·클래스명·에셋 명명 규칙 정의
- [x] `CLAUDE.md` — Claude 작업 가이드 작성

### UI 기반 작업 (Phase 0 외 선행 구현)
- [x] `presentation/main/main_screen.dart` — 메인 화면, 13개 카드 리스트 UI
  - StatefulWidget 전환, ScrollController 기반 스크롤 감지
  - 스크롤 시 BackdropFilter blur(20) + 흰색 75% 투명 AppBar 전환
- [x] `presentation/widgets/calc_mode_card.dart` — 카드 위젯
  - 이미지 배경 + Hero fadeout 전환 애니메이션
  - 그라디언트 오버레이 (좌→우, 60%→20% black)
  - 라운드 사각형 아이콘 컨테이너, 타이틀 외곽 그림자, 체브론 버튼
- [x] `presentation/calculator/basic_calculator_screen.dart` — 플레이스홀더 화면
- [x] macOS Impeller 비활성화 (`macos/Runner/Info.plist`)
- [x] Android Gradle JVM 메모리 최적화 (`android/gradle.properties`)

## 다음 작업

### 카드 리스트 리팩터링 (Phase 1 선행 작업) — `feat/calc-mode-card-refactor`

1. `domain/models/calc_mode_entry.dart` — CalcModeEntry (Freezed) 모델 정의
   - id, title, description, icon, imagePath, isVisible, order 필드
2. `core/config/calc_mode_config.dart` — 13개 기본 항목 상수 정의
3. `presentation/main/main_screen_viewmodel.dart` — NotifierProvider, 카드 리스트 상태 관리
4. `presentation/main/main_screen.dart` — ConsumerWidget 전환, Provider 구독

### Phase 1: 기본 계산기 — `feat/basic-calculator`

1. `CalculatorState` (Freezed), `CalculatorIntent` (sealed class) 정의
2. `EvaluateExpressionUseCase` — TDD 작성 후 구현
3. `CalculatorViewModel` (Riverpod Notifier, handleIntent)
4. 기본 계산기 UI 구현 (결과창 + 버튼 패드)

## 프로젝트 구조 (현재)

```
lib/
├── core/
│   ├── di/
│   │   └── providers.dart           # dioProvider
│   ├── network/
│   │   └── error_interceptor.dart   # 공통 오류 처리
│   └── theme/
│       └── app_theme.dart           # 라이트/다크 테마
├── presentation/
│   ├── main/
│   │   └── main_screen.dart         # 메인 화면 (13개 카드 리스트)
│   ├── calculator/
│   │   └── basic_calculator_screen.dart  # 기본 계산기 (플레이스홀더)
│   └── widgets/
│       └── calc_mode_card.dart      # 공통 계산기 카드 위젯
└── main.dart
```

**상세 작업 이력**: `HISTORY.md` 참조
