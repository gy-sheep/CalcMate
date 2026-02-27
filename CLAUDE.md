# CalcMate - Claude 작업 가이드

## 프로젝트 개요

생활 속 계산을 하나로 해결하는 Flutter 계산기 앱.
기본 계산기, 환율, 단위 변환, 세금, 나이, 날짜 등 13가지 계산기 제공 예정.

## 기술 스택

- **Framework**: Flutter / Dart
- **State Management & DI**: Riverpod (Notifier 기반)
- **Networking**: Dio + Retrofit
- **Serialization**: Freezed + json_serializable
- **Local Storage**: shared_preferences

## 아키텍처

Clean Architecture — 3계층을 엄격히 분리한다.

```
lib/
├── core/           # 공통 유틸리티, 테마, DI 설정
├── data/           # API 클라이언트, DTO, Repository 구현체
├── domain/         # Entity, Repository 인터페이스, UseCase (순수 Dart)
└── presentation/   # Widget(View), ViewModel(Riverpod Notifier), State
```

### 패턴: MVVM + Intent

- **View**: `ConsumerWidget` — 상태를 구독하고 Intent를 전달하는 역할만 한다
- **ViewModel**: `Riverpod Notifier` — `handleIntent()`로 액션을 받아 State를 계산
- **Intent**: `sealed class` — 가능한 모든 사용자 액션을 타입으로 정의
- **State**: `Freezed` 불변 객체 — UI 상태 전체를 담는 단일 진실 공급원

## 개발 원칙

1. **TDD**: 로직 구현 전 단위 테스트 먼저 작성
2. **불변 상태**: 상태는 항상 Freezed 객체로, `copyWith()`으로 업데이트
3. **계층 의존 방향**: `Presentation → Domain ← Data` (Domain은 외부에 의존하지 않음)
4. **UseCase 단위**: 비즈니스 로직은 UseCase 단위로 분리 (e.g. `CalculateResultUseCase`)
5. **단계별 진행**: Phase별 최소 기능 완성 후 다음 Phase로 이동

## 주요 문서

- **로드맵**: `docs/plans/ROADMAP.md`
- **질문/답변 로그**: `docs/prompts/PROPMTS.md`
- **세션 시작 시 반드시 읽기**: `PROGRESS.md` (현재 상태 및 다음 작업 — 구현에 필요한 정보 포함)

## 문서 관리

- **Phase/Step 구현 완료 시**: `PROGRESS.md` 업데이트를 제안한다
- **세션 종료 감지 시** ("오늘은 여기까지", "커밋하고 끝낼게" 등): `PROGRESS.md` 업데이트 여부를 확인한다
- **`/commit` 실행 시**: 커밋 전에 `PROGRESS.md` 반영 여부를 자동으로 확인한다
- 업데이트 시 완료된 내용은 `HISTORY.md`로 이동하고, `PROGRESS.md`는 다음 작업 기준으로 유지한다