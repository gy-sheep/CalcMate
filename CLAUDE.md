# CalcMate - Claude 작업 가이드

## 프로젝트 개요

생활 속 계산을 하나로 해결하는 Flutter 계산기 앱.
기본 계산기, 환율, 단위 변환, 세금, 나이, 날짜 등 10가지 계산기 제공.

## 기술 스택
- **Android Studio**
- **Framework**: Flutter / Dart
- **State Management & DI**: Riverpod (Notifier 기반)
- **Networking**: Dio + Retrofit
- **Serialization**: Freezed + json_serializable
- **Local Storage**: shared_preferences

## 아키텍처

Clean Architecture 3계층 + MVVM + Intent 패턴.
상세 설명은 [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md) 참고.

## 개발 원칙

1. **TDD**: 로직 구현 전 단위 테스트 먼저 작성
2. **불변 상태**: 상태는 항상 Freezed 객체로, `copyWith()`으로 업데이트
3. **계층 의존 방향**: `Presentation → Domain ← Data` (Domain은 외부에 의존하지 않음)
4. **UseCase 단위**: 비즈니스 로직은 UseCase 단위로 분리 (e.g. `CalculateResultUseCase`)
5. **단계별 진행**: Phase별 최소 기능 완성 후 다음 Phase로 이동
6. **위젯 파일 분리**: 실제 구현 단계에서는 위젯을 `widgets/` 폴더로 분리한다 (상세 규칙은 `docs/architecture/ARCHITECTURE.md` 참고)
7. **문자열 l10n 필수**: 사용자에게 노출되는 모든 문자열은 반드시 ARB 파일(`lib/l10n/app_ko.arb`, `app_en.arb`)에 정의하고 `AppLocalizations`를 통해 참조한다. 하드코딩 금지

## 주요 문서

- **로드맵**: `docs/plans/ROADMAP.md`
- **질문/답변 로그**: `docs/prompts/PROPMTS.md`
- **세션 시작 시 반드시 읽기**: `PROGRESS.md` (현재 상태 및 다음 작업 — 구현에 필요한 정보 포함)

## 기능 개발 문서 작성 규칙

기능 개발 전 아래 순서로 문서를 작성한다.

### 1단계: 기획 명세 (Spec)
- **저장 위치**: `docs/specs/{FEATURE_NAME}.md`
- **템플릿**: `docs/specs/_SPEC_TEMPLATE.md`
- **내용**: 요구사항, 화면 구성, 예외 케이스 등 **무엇을** 만들지 정의

### 2단계: UI 프리뷰 (선택)
- 기획 명세 작성 후 사용자가 **"화면만 먼저 개발"** 또는 **"UI 먼저 확인"** 을 요청하면 진행한다
- **구현 전 `memory/patterns.md` 를 읽고** 공통 UI 패턴(스크롤 페이드, 레이아웃 등)을 확인한다
- **텍스트 스타일은 `AppTokens`의 Semantic TextStyle 토큰을 사용**한다. fontSize를 직접 숫자로 쓰지 않고 `.copyWith(color:)`로 색상만 주입한다
- **어떤 컴포넌트에 어떤 토큰을 쓸지는 `docs/conventions/UI_TOKEN_CONVENTION.md` 참고**한다
- **더미 데이터**로 결과가 표시된 상태로 구현하며, **인터랙션**(버튼/탭 동작)도 포함한다
- ViewModel / UseCase / 실제 로직은 구현하지 않는다
- UI 확정 후 3단계로 이동

### 3단계: 구현 명세 (Impl Spec)
- **저장 위치**: `docs/dev/{FEATURE_NAME}.md`
- **템플릿**: `docs/dev/_IMPL_SPEC_TEMPLATE.md`
- **내용**: 파일 구조, 클래스 설계, 구현 순서 등 **어떻게** 만들지 정의
- **dev 파일 작성 후 실제 구현 진행 시 `memory/patterns.md` 를 읽고** 공통 패턴을 적용한다
- **텍스트 스타일·크기·간격 등은 `AppTokens` 토큰을 우선 사용**하고, **컴포넌트별 사용 기준은 `docs/conventions/UI_TOKEN_CONVENTION.md` 참고**한다

## 문서 관리

- **기능 구현 완료 시**: `PROGRESS.md` 업데이트를 제안한다
- **세션 종료 감지 시** ("오늘은 여기까지", "커밋하고 끝낼게" 등): `PROGRESS.md` 업데이트 여부를 확인한다
- **`/commit` 실행 시**: 커밋 전에 `PROGRESS.md` 반영 여부를 자동으로 확인한다
- 업데이트 시 완료된 내용은 `HISTORY.md`로 이동하고, `PROGRESS.md`는 다음 작업 기준으로 유지한다