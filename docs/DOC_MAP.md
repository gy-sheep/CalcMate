# CalcMate 문서 구조 가이드

프로젝트 내 모든 문서 파일의 위치, 용도, 관계를 한눈에 파악하기 위한 지도 문서.

---

## 전체 구조도

```
CalcMate/
│
├── README.md                          # 프로젝트 소개 (외부 공개용)
├── CLAUDE.md                          # Claude AI 작업 가이드 (세션 규칙)
├── PROGRESS.md                        # 현재 개발 진행 상태 (세션 시작 시 필독)
├── HISTORY.md                         # 완료된 작업 이력
│
├── .claude/
│   └── commands/                      # 커스텀 슬래시 명령어 정의
│       ├── commit.md                  #   /commit — 커밋 자동화 워크플로
│       ├── qa.md                      #   /qa     — 질문/답변 기록 워크플로
│       ├── sync-docs.md               #   /sync-docs — 코드 변경 시 문서 동기화
│       └── deploy-functions.md        #   /deploy-functions — Firebase 배포
│
└── docs/
    ├── architecture/
    │   └── ARCHITECTURE.md            # 아키텍처 설계 (Clean Arch + MVVM + Intent)
    │
    ├── conventions/
    │   └── NAMING_CONVENTION.md       # 파일/클래스/에셋 네이밍 규칙
    │
    ├── git/
    │   └── COMMIT_CONVENTION.md       # Git 커밋 메시지 형식 규칙
    │
    ├── plans/
    │   └── ROADMAP.md                 # 13개 계산기 구현 단계별 로드맵
    │
    ├── specs/                         # 기능 명세 (UX/기획 관점)
    │   ├── _SPEC_TEMPLATE.md          #   신규 계산기 명세 작성 템플릿
    │   ├── BASIC_CALCULATOR.md        #   기본 계산기 UX 명세
    │   └── EXCHANGE_RATE.md           #   환율 계산기 UX 명세
    │
    ├── dev/                           # 구현 명세 (개발/아키텍처 관점)
    │   ├── _IMPL_SPEC_TEMPLATE.md     #   구현 명세 작성 템플릿
    │   ├── BASIC_CALCULATOR.md        #   기본 계산기 구현 명세
    │   ├── EXCHANGE_RATE_CALCULATOR.md#   환율 계산기 구현 명세
    │   ├── CARD_LIST_REFACTOR.md      #   메인 카드 리스트 리팩터링 명세
    │   ├── TERMINAL_COMMAND.md        #   자주 쓰는 Flutter 터미널 명령어 모음
    │   └── firebase/
    │       ├── FIREBASE_GUIDE.md      #   Firebase 프로젝트 설정 및 배포 가이드
    │       └── FIREBASE_EXCHANGE_RATE_BACKEND.md  # 환율 캐싱 백엔드 설계
    │
    └── prompts/                       # 질문/답변 지식 베이스
        ├── PROPMTS.md                 #   Q&A 마스터 인덱스
        └── answers/
            ├── Q0001.md               #   개별 답변 문서 (Q0001~Q0017 답변 완료)
            └── ...
```

---

## 파일별 상세 설명

### 루트 레벨 — 프로젝트 핵심 문서

| 파일 | 용도 | 주 독자 |
|------|------|---------|
| `README.md` | 앱 소개, 기능 목록, 기술 스택 요약. GitHub 등 외부에 공개되는 첫 페이지 | 외부 방문자 |
| `CLAUDE.md` | Claude와 협업 시 따라야 할 규칙 정의. 기술 스택, 아키텍처 원칙, 문서 관리 방식 포함 | Claude AI |
| `PROGRESS.md` | **세션 시작 시 반드시 확인.** 현재 Phase 진행 상태, 완료/미완료 작업, 다음 할 일 | 개발자·Claude |
| `HISTORY.md` | 완료된 작업의 날짜별 이력. PROGRESS.md에서 완료된 항목이 여기로 이동 | 개발자 |

---

### `.claude/commands/` — 자동화 슬래시 명령어

Claude CLI에서 `/명령어`로 실행하는 자동화 워크플로 정의 파일.

| 파일 | 명령어 | 수행 작업 |
|------|--------|-----------|
| `commit.md` | `/commit` | 변경 코드 분석 → 관련 문서 동기화 → PROGRESS.md 업데이트 여부 확인 → 커밋 컨벤션에 맞춰 커밋 생성 |
| `qa.md` | `/qa [키워드 또는 ID]` | PROPMTS.md에서 질문 탐색 → 답변 작성 → `docs/prompts/answers/QXXXX.md`에 저장 → 인덱스 상태 업데이트 |
| `sync-docs.md` | `/sync-docs` | 변경된 코드 파악 → 관련 문서 검색 → 불일치 항목 식별 → 승인 후 문서 업데이트 |
| `deploy-functions.md` | `/deploy-functions` | Firebase Functions 빌드 및 배포 → 결과 요약 또는 오류 분석 |

---

### `docs/architecture/` — 아키텍처 설계

| 파일 | 설명 |
|------|------|
| `ARCHITECTURE.md` | Clean Architecture 3계층(Presentation → Domain ← Data) 구조 설명. MVVM + Intent 패턴, 각 계층의 역할과 의존 방향, 코드 예시 포함. 모든 구현 명세의 기반 문서 |

---

### `docs/conventions/` — 코딩 규칙

| 파일 | 설명 |
|------|------|
| `NAMING_CONVENTION.md` | 파일명(snake_case + 역할 접미사), 클래스명, 에셋 경로 등 프로젝트 전반의 네이밍 규칙. 일관성 유지를 위해 신규 파일 생성 전 반드시 참고 |

---

### `docs/git/` — Git 협업 규칙

| 파일 | 설명 |
|------|------|
| `COMMIT_CONVENTION.md` | 커밋 타입(feat/fix/docs/refactor/test/chore/style), 메시지 형식, 한국어/영어 사용 기준 정의. `/commit` 명령어가 이 규칙을 자동 적용 |

---

### `docs/plans/` — 개발 로드맵

| 파일 | 설명 |
|------|------|
| `ROADMAP.md` | Phase 0(기반 구축)부터 Phase 1~13(13개 계산기)까지 단계별 목표와 세부 작업 목록. 전체 개발 방향의 기준 문서 |

---

### `docs/specs/` — 기능 명세 (UX/기획 관점)

사용자 경험과 기능 요구사항을 기술한 문서. **"무엇을 만들 것인가"**에 초점.

| 파일 | 설명 |
|------|------|
| `_SPEC_TEMPLATE.md` | 새 계산기 기능 명세 작성 시 사용하는 템플릿. 화면 구성, 입력/출력 정의, 예외 처리 항목 포함 |
| `BASIC_CALCULATOR.md` | iOS 계산기 스타일 UX, 사칙연산·%, AC/C 동작 방식, 버튼 레이아웃 명세 |
| `EXCHANGE_RATE.md` | 실시간 환율 변환, 수식 입력 방식, 오프라인 캐싱 동작, 통화 선택 UX 명세 |

---

### `docs/dev/` — 구현 명세 (개발/아키텍처 관점)

코드 수준의 설계와 구현 방법을 기술한 문서. **"어떻게 만들 것인가"**에 초점.

| 파일 | 설명 |
|------|------|
| `_IMPL_SPEC_TEMPLATE.md` | 구현 명세 작성 템플릿. 배경, 목표, 관련 파일, 계층별 설계, 데이터 흐름, 인수 조건 섹션 포함 |
| `BASIC_CALCULATOR.md` | 기본 계산기의 State/Intent 정의, UseCase TDD 방식, ViewModel 설계 |
| `EXCHANGE_RATE_CALCULATOR.md` | 환율 계산기의 Clean Architecture 계층별 구현, Firestore/Firebase Functions 연동, 데이터 흐름 |
| `CARD_LIST_REFACTOR.md` | 메인 화면 카드 리스트를 데이터 기반으로 리팩터링하는 설계 (`CalcModeEntry` 모델 도입) |
| `TERMINAL_COMMAND.md` | `flutter run`, `flutter test` 등 개발 중 자주 사용하는 터미널 명령어 모음 |

#### `docs/dev/firebase/` — Firebase 백엔드 문서

| 파일 | 설명 |
|------|------|
| `FIREBASE_GUIDE.md` | Node.js 설정, Firebase CLI 설치, 프로젝트 초기화, 에뮬레이터 실행, 배포 절차 단계별 가이드 |
| `FIREBASE_EXCHANGE_RATE_BACKEND.md` | 환율 캐싱 아키텍처 설계. Open Exchange Rates API 연동, Cloud Scheduler 트리거, Firestore Double-Check Locking 트랜잭션 설계 |

---

### `docs/prompts/` — 질문/답변 지식 베이스

개발 중 발생한 의사결정, 기술 선택 이유, 아키텍처 논의를 Q&A 형식으로 축적.

| 파일 | 설명 |
|------|------|
| `PROPMTS.md` | 전체 Q&A 인덱스. `/qa` 명령어의 진입점. 각 질문의 ID, 제목, 답변 상태 관리 |
| `answers/Q0001.md ~ Q0017.md` | 개별 질문에 대한 상세 답변 문서 (현재 Q0001~Q0017 답변 완료) |

---

## 문서 간 관계도

```
CLAUDE.md
  └─ 세션 시작 시 → PROGRESS.md (필독)
  └─ 아키텍처 참고 → docs/architecture/ARCHITECTURE.md
  └─ 로드맵 참고 → docs/plans/ROADMAP.md

PROGRESS.md
  └─ 완료 항목 이동 → HISTORY.md
  └─ 구현 세부사항 → docs/dev/*.md

ROADMAP.md
  └─ UX 명세 → docs/specs/*.md
  └─ 구현 명세 → docs/dev/*.md

ARCHITECTURE.md
  └─ 모든 구현 명세(_IMPL_SPEC_TEMPLATE.md)의 기준

docs/specs/*.md  ──(UX→구현)──→  docs/dev/*.md

COMMIT_CONVENTION.md
  └─ 자동 적용 → .claude/commands/commit.md

PROPMTS.md
  └─ 답변 저장 → docs/prompts/answers/QXXXX.md
```

---

## 신규 기능 개발 시 문서 작성 순서

1. `docs/specs/{FEATURE}.md` — UX/기능 명세 작성 (`_SPEC_TEMPLATE.md` 참고)
2. `docs/dev/{FEATURE}.md` — 구현 명세 작성 (`_IMPL_SPEC_TEMPLATE.md` 참고)
3. `docs/plans/ROADMAP.md` — 해당 Phase에 작업 항목 추가
4. 구현 완료 후 `PROGRESS.md` 업데이트 → 완료 항목은 `HISTORY.md`로 이동
