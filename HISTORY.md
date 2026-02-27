# CalcMate 개발 히스토리

---

## 2026-02-27 — 프로젝트 기반 설정 및 메인 UI 구현

### 완료 항목

**프로젝트 초기 설정**
- Flutter 프로젝트 생성 (`calcmate`)
- `core/theme/app_theme.dart` — Material 3 기반 라이트/다크 테마 정의, 시스템 설정 자동 전환
- `main.dart` — MaterialApp 설정, MainScreen 진입점 연결
- `CLAUDE.md` — Claude 작업 가이드 (아키텍처, 개발 원칙, 문서 관리 규칙)
- `docs/git/COMMIT_CONVENTION.md` — 커밋 메시지 컨벤션 정의
- `docs/plans/ROADMAP.md` — Phase 0~14 구조로 전면 재작성 (13개 계산기 각각 개별 Phase)

**메인 화면 UI**
- `presentation/main/main_screen.dart` — 계산기 카드 리스트 화면 구현 (현재 6개)
- `presentation/widgets/calc_mode_card.dart` — 공통 카드 위젯
  - 카드 배경: 이미지 (`Image.asset`) + errorBuilder 폴백 (회색)
  - Hero 전환: `flightShuttleBuilder` + `FadeTransition`으로 이미지 확장 중 fadeout
  - 그라디언트 오버레이: 좌→우 LinearGradient (#000 60% → #000 20%), 텍스트 가독성 확보
  - Hero 태그 3개: `calc_bg_`, `calc_icon_`, `calc_title_`
- `presentation/calculator/basic_calculator_screen.dart` — 플레이스홀더 화면
  - Hero 도착지 구조: 투명 `Container()` (Hero) + 단색 `Container(color)` (실제 배경) 분리

**인프라**
- `assets/images/` 디렉토리 생성, `pubspec.yaml` 자산 경로 등록
- `macos/Runner/Info.plist` — `FLTEnableImpeller: false` 추가 (macOS 셰이더 컴파일 오류 해결)
- `.claude/commands/` — `commit.md`, `qa.md`, `sync-docs.md` 커스텀 커맨드 추가

**Q&A 문서**
- `docs/prompts/answers/Q0001.md` — MVVM/MVI 패턴 설명
- `docs/prompts/answers/Q0002.md` — Git 브랜치 전략 (GitHub Flow 기반, 번호 없는 기능명)
- `docs/prompts/answers/Q0003.md` — Google Stitch → Flutter 적용 방법
- `docs/prompts/answers/Q0004.md` — 카드 이미지 배경 + Hero fadeout 구현 방법

### 커밋
- `068dcec` — Initial commit
- `52fa419` — feat: 카드 배경 이미지 전환 및 프로젝트 기반 설정

---

## 2026-02-27 — 메인 화면 UI 완성 및 13개 카드 전체 구현

### 완료 항목

**메인 화면 개선**
- `presentation/main/main_screen.dart` — StatefulWidget 전환
  - ScrollController 기반 스크롤 감지 (`_isScrolled`)
  - 스크롤 시 BackdropFilter blur(20) + 흰색 75% 투명 AppBar 애니메이션 전환
  - 13개 계산기 카드 전체 추가 (기본~BMI)
  - ListView top padding: `statusBar + toolbarHeight + 16`

**카드 UI 개선** (`presentation/widgets/calc_mode_card.dart`)
- 아이콘: CircleAvatar → Container(44×44, borderRadius:10, white 25%)
- 타이틀 텍스트: 4방향 그림자 (Colors.black26, offset ±1.5) 추가
- 레이아웃: CrossAxisAlignment.center, Column mainAxisSize.min, 타이틀-설명 간격 제거
- 우측 체브론 CircleAvatar 버튼 추가 (white 20%, chevron_right)

**에셋 재구성**
- `assets/images/backgrounds/` 폴더 구성
  - Image.png~Image-12.png → 의미있는 파일명으로 rename (13개)
  - `pubspec.yaml` 자산 경로 업데이트

**문서 추가**
- `docs/conventions/NAMING_CONVENTION.md` — 파일명·클래스명·에셋·Hero 태그 명명 규칙
- `docs/prompts/answers/Q0007.md` — 메인 화면 목록 구조 (설정 기반 순서 변경)
- `docs/prompts/answers/Q0008.md` — 문자열·사이즈값 관리 (constants, l10n)

**인프라**
- `android/gradle.properties` — JVM Xmx 8G → 2g 메모리 최적화
- `.claude/commands/commit.md` — .py → .dart 파일 감지 오류 수정
- `.claude/commands/sync-docs.md` — 잘못된 docs 경로 수정 (docs/dev/, docs/git/ 제거)

### 커밋
- `136b02a` — feat: 메인 화면 UI 완성 및 13개 계산기 카드 전체 구현

---

## 2026-02-27 — Phase 0 인프라 완성

### 완료 항목

**의존성 추가** (`pubspec.yaml`)
- `flutter_riverpod ^2.6.1` — 상태관리
- `dio ^5.7.0`, `retrofit ^4.4.1` — 네트워크
- `freezed_annotation ^2.4.4`, `json_annotation ^4.9.0` — 직렬화
- `shared_preferences ^2.3.3` — 로컬 저장소
- `build_runner`, `freezed`, `json_serializable`, `retrofit_generator` — 코드 생성 (dev)

**DI 설정** (`core/di/providers.dart`)
- `dioProvider` — Dio 인스턴스 (timeout 10초, LogInterceptor + ErrorInterceptor)

**네트워크 인터셉터** (`core/network/error_interceptor.dart`)
- 타임아웃, 연결 오류, 서버 오류를 한국어 메시지로 변환

**앱 진입점** (`main.dart`)
- `ProviderScope`로 앱 전체 래핑

**문서 추가**
- `docs/prompts/answers/Q0009.md` — 다음 작업 우선순위 (Phase 0 → 카드 리팩터링 → Phase 1)
- `docs/prompts/answers/Q0010.md` — Riverpod ProviderScope 개념 설명

**커맨드 개선** (`.claude/commands/commit.md`)
- push 완료 후 `/clear` 안내 문구 추가

### 커밋
- (이번 커밋)
