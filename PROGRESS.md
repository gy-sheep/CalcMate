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
  - ConsumerStatefulWidget 전환, ScrollController 기반 스크롤 감지
  - 스크롤 시 BackdropFilter blur(20) + 흰색 75% 투명 AppBar 전환
- [x] `presentation/widgets/calc_mode_card.dart` — 카드 위젯
  - 이미지 배경 + Hero fadeout 전환 애니메이션
  - 그라디언트 오버레이 (좌→우, 60%→20% black)
  - 라운드 사각형 아이콘 컨테이너, 타이틀 외곽 그림자, 체브론 버튼
- [x] macOS Impeller 비활성화 (`macos/Runner/Info.plist`)
- [x] Android Gradle JVM 메모리 최적화 (`android/gradle.properties`)

### 카드 리스트 리팩터링 (Phase 1 선행) — `feat/calc-mode-card-refactor` 완료
- [x] `domain/models/calc_mode_entry.dart` — CalcModeEntry (Freezed) 모델 정의
- [x] `core/config/calc_mode_config.dart` — 13개 항목 상수 정의
- [x] `presentation/main/main_screen_viewmodel.dart` — NotifierProvider, State, Intent
- [x] `presentation/main/main_screen.dart` — ConsumerStatefulWidget 전환, Provider 구독
- [x] `pubspec.yaml` — retrofit 버전 충돌 수정 (`>=4.4.1 <4.9.0`)

### Phase 1: 기본 계산기 — `feat/basic-calculator` 완료
- [x] 기본 계산기 UI 구현 (뉴모피즘 디자인, iOS 동일 버튼 레이아웃)
- [x] `docs/dev/BASIC_CALCULATOR.md` — 구현 명세 작성
- [x] `domain/models/calculator_state.dart` — CalculatorState (Freezed) 정의
- [x] `domain/usecases/evaluate_expression_usecase.dart` — TDD 작성 후 구현 (14케이스)
- [x] `presentation/calculator/basic_calculator_viewmodel.dart` — CalculatorViewModel (Notifier + sealed Intent)
- [x] `presentation/calculator/basic_calculator_screen.dart` — ConsumerWidget 전환 및 ViewModel 연결
- [x] 아이폰 계산기 동작 방식으로 UX 개선: 천 단위 콤마, 음수 괄호 표시, 동적 폰트 사이즈, 오버플로우 시 오른쪽 고정 스크롤, % 기호 표시 및 컨텍스트 계산, = 반복, AC/C 동적 전환, 스마트 클리어, 음수 입력 모드
- [x] `basic_calculator_screen.dart` — 다크 그라디언트 테마로 디자인 교체 (v2 프로토타입 검증 후 통합), 아이콘·타이틀 Hero 애니메이션 유지
- [x] `main_screen.dart` — 화면 전환 Fade 애니메이션 추가 (진입 400ms / 복귀 300ms)

---

## 다음 작업

### Phase 2: 환율 계산기 — `feat/exchange-rate`

> 구현 명세: `docs/dev/EXCHANGE_RATE_CALCULATOR.md`

- [x] `presentation/currency/currency_calculator_screen.dart` — 목업 기반 환율 계산기 UI 구현
  - From/To 1:1 환율 변환, 통화 선택 Bottom Sheet(검색 포함), 스왑 버튼
  - 앱바 Hero 애니메이션 (`calc_icon_$title`, `calc_title_$title`)
  - 기본 계산기와 동일한 5×4 키패드 (연산자·수식·% 지원, `EvaluateExpressionUseCase` 재사용)
  - 다크 그라디언트 테마 (딥 네이비 → 틸)
- [x] `core/navigation/calc_page_route.dart` — 화면 전환 공통 라우트 (기본 Fade, 메뉴별 커스텀 지원)
- [x] `main_screen.dart` — CalcPageRoute 적용, 환율 계산기 Hero 애니메이션 연결
- [x] `docs/dev/EXCHANGE_RATE_CALCULATOR.md` — 환율 계산기 구현 명세 작성
- [x] `docs/specs/` — 스펙 문서 디렉토리 신설 (템플릿, 기본/환율 계산기 스펙)
- [ ] **Data**: Retrofit API 인터페이스, 환율 DTO, Repository 구현체
- [ ] **Domain**: `ExchangeRateEntity`, `GetExchangeRateUseCase`
- [ ] **Presentation**: 목업 → 실제 API 연동, ViewModel 분리
- [ ] **ViewModel**: `ExchangeRateViewModel` (Notifier — API + 입력 상태 통합 관리)
- [ ] 오프라인 fallback: 마지막 조회 환율 `shared_preferences` 캐싱 (유효 기간 1시간)

---

## 프로젝트 구조 (현재)

```
lib/
├── core/
│   ├── config/
│   │   └── calc_mode_config.dart        # 13개 항목 상수 (kCalcModeEntries)
│   ├── di/
│   │   └── providers.dart               # dioProvider
│   ├── navigation/
│   │   └── calc_page_route.dart         # 화면 전환 공통 라우트 (Fade 기본, 커스텀 지원)
│   ├── network/
│   │   └── error_interceptor.dart       # 공통 오류 처리
│   └── theme/
│       └── app_theme.dart               # 라이트/다크 테마
├── domain/
│   ├── models/
│   │   ├── calc_mode_entry.dart         # CalcModeEntry (Freezed)
│   │   └── calculator_state.dart        # CalculatorState (Freezed)
│   └── usecases/
│       └── evaluate_expression_usecase.dart  # 사칙연산 파서
├── presentation/
│   ├── main/
│   │   ├── main_screen.dart             # 메인 화면 (ConsumerStatefulWidget)
│   │   └── main_screen_viewmodel.dart   # MainScreenViewModel (Notifier)
│   ├── calculator/
│   │   ├── basic_calculator_screen.dart     # 기본 계산기 (ConsumerWidget, 다크 테마)
│   │   └── basic_calculator_viewmodel.dart  # BasicCalculatorViewModel (Notifier)
│   ├── currency/
│   │   └── currency_calculator_screen.dart    # 환율 계산기 (목업, Hero 애니메이션, 5×4 키패드)
│   └── widgets/
│       └── calc_mode_card.dart          # 공통 계산기 카드 위젯
└── main.dart
```

**상세 작업 이력**: `HISTORY.md` 참조
