# CalcMate 개발 진행 상황

## 다음 작업

> **현재 브랜치**: `feat/salary-calculator`
> **마지막 완료**: 실수령액 계산기 로직 구현 및 Clean Architecture 전환

### Phase 14: 설정 화면 — 나머지 기능 연동
- [ ] 언어 설정 실제 l10n 전환 (현재 UI만 구현)
- [ ] 환율 기준 통화 바텀시트 + SharedPreferences 연동
- [ ] BMI 단위 바텀시트 + SharedPreferences 연동
- [ ] 버전 정보 `package_info_plus` 동적 표시
- [ ] 개인정보 처리방침 URL 확정 + `url_launcher` 연동

> 기획 명세: `docs/specs/SETTINGS.md`

### Phase 10: 다음 계산기
- [ ] 다음 Phase 계산기 선정 및 기획
- [ ] 실수령액 계산기 Firestore 세율 연동 (간이세액표 실데이터)

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
| — | 메인·BMI 앱바 블러+그라디언트 오버레이, Pretendard 폰트, textStyleCardTitle 분리, AppBar 타이틀 전역 폰트 설정 | — | — |
| — | 메인 앱바 투명화·타이틀 스타일·Shadow, textStyleAppBarTitle 토큰 강화, 전체 화면 titleSpacing: 0 통일 | — | — |
| — | 스플래시 화면 디자인 개선 (아이콘 shimmer·AppTokens 폰트·슬로건 슬라이드 애니메이션) | — | — |
| — | 스플래시 shimmer 개선 (왕복 애니메이션·속도·곡선 조정) | — | — |
| — | 스크롤 상단 페이드 그라디언트 추가 (ScrollFadeView·환율·단위변환기) | — | — |
| — | 탭바(더치페이·날짜) UX 개선 (높이 48·탭 구분선·비활성 opacity·폰트 굵기) | — | — |
| — | 전체 화면 AppBar.systemOverlayStyle 일괄 적용 (배경색 기준 light/dark 분기) | — | — |
| 14 | 설정 화면 (다크 모드·계산기 관리·메인 카드 스와이프 숨기기) | — | `docs/specs/SETTINGS.md` |
| — | 설정 UI 전체 구현 (카드 레이아웃·언어·앱 정보·라이선스·블러 오버레이·iOS Switch) | — | `docs/specs/SETTINGS.md` |
| 10 | 실수령액 계산기 UI 구현 (입력 카드·슬라이더 통합·결과 카드·공제 내역·부양가족 바) | — | `docs/design/SALARY_CALCULATOR.md` |
| 10 | 실수령액 계산기 로직 구현 (TaxRates·SalaryCalculatorState·CalculateSalaryUseCase·ViewModel·위젯 분리) | 19케이스 | `docs/dev/SALARY_CALCULATOR_IMPL.md` |
| — | Cm* 컴포넌트 토큰 시스템 추가 (CmTab·CmInputCard·CmResultCard·CmListCard·CmRoundButton·CmSlider 등) | — | `docs/conventions/UI_TOKEN_CONVENTION.md` |
| — | 단위 변환기 단위 전환 정밀도 개선 (rawConvertedValues) | — | — |
| — | 구 AppTokens 클래스 제거 및 전체 코드베이스를 Cm* 신규 토큰·전역 상수로 전면 교체 | — | — |

> 상세 작업 이력: `HISTORY.md`

---

## 프로젝트 구조

[`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md) 참고

**구현 패턴 템플릿**: `~/.claude/projects/.../memory/patterns.md`
