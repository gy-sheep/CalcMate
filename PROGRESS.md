# CalcMate 개발 진행 상황

## 다음 작업

> **현재 브랜치**: `fix/ui-design-updates`
> **마지막 완료**: 메인·BMI 앱바 블러 애니메이션 개선 및 메인 UI 업데이트

### Phase 10: 다음 계산기
- [ ] 다음 Phase 계산기 선정 및 기획

> **대출 계산기** (Phase 13으로 이동): `docs/specs/LOAN_CALCULATOR.md` 기획 명세 작성 완료, UI 안 선택 및 구현은 추후 진행

### 리팩토링 (Phase 2 후속)
> 체크리스트: `docs/plans/REFACTORING_CHECKLIST.md`

---

## 완료 기능 현황

| Phase | 기능 | 테스트 | 구현 명세 |
|-------|------|--------|-----------|
| 0 | 기반 설정 (테마·DI·에셋·라우트) | — | — |
| 1 | 기본 계산기 (괄호·수식·뉴모피즘) | 116케이스 | `docs/dev/BASIC_CALCULATOR_IMPL.md` |
| 2 | 환율 계산기 (Firebase·Firestore) | — | — |
| 3 | 단위 변환기 (10개 카테고리) | 24케이스 | `docs/dev/UNIT_CONVERTER_IMPL.md` |
| 4 | 부가세 계산기 (영수증 UI) | 54케이스 | `docs/dev/VAT_CALCULATOR_IMPL.md` |
| 5 | 나이 계산기 (음력·띠·별자리) | 19케이스 | `docs/dev/AGE_CALCULATOR.md` |
| 6 | 날짜 계산기 (3모드·D-Day) | 28케이스 | `docs/dev/DATE_CALCULATOR_IMPL.md` |
| — | 위젯 분리 리팩토링 (6개 계산기) | — | 각 구현 명세 참고 |
| — | Container Transform 전환 애니메이션 | — | — |
| — | AppBar 리팩토링 (Scaffold.appBar 통일, 아이콘 제거) | — | `docs/architecture/ARCHITECTURE.md` |
| — | 부가세 계산기 모드 전환 UI 체크박스 → 인라인 토글 교체 + 결과 카드 UX 개선 | — | `docs/dev/VAT_CALCULATOR_IMPL.md` |
| — | 광고 배너 플레이스홀더 (6개 화면, AppConfig.isPremium 플래그) | — | — |
| — | 다국어 날짜 피커 (flutter_localizations) | — | — |
| — | 메인 화면 순서 편집 (드래그 정렬·설정 드롭다운·순서 저장) | — | — |
| 7 | 더치페이 계산기 (균등 분배·개별 계산·공유) | 2파일 | `docs/dev/DUTCH_PAY_CALCULATOR_IMPL.md` |
| 8 | 할인 계산기 (ViewModel·UseCase·State·테스트 21케이스) | 21케이스 | `docs/dev/DISCOUNT_CALCULATOR.md` |
| 9 | BMI 계산기 (아크 게이지·슬라이더·locale 자동 적용·ViewModel·UseCase) | 27케이스 | `docs/dev/BMI_CALCULATOR_IMPL.md` |
| — | 공통 모듈화: ScrollFadeView·AppAnimatedTabBar·showAppToast + 스크롤 페이드 전체 적용 | — | `docs/plans/REFACTORING_CHECKLIST.md` |
| — | 디자인 일관성 리팩토링 (토큰 전체 적용·공통 위젯·디자인 문서) | — | `docs/design/` |
| — | 스플래시 화면 (네이티브 배경 + Flutter shimmer 애니메이션) | — | — |
| — | 메인·BMI 앱바 블러 애니메이션 개선, CalcModeCard 토큰 적용, 메인 앱바 좌측 정렬·more_vert | — | — |

> 상세 작업 이력: `HISTORY.md`

---

## 프로젝트 구조

[`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md) 참고

**구현 패턴 템플릿**: `~/.claude/projects/.../memory/patterns.md`
