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

### Phase 2: 환율 계산기 — `feat/exchange_rate` 완료
- [x] `presentation/currency/currency_calculator_screen.dart` — 목업 기반 환율 계산기 UI 구현
  - From/To 1:1 환율 변환, 통화 선택 Bottom Sheet(검색 포함), 스왑 버튼
  - 앱바 Hero 애니메이션 (`calc_icon_$title`, `calc_title_$title`)
  - 기본 계산기와 동일한 5×4 키패드 (연산자·수식·% 지원, `EvaluateExpressionUseCase` 재사용)
  - 다크 그라디언트 테마 (딥 네이비 → 틸)
- [x] `core/navigation/calc_page_route.dart` — 화면 전환 공통 라우트 (기본 Fade, 메뉴별 커스텀 지원)
- [x] `main_screen.dart` — CalcPageRoute 적용, 환율 계산기 Hero 애니메이션 연결
- [x] `docs/dev/EXCHANGE_RATE_CALCULATOR.md` — 환율 계산기 구현 명세 (Firebase 연동 구조로 업데이트)
- [x] `docs/specs/` — 스펙 문서 디렉토리 신설 (템플릿, 기본/환율 계산기 스펙)
- [x] **Firebase 백엔드** — 프로젝트 생성(calcmate-353ed), Function 배포, Firestore 보안 규칙
  - `docs/dev/firebase/FIREBASE_EXCHANGE_RATE_BACKEND.md` — 구현 명세
  - `docs/dev/firebase/FIREBASE_GUIDE.md` — 셋업 및 배포 가이드
  - `functions/src/index.ts` — refreshExchangeRates (Double Check Locking, TTL 1시간)
  - `firestore.rules` — exchange_rates 읽기만 허용
- [x] **Data 계층** — Firestore 연동 RemoteDataSource, 환율 DTO, Repository 구현체
  - `data/datasources/exchange_rate_remote_datasource.dart` — Firestore 직접 읽기 + Function 트리거
  - `data/datasources/exchange_rate_local_datasource.dart` — SharedPreferences 캐시 (TTL 1시간)
  - `data/dto/exchange_rate_dto.dart` — Firestore 문서 DTO (Freezed + json_serializable)
  - `data/repositories/exchange_rate_repository_impl.dart` — 3단계 fallback (로컬→Firestore→Function)
- [x] **Domain 계층** — ExchangeRateEntity, GetExchangeRateUseCase
  - `domain/models/exchange_rate_entity.dart` — ExchangeRateEntity (Freezed)
  - `domain/repositories/exchange_rate_repository.dart` — Repository 인터페이스
  - `domain/usecases/get_exchange_rate_usecase.dart` — 환율 조회 UseCase
- [x] **Presentation 계층** — 목업 → 실제 Firestore 연동, ViewModel 분리
  - `presentation/currency/currency_calculator_viewmodel.dart` — ExchangeRateViewModel (Notifier + sealed Intent, 교차환율 계산)
  - `presentation/currency/currency_calculator_screen.dart` — StatefulWidget → ConsumerWidget 전환
- [x] **DI** — `core/di/providers.dart` 환율 관련 Provider 전체 등록
- [x] **Firebase 초기화** — `main.dart`에 Firebase.initializeApp() + SharedPreferences override
- [x] **오프라인 fallback** — 마지막 조회 환율 SharedPreferences 캐싱 (유효 기간 1시간)
- [x] **Cloud Scheduler 도입** — Blaze 플랜 전환, `scheduledExchangeRateRefresh` 매 정각 자동 갱신
  - `functions/src/index.ts` — `fetchAndStoreRates()` 공통 함수 분리, `onSchedule` 추가 (`0 * * * *`, `Asia/Seoul`)
  - 앱 클라이언트 Firebase Function 트리거 로직 제거 → 2단계 fallback으로 단순화 (로컬캐시→Firestore)
- [x] **기본/환율 계산기 autoDispose 적용** — 화면 재진입 시 이전 입력값 초기화 버그 수정
  - `basic_calculator_viewmodel.dart`, `currency_calculator_viewmodel.dart` — `NotifierProvider.autoDispose`
- [x] **환율 계산기 UX 개선**
  - 기본 통화 KRW/USD (기존 USD/KRW에서 변경)
  - 스왑 버튼 두 통화 행 사이 중앙 → 좌측 통화 코드 아래로 이동
  - 금액 텍스트 오버플로우 수정 (`FittedBox(fit: BoxFit.scaleDown)`)
  - Progress indicator Stack 오버레이로 화면 정중앙 배치
- [x] `.claude/commands/deploy-functions.md` — `/deploy-functions` 슬래시 커맨드 추가

---

## 다음 작업

### Phase 3 이후 — 추가 계산기 구현 예정

> 로드맵: `docs/plans/ROADMAP.md`

---

## 프로젝트 구조

[`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md) 참고

**상세 작업 이력**: `HISTORY.md` 참조
