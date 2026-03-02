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
- [x] `basic_calculator_screen.dart` — 다크 그라디언트 테마로 디자인 교체, 수식 줄바꿈/좌우 스크롤
- [x] `main_screen.dart` — 화면 전환 Fade 애니메이션 추가 (진입 400ms / 복귀 300ms)

### Phase 2: 환율 계산기 — `feat/exchange_rate` 완료
- [x] From 1개 + To 3개 구조, 통화 선택 Bottom Sheet (검색, 중복 차단, swap)
- [x] 키패드 5×4 (`0/00` 레이아웃), 수식 입력 지원 (`EvaluateExpressionUseCase` 재사용)
- [x] 1단위 환율 힌트, 새로고침 (CupertinoActivityIndicator, 최소 800ms), 업데이트 시간 표시
- [x] 자릿수 제한 (정수 12, 소수 8) + 토스트, 입력값 천 단위 콤마
- [x] 원형 국기 표시 (`country_flags`), 다크 그라디언트 테마 (딥 네이비 → 틸)
- [x] `core/navigation/calc_page_route.dart` — 화면 전환 공통 라우트
- [x] **Firebase 백엔드** — Cloud Scheduler 매 정각 자동 갱신, Firestore 캐싱
- [x] **Data 계층** — Firestore 연동, 로컬 캐시 (TTL 1시간), 목업 환율 fallback
- [x] **Domain 계층** — ExchangeRateEntity, GetExchangeRateUseCase
- [x] **Presentation 계층** — ExchangeRateViewModel (Notifier + Intent, 교차환율 계산)
- [x] **스펙 문서** — `docs/specs/EXCHANGE_RATE.md` 현행화 완료
- [x] **리팩토링 체크리스트** — `docs/dev/REFACTORING_CHECKLIST.md` 작성

---

## 다음 작업

### 리팩토링 (Phase 2 후속)
> 체크리스트: `docs/dev/REFACTORING_CHECKLIST.md`

### Phase 3 이후 — 추가 계산기 구현 예정
> 로드맵: `docs/plans/ROADMAP.md`

---

## 프로젝트 구조

[`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md) 참고

**상세 작업 이력**: `HISTORY.md` 참조
