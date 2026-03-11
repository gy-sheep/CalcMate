# CalcMate 개발 진행 상황

## 다음 작업

> **현재 브랜치**: `dev`
> **마지막 완료**: 리팩토링 R-01/R-06/R-10 완료 및 전반 코드 정리

### Phase 12-1: l10n 전환 (다음 세션 즉시 시작)

> **작업 계획서**: `docs/plans/L10N_PLAN.md`
> **Phase 1(인프라)부터 순서대로 진행** — 계획서의 Phase/커밋 전략 그대로 따를 것

- [ ] Phase 1: 인프라 구축 (l10n.yaml, arb, Riverpod locale, 설정 연동)
- [ ] Phase 2: Domain 계층 하드코딩 → 상수/enum 전환
- [ ] Phase 3: 데이터성 문자열 분리 (단위/통화/카테고리)
- [ ] Phase 4: 통화 포맷터 도입
- [ ] Phase 5: 화면별 문자열 전환 (5-1~5-4)
- [ ] Phase 6: UI 레이아웃 대응
- [ ] Phase 7: 테스트 및 마무리

### Phase 11: 설정 화면 — 나머지 기능 연동
- [ ] 환율 기준 통화 바텀시트 + SharedPreferences 연동
- [ ] BMI 단위 바텀시트 + SharedPreferences 연동

> 기획 명세: `docs/specs/SETTINGS.md`

### Phase 12: 출시 준비
- [x] 버전 정보 `package_info_plus` 동적 표시
- [ ] 언어 설정 실제 l10n 전환 (현재 UI만 구현)
- [ ] 개인정보 처리방침 URL 확정 + `url_launcher` 연동
- [ ] 공통 팝업, 공통 토스트
- [ ] 에러 메시지 config
- [ ] Google Analytics (Firebase Analytics) 연동
- [ ] 인앱 결제 모듈 연동 (유료 버전 / 광고 제거)
- [ ] 개인정보 처리방침 작성 + URL 확정 + `url_launcher` 연동

### Phase 10: 기타
- [ ] 실수령액 계산기 Firestore 세율 연동 (간이세액표 실데이터)

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
| 11 | 설정 화면 (다크 모드·계산기 관리·메인 카드 스와이프 숨기기) | — | `docs/specs/SETTINGS.md` |
| — | 설정 UI 전체 구현 (카드 레이아웃·언어·앱 정보·라이선스·블러 오버레이·iOS Switch) | — | `docs/specs/SETTINGS.md` |
| 10 | 실수령액 계산기 UI 구현 (입력 카드·슬라이더 통합·결과 카드·공제 내역·부양가족 바) | — | `docs/design/SALARY_CALCULATOR.md` |
| 10 | 실수령액 계산기 로직 구현 (TaxRates·SalaryCalculatorState·CalculateSalaryUseCase·ViewModel·위젯 분리) | 19케이스 | `docs/dev/SALARY_CALCULATOR_IMPL.md` |
| — | Cm* 컴포넌트 토큰 시스템 추가 (CmTab·CmInputCard·CmResultCard·CmListCard·CmRoundButton·CmSlider 등) | — | `docs/conventions/UI_TOKEN_CONVENTION.md` |
| — | 단위 변환기 단위 전환 정밀도 개선 (rawConvertedValues) | — | — |
| — | 구 AppTokens 클래스 제거 및 전체 코드베이스를 Cm* 신규 토큰·전역 상수로 전면 교체 | — | — |
| — | Cm* 토큰 기준 설계 문서 전체 현행화 (ARCHITECTURE·UI_TOKEN_CONVENTION·4개 design docs) | — | — |
| — | 부가세 계산기 합계금액 디폴트·토글 순서 수정 | — | — |
| — | 날짜 계산기 UX 개선 (CmTab 칩·이후/이전 토글·CmInputCard 숫자·카드 레이아웃·오늘 표시) | — | `docs/dev/DATE_CALCULATOR_IMPL.md` |
| — | DateKeypad 제거 → showNumberKeypad 공통 모달 전환 | — | — |
| — | 숫자 키패드 공통 모듈화: KeypadColors + showNumberKeypad (core/widgets) | — | — |
| — | 단위 변환기 왕복 변환 정밀도 개선 및 테스트 추가 | — | — |
| — | 더치페이 UI 개선 (테마 심화·그라데이션 테두리·탭 레이블·인원 프리셋 칩·정산 단위 인라인 칩·각출 단일 스크롤·바 차트 결과) | — | — |
| — | 더치페이 각출 UX 개선 2차 (sticky compact 바·스크롤 페이드·금액 콤마·탭 전환 상태 유지·바텀시트 테마·차트 레이아웃 등) | — | — |
| — | 전월세·대출·취득세 계산기 삭제 (10개 계산기로 축소) | — | — |
| — | 실수령액 계산기 뉴스프린트 테마 적용 (accent black 통일) | — | — |
| — | 할인 계산기 UI 개선 (Peach Bunny 테마·CmGradientBorderCard 그라데이션 테두리·입체 그림자) | — | — |
| — | 전 계산기 키패드 백스페이스 롱프레스 → AC 통일 (7개 키패드 + viewmodel 2건 보강) | — | — |
| — | 스플래시 배경색 앱 아이콘 일치 보정 (#0F0F19), 메인 앱바 다크모드 glow, 설정 UI 개선 | — | — |
| — | 버전 정보 package_info_plus 동적 표시 | — | — |
| — | DigitLimitPolicy 공용 클래스 도입 (기본·환율·부가세·단위변환 4개 ViewModel) | — | — |
| — | 대형 파일 분리: discount_calculator_screen (6파일), individual_split_view (6파일) | — | — |
| — | 미사용 DateKeypad 삭제, 키패드 높이 Medium 통일 (기본 계산기만 Large) | — | — |
| — | 리팩토링 R-01 색상 네이밍 통일 (9개 *_colors.dart, Bg1/KeyNumber 패턴) | — | — |
| — | 리팩토링 R-10 Duration 7종·BorderRadius 토큰화 (34개 교체, 18파일) | — | — |

> 상세 작업 이력: `HISTORY.md`

---

## 프로젝트 구조

[`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md) 참고

**구현 패턴 템플릿**: `~/.claude/projects/.../memory/patterns.md`
