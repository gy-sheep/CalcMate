# CalcMate 개발 히스토리

---

## 2026-03-11 — 더치페이 각출 UX 개선 2차

### 완료 항목

- **sticky compact 바**: 배경 불투명화(kDutchBg1), 전체 너비 확장, 바텀 구분선 추가
- **스크롤 페이드**: 상하 페이드(GlobalKey로 participants 바 높이 측정 후 sticky 감지), compact 바 좌우 동적 페이드
- **탭 전환 상태 유지**: `tabChanged` 핸들러에서 서브 상태 초기화 제거
- **참여자 칩 동작 수정**: 강조 중 탭 시 필터 해제 (이름 변경 팝업 대신)
- **금액 입력 콤마 포맷**: `FilteringTextInputFormatter` + `_fmtAmt()` 동기화
- **바텀시트 테마 통일**: 배경 kDutchBg1, 입력창 kDutchBg2, 삭제 버튼 kDutchAccent 계열
- **바 차트 레이아웃**: 이름 36→52px, 금액 72→96px + softWrap:false
- **편집 모드 칩**: 내부 X 아이콘 제거 (뱃지로 대체)
- **빈 상태 텍스트 제거**: "아직 메뉴가 없어요" 및 설명 문구 삭제
- **부가세 세율 참고 시트**: 타이틀 좌측 정렬
- **공유 시트**: CalcMate 텍스트 18px 확대, 더치페이 텍스트 제거
- **힌트 칩**: 배경·테두리 제거, 설명 텍스트 스타일로 변경, 칩 간격 확대

---

## 2026-03-10 — 날짜 계산기 UX 개선·키패드 공통 모듈화 및 문서 현행화

### 완료 항목

- **날짜 계산기 UX 개선**
  - 단위 버튼(일/주/개월/년): CmTab 칩 스타일 + AnimatedContainer 전환
  - 이후/이전 텍스트 토글 + 숫자·단위 CmInputCard 토큰 우측 정렬 표시
  - 날짜 계산 카드 영역을 CmInputCard 토큰으로 카드 형태로 감싸기
  - 기간 계산: 시작일 포함 레이아웃 개선, 서브 결과 단일 Row
  - D-Day·기간·날짜 계산 공통으로 오늘 날짜 (오늘) 표시 통일
  - DateKeypad 제거 → 숫자 표시 영역 탭 시 showNumberKeypad 모달 호출
- **숫자 키패드 공통 모듈화**
  - `lib/core/widgets/number_keypad.dart`: KeypadColors + showNumberKeypad
  - `showSalaryKeypad` thin wrapper로 리팩토링
  - 모달 열릴 때 빈 입력으로 시작 (실수령액·날짜 계산기 공통 적용)
- **부가세 계산기**: 합계금액 디폴트 변경, 합계금액 | 공급가액 토글 순서 수정
- **단위 변환기**: 왕복 변환 정밀도 개선 (역수 활용), formatScientific·rawFromDouble 정밀도 향상, 테스트 추가
- **Cm* 토큰 설계 문서 전체 현행화**: ARCHITECTURE.md, UI_TOKEN_CONVENTION.md, BASIC_CALCULATOR.md, EXCHANGE_RATE.md, SALARY_CALCULATOR.md, UNIT_CONVERTER.md

---

## 2026-03-10 — 실수령액 계산기 로직 구현 및 Clean Architecture 전환

### 완료 항목

**Domain 계층**
- `tax_rates.dart` — TaxRates Freezed 모델 + `kFallbackTaxRates` 상수 (2024년 기준)
- `net_pay_state.dart` — SalaryMode/AdjustUnit enum, NetPayState Freezed, NetPayStateX computed getters
- `calculate_net_pay_usecase.dart` — 4대보험 + 소득세(간이세액표 산출 공식 10단계) + 지방소득세 계산
  - 소득세: 소득세법 시행령 별표2 기반 공식 (근로소득공제 → 과세표준 → 누진세율 → 세액공제)
  - 간이세액표 2D 배열 대신 산출 공식 사용 (Firestore 연동 전 임시 방안)

**Presentation 계층**
- `net_pay_calculator_viewmodel.dart` — `AutoDisposeNotifier<NetPayState>` + sealed Intent 6종
  - salaryChanged, tabSwitched, directInput, unitChanged, adjust, dependentsChanged
- `net_pay_calculator_screen.dart` — StatefulWidget → ConsumerStatefulWidget 전환
- 위젯 6개 분리:
  - `widgets/salary_display.dart` — 급여 입력 표시 + 슬라이더 통합
  - `widgets/adjust_bar.dart` — [−] [단위▾] [+] 미세 조절 바
  - `widgets/result_card.dart` — 실수령액 결과 카드
  - `widgets/deduction_card.dart` — 공제 내역 6항목 리스트
  - `widgets/dependents_bar.dart` — 고정 하단 부양가족 조절기
  - `widgets/keypad_modal.dart` — 키패드 바텀시트

**테스트**
- `calculate_net_pay_usecase_test.dart` — 19케이스
  - 국민연금 3, 건강보험 2, 장기요양 1, 고용보험 1, 소득세 6, 지방소득세 1, 통합검증 4, 엣지케이스 1

**단위 변환기 정밀도 개선**
- `unit_converter_state.dart` — `rawConvertedValues` 필드 추가
- `number_formatter.dart` — `formatUnitResult` 임계값 1e-4→1e-12, 소수점 8→12자리
- `unit_converter_viewmodel.dart` — 단위 전환 시 raw double 값 사용 (정밀도 손실 방지)

**문서**
- `docs/dev/SALARY_CALCULATOR_IMPL.md` — 실제 구현 반영 (산출 공식, AutoDisposeNotifier, 위젯 목록)

---

## 2026-03-09 — 설정 화면 UI 전체 구현 및 블러 오버레이 모듈화

### 완료 항목

**설정 화면 (Phase 14 — 전체 UI)**
- `SettingsViewModel` + Freezed 상태, `SharedPreferences` 연동 (`theme_mode` 키)
- 다크 모드: 바텀시트 라디오 선택 → `MaterialApp.themeMode` 즉시 반영
- `CalcmateApp` → `ConsumerWidget` 변환, `settingsViewModelProvider` 연동
- 계산기 관리 서브 화면: `CalculatorManagementScreen` (Switch 토글, 최소 1개 보호)
- Toss 앱 스타일 카드 기반 레이아웃으로 전면 재설계
  - 배경: 라이트 `#F2F2F7`, 다크 `Colors.black`
  - 카드: 라이트 `Colors.white`, 다크 `#1C1C1E`, `radiusCard(16)`
  - `_SectionCard` (선택적 타이틀) + `_SettingsTile` (선택적 값) 위젯
- 3개 섹션 카드 구성:
  - 첫 번째 (타이틀 없음): 언어 (한국어/English/中文/日本語 바텀시트, UI only), 화면 테마
  - 일반: 계산기 관리, 환율 기준 통화 (UI only), BMI 단위 (UI only)
  - 앱 정보: 버전 정보 (하드코딩 1.0.0), 오픈소스 라이선스, 개인정보 처리방침 (UI only)
- iOS 스타일 Switch 색상: `#34C759` 녹색, `trackOutlineColor: transparent`

**커스텀 오픈소스 라이선스 화면**
- `OpenSourceLicensesScreen`: `LicenseRegistry.licenses`로 패키지별 라이선스 수집, 알파벳 정렬
- `_LicenseDetailScreen`: 패키지별 전체 라이선스 텍스트 표시
- `paragraph.indent.clamp(0, 10)` — 음수 indent 크래시 방지 (abseil-cpp)

**BlurStatusBarOverlay 공통 위젯**
- `lib/presentation/widgets/blur_status_bar_overlay.dart` 신규 생성
- `BackdropFilter(sigma: 20)` + `ShaderMask` + `AnimatedOpacity(250ms)`
- `isVisible` + `backgroundColor` 파라미터
- 5개 화면 적용: 설정, 계산기 관리, 라이선스 목록, 라이선스 상세, BMI 계산기
- BMI 계산기: 인라인 블러 코드 ~40줄 → `BlurStatusBarOverlay` 1줄로 교체

**메인 화면 카드 스와이프 숨기기**
- `_SwipeToHideCard` 위젯: 좌측 스와이프 → 원형 숨기기 버튼 노출
- 버튼 UX: fade+scale 등장 → pill 스트레치 → 아이콘 위치 전환(중앙→좌측)
- 카드 효과: 흑백 필터(ColorFiltered), 드래그 감쇠(0.85, snap 이후 1:1)
- 햅틱: dismiss 커밋 지점(50%)에서 mediumImpact
- 자동 닫힘: 스크롤 시작·상세 페이지 진입 시 ValueNotifier로 부드럽게 복귀
- `MainScreenViewModel`: `toggleVisibility` intent, `_saveHidden`, `_loadSavedData`

**문서**
- `docs/specs/SETTINGS.md` — 카드 레이아웃·섹션 구조·커스텀 라이선스·블러 오버레이 반영
- `docs/specs/MAIN_SCREEN.md` 신규 작성 (스와이프 숨기기 포함)

---

## 2026-03-08 — 부가세 계산기 모드 토글 및 결과 카드 UX 개선

### 완료 항목

**체크박스 → 인라인 토글 교체**
- `VatModeToggle` 위젯 신규 추가 (`receipt_card.dart`)
- "부가세 별도" 체크박스를 `공급가액 | 합계금액` 인라인 토글로 교체
- 터치 영역 개선 (기존 20×20px → Row 전체 영역)

**결과 카드 구조 개선**
- 공급가액 모드: 공급가액(입력값) → 부가세 → **합계(강조)**
- 합계금액 모드: 합계(입력값) → 부가세 → **공급가액(강조)**
- 항상 "계산된 값"이 강조 행에 표시되도록 변경

**문서**
- `docs/specs/VAT_CALCULATOR.md` 전면 재작성
- `docs/design/VAT_CALCULATOR.md` 모드별 레이아웃 반영
- `docs/dev/VAT_CALCULATOR_IMPL.md` 신규 작성

---

## 2026-03-08 — 메인 화면 스크롤 성능 개선 및 카드 shadow 조정

### 완료 항목

**스크롤 성능 개선**
- `CalcModeCard._buildImage` — `cacheHeight` 추가 (devicePixelRatio 기반 이미지 디코딩 최적화)
- `CalcModeCard` — `Clip.antiAlias` → `Clip.hardEdge` 변경
- 각 카드 항목에 `RepaintBoundary` 추가
- `initState`에서 `precacheImage`로 배경 이미지 13개 사전 로딩

**카드 shadow 조정**
- `OpenContainer.closedElevation` 제거 (0으로 변경)
- `Card.elevation` 4 + `shadowColor: Colors.black`으로 통일

---

## 2026-03-08 — BMI 계산기 ViewModel·UseCase·State 구현 및 위젯 분리

### 완료 항목

**Clean Architecture 전환**
- `BmiCalculateUseCase` — BMI 계산·범주 판정(글로벌 4범주/아시아 5범주)·건강 체중 역산·locale 헬퍼
- `BmiCalculatorState` (Freezed) — heightCm, weightKg, isMetric, standard
- `BmiCalculatorViewModel` — sealed Intent + SharedPreferences 단위 저장/복원
- Screen: `StatefulWidget` → `ConsumerStatefulWidget` 전환 (886줄 → ~170줄)

**위젯 분리 (4개)**
- `widgets/bmi_gauge.dart` — 아크 게이지 + GaugePainter
- `widgets/bmi_input_slider.dart` — 슬라이더 카드
- `widgets/bmi_healthy_weight_card.dart` — 건강 체중 범위 카드
- `widgets/bmi_category_grid.dart` — 범주 안내 그리드

**테스트**
- `test/domain/usecases/bmi_calculate_usecase_test.dart` — 27케이스

**문서**
- `docs/dev/BMI_CALCULATOR_IMPL.md` — 구현 명세 신규 작성
- `docs/specs/BMI_CALCULATOR.md` — 데이터 모델 섹션 실제 구현 반영

---

## 2026-03-08 — BMI 계산기 UI 구현 및 디자인 토큰 정비 (Phase 9)

### 완료 항목

**BMI 계산기 (`lib/presentation/bmi_calculator/bmi_calculator_screen.dart`)**
- 반원 아크 게이지 (CustomPaint) — 컬러 구간·바늘·easeOutCubic 애니메이션
- 키·몸무게 슬라이더 카드 — 값 버튼 탭 시 직접 입력 AlertDialog
- 건강 체중 범위 카드 — 현재 키 기준 정상 체중 역산 표시
- BMI 범주 안내 그리드 — 4셀 1행(글로벌) / 5셀 3+2행(아시아태평양)
- WHO 글로벌/아시아태평양 기준 locale 자동 적용 (15개국 아시아태평양)
- 미터법·야드파운드법 단위 토글 (SharedPreferences 저장)
- 스크롤 연동 AppBar 블러 처리 (BackdropFilter + AnimatedContainer)

**AppTokens 토큰 6종 추가 (`lib/core/theme/app_design_tokens.dart`)**
- `textStyleResult52` — BMI 수치 표시 (52sp / w300)
- `heightSliderTrack` — 슬라이더 트랙 높이 (4)
- `radiusSliderThumb` — 슬라이더 thumb 반지름 (10)
- `sizeIconMedium` — 아이콘 중형 (22)
- `sizeIconContainer` — 아이콘 컨테이너 크기 (44)
- `radiusIconContainer` — 아이콘 컨테이너 borderRadius (10)

**CalcModeCard 토큰 적용 (`lib/presentation/widgets/calc_mode_card.dart`)**
- 아이콘 컨테이너 `44×44` / `borderRadius: 10` → `sizeIconContainer` / `radiusIconContainer`

**문서**
- `docs/specs/BMI_CALCULATOR.md` — 기획 명세 신규 작성
- `docs/design/BMI_CALCULATOR.md` — 화면 디자인 문서 신규 작성

---

## 2026-03-08 — 할인 계산기 Clean Architecture 전환 (Phase 8 완료)

### 완료 항목

**할인 계산기 아키텍처 전환**
- `DiscountCalculatorState` (Freezed) — `ActiveField` enum 포함
- `CalculateDiscountUseCase` — 순수 계산 로직 분리, `formatPrice` static 헬퍼
- `DiscountCalculatorViewModel` — sealed Intent 패턴 (keyPressed·chipSelected·fieldTapped·toggleExtraDiscount)
- `DiscountCalculatorScreen` — `StatefulWidget` 인라인 로직 → `ConsumerWidget` 전환

**테스트**
- `test/domain/usecases/calculate_discount_usecase_test.dart` — 21케이스
  (hasResult / 기본 할인 / 중첩 할인 복리 / 엣지 케이스 / formatPrice)

**문서**
- `docs/dev/DISCOUNT_CALCULATOR.md` — 구현 명세 신규 작성
- `docs/specs/DISCOUNT_CALCULATOR.md` — 키패드 소수점·AC 오기재 수정
- `docs/design/DISCOUNT_CALCULATOR.md` — 키패드 소수점 설명 수정

---

## 2026-03-07 — 디자인 일관성 리팩토링

### 완료 항목

**AppTokens 토큰 체계 확장 (`lib/core/theme/app_design_tokens.dart`)**
- Semantic TextStyle 토큰 도입: `textStyleSectionTitle`(13), `textStyleBody`(14), `textStyleHint`(14), `textStyleCaption`(12), `textStyleValue`(16), `textStyleChip`(14), `textStyleLabelMedium`(12), `textStyleLabelSmall`(10), `textStyleSheetTitle`(18), `textStyleAppBarTitle`(18)
- Result 크기별 토큰: `textStyleResult18`~`textStyleResult56` (8단계)
- 키패드 토큰: `textStyleKeypadNumber`(22), `textStyleKeypadOperator`(28)
- Icon Size 토큰: `sizeIconXSmall`(16), `sizeIconSmall`(20), `sizeIconStep`(18), `sizeIconDropdown`(18)

**8개 계산기 전체 토큰 적용**
- 기본·환율·단위·부가세·나이·날짜·더치페이·할인 계산기
- 모든 인라인 `fontSize`, `fontWeight`, icon `size` → AppTokens 상수로 교체

**공통 위젯 추출**
- `app_text_field.dart` — AppTextField (body/hint 스타일 자동 적용)
- `app_input_underline.dart` — AppInputUnderline (입력 밑줄 공통화)

**더치페이 UX 개선**
- 개별 계산 인원 추가 시 자동 스크롤 (신규 인원이 보이도록)
- 최대 10명 도달 시 `showAppToast` 안내
- 편집/완료 모드 전환 시 스크롤 처음으로 이동

**디자인 문서 (`docs/design/`)**
- 8개 계산기 디자인 문서 + 템플릿 신규 작성
- 토큰명·크기·용도를 표로 정리

**스펙 문서 정리**
- 8개 스펙 + 템플릿에서 UI 요소 스타일 섹션 제거 (디자인 문서와 중복)
- `> UI 스타일: 디자인 문서 참조` 한 줄로 대체

**가이드 문서 업데이트**
- `CLAUDE.md` — UI 구현 시 AppTokens 토큰 사용 원칙 추가
- `docs/architecture/ARCHITECTURE.md` — 디자인 토큰 섹션 및 사용 패턴 추가

### 커밋
- (이번 커밋)

---

## 2026-03-06 — 더치페이 계산기 구현

### 완료 항목

**기획 명세 (`docs/specs/DUTCH_PAY_CALCULATOR.md`)**
- 균등 분배 / 개별 계산 2탭 구조 기획

**구현 명세 (`docs/dev/DUTCH_PAY_CALCULATOR_IMPL.md`)**
- 파일 구조, 클래스 설계, 구현 순서 정의

**Domain**
- `dutch_pay_state.dart` — Freezed 상태 모델 (DutchPayState, EqualSplitState, IndividualSplitState, DutchParticipant, DutchItem, RemUnit)
- `dutch_pay_equal_split_usecase.dart` — 균등 분배 계산 (나머지 단위, 팁 지원)
- `dutch_pay_individual_split_usecase.dart` — 개별 계산 (항목별 담당자 배분)

**Presentation**
- `dutch_pay_screen.dart` — 메인 화면 (탭 전환)
- `dutch_pay_viewmodel.dart` — Intent 기반 ViewModel (균등/개별 전체 처리)
- `dutch_pay_tab_bar.dart` — elastic stretch 탭바
- `equal_split_view.dart` — 균등 분배 UI (키패드, 인원, 나머지 단위, 팁)
- `individual_split_view.dart` — 개별 계산 UI (바텀시트 메뉴 입력, 참여자 관리)
- `participant_chip.dart` — 참여자 칩 위젯 (선택/삭제/아이콘)
- `share_sheet.dart` — 영수증 스타일 공유 (share_plus)
- `dutch_pay_keypad.dart` — 커스텀 키패드
- `dutch_pay_colors.dart` — 테마 색상 상수

**주요 UX 결정**
- 개별 계산 메뉴 입력을 바텀시트로 분리 (키보드 overflow 해결)
- 참여자 탭 → 이름 변경 다이얼로그 (취소/다음/확인)
- 편집 모드 칩 탭 → 삭제 확인
- iOS share_plus sharePositionOrigin 설정

**테스트**
- `dutch_pay_equal_split_usecase_test.dart`
- `dutch_pay_individual_split_usecase_test.dart`

---

## 2026-03-05 — 대출 계산기 UI 프로토타입 4종

### 완료 항목

**기획 명세 (`docs/specs/LOAN_CALCULATOR.md`)**
- 4가지 UI 안(A~D) 화면 구성 및 기획 의도 정의

**UI 프로토타입 (`lib/presentation/loan_calculator/`)**
- 안 A: 표준 입력형 — 조건 입력 후 결과 확인 (전통적 흐름)
- 안 B: 결과 우선형 — 진입 즉시 결과 노출, 슬라이더로 조건 탐색
- 안 C: 타임라인형 — 연도별 누적 원금/이자 스택 바 차트 시각화
- 안 D: 목표 역산형 — 월 납입 예산 입력 → 최대 대출 가능금액 역산
- 허브 화면(`loan_prototype_hub.dart`)으로 4가지 안 선택 진입
- 공유 계산 헬퍼 및 공유 위젯 분리 (`_loan_calc_helper.dart`, `_loan_shared_widgets.dart`)
- 원리금균등·원금균등·만기일시 3가지 상환 방식 실시간 계산 지원

**메인 화면 연결**
- `main_screen.dart` — `loan_calculator` 케이스에 허브 화면 연결

---

## 2026-03-04 — Container Transform 화면 전환 애니메이션

### 완료 항목

**화면 전환 방식 교체**
- Hero + CalcPageRoute → OpenContainer (animations 패키지) Container Transform으로 전환
- 카드가 상세 화면으로 확장되는 전환 효과 구현 (전체 6개 화면 적용)
- EdgeSwipeBack 위젯 신규 생성 (iOS 엣지 스와이프 뒤로가기 지원)
- 환율 계산기 API 호출을 전환 애니메이션 완료 후(400ms)로 지연하여 버벅임 방지

**Hero 관련 코드 정리**
- CalcModeCard, CalculatorAppBar, CurrencyAppBar, UnitAppBar, VatAppBar에서 Hero 위젯 제거
- 각 화면의 useHero 파라미터 제거

**문서 업데이트**
- NAMING_CONVENTION.md — Hero 태그 섹션 제거
- MAIN_SCREEN_IMPL.md — Hero/CalcPageRoute 언급을 OpenContainer/EdgeSwipeBack으로 갱신

---

## 2026-03-04 — 전 화면 위젯 분리 리팩토링

### 완료 항목

**위젯 분리** (ARCHITECTURE.md 위젯 파일 분리 규칙 적용)
- 6개 계산기 화면의 위젯을 `widgets/` 폴더로 분리, Screen 파일은 레이아웃만 담당
- 각 화면별 색상 상수를 `{feature}_colors.dart`로 추출

| 계산기 | 분리된 위젯 수 | 색상 파일 |
|--------|---------------|-----------|
| 기본 계산기 | 3개 (display_panel, button_pad, calculator_app_bar) | basic_calculator_colors.dart |
| 환율 계산기 | 5개 (currency_app_bar, amount_display, currency_code_button, currency_number_pad, currency_picker_sheet) | currency_calculator_colors.dart |
| 단위 변환기 | 4개 (unit_app_bar, category_tabs, unit_list, unit_number_pad) | unit_converter_colors.dart |
| 부가세 계산기 | 4개 (vat_app_bar, vat_number_pad, receipt_card, tax_rate_info_sheet) | vat_calculator_colors.dart |
| 나이 계산기 | 12개 (age_card, zodiac_card, constellation_card 등) | age_calculator_colors.dart |
| 날짜 계산기 | 7개 (date_tab_bar, period_mode_view, dday_mode_view 등) | date_calculator_colors.dart |

**단위 변환기 카테고리 탭 애니메이션 개선**
- 탄성 스트레치: 좌/우 엣지 별도 커브 (easeInCubic / easeOutCubic)
- 배경 칩 글로우 (boxShadow + border) 추가
- 텍스트 스케일 (활성 +8%) 추가
- 날짜 계산기 DateTabBar와 동일한 애니메이션 효과 통일

**문서 업데이트**
- `CLAUDE.md` — 위젯 파일 분리 개발 원칙 추가
- `docs/architecture/ARCHITECTURE.md` — 위젯 파일 분리 규칙 섹션 추가
- 5개 구현 명세 — 위젯 파일 목록 및 구조 반영

### 커밋
- (이번 커밋)

---

## 2026-03-04 — 디자인 토큰 도입 및 전 화면 스타일 통일

### 완료 항목

**디자인 토큰**
- `core/theme/app_design_tokens.dart` — AppTokens abstract 클래스 신규 생성
  - Typography: fontSizeAppBarTitle(18), weightAppBarTitle(w600), fontSizeLabel(12), fontSizeBody(14), fontSizeValue(16)
  - Shape: radiusCard(16), radiusBottomSheet(20), radiusChip(20), radiusTag(6), radiusAppBarIcon(7), radiusInput(12)
  - Spacing: paddingScreenH(16), paddingCardInner(16), paddingAppBarH(16), paddingAppBarV(12)
  - Component: sizeAppBarIcon(28), sizeAppBarIconInner(15), heightButtonLarge(68), heightButtonMedium(56), heightSegment(36)

**공통 위젯**
- `presentation/widgets/app_segment_control.dart` — AppSegmentControl<T> 신규 생성
  - trackColor, thumbColor, activeTextColor, inactiveTextColor 파라미터로 테마 주입
  - 부가세 계산기 CupertinoSlidingSegmentedControl 교체 + _CalendarSegment(나이 계산기) 교체

**스타일 통일**
- 나이 계산기 AppBar fontWeight w700 → AppTokens.weightAppBarTitle(w600) 통일
- 단위 변환기 list item borderRadius 12 → AppTokens.radiusCard(16) 통일
- 전 화면(기본·환율·단위·부가세·나이) AppBar 하드코딩 값 → AppTokens 상수 교체

---

## 2026-03-04 — 나이 계산기 음력 변환 및 UI 개선

### 완료 항목

**음력 변환 기능**
- `domain/usecases/lunar_converter.dart` — 음력↔양력 변환 래퍼 (신규)
  - `korean_lunar_utils` 패키지 캡슐화 (Domain 계층 직접 의존 방지)
  - `toSolar()`, `hasLeapMonth()`, `daysInMonth()` 정적 메서드
  - 범위 초과(1900 이전 / 2049 이후) 시 null 반환, 예외 처리
- `domain/models/age_calculator_state.dart` — `convertedSolarDate: DateTime?` 필드 추가
- `domain/usecases/age_calculate_usecase.dart` — kZodiacIcons, kConstellationIcons 정적 데이터 추가
- `pubspec.yaml` — `korean_lunar_utils: ^1.0.1` 의존성 추가

**Presentation 계층**
- `presentation/age_calculator/age_calculator_viewmodel.dart` — 음력 변환 로직 추가
  - 각 Intent 핸들러에서 음력 모드 시 `LunarConverter.toSolar()` 호출 → `convertedSolarDate` 갱신
  - `maxDaysForCurrentMonth()`: 음력 모드 시 `LunarConverter.daysInMonth()` 반환
  - `hasLeapMonth` getter: 현재 연·월 윤달 존재 여부
- `presentation/age_calculator/age_calculator_screen.dart` — UI 전면 개선
  - Frosted Glass 드럼롤 피커 (BackdropFilter blur + ShaderMask 그라데이션 페이드)
  - 세는 나이 Primary(56sp, 포인트 컬러), 만 나이 보조 행으로 이동
  - 태어난 요일 나이 카드 내 보조 행으로 통합 (별도 카드 제거)
  - 띠/별자리 카드: 이모지 → PNG 아이콘 가로 배치 (`Image.asset`, 36×36)
  - 음력 모드 `_LunarInfo`: 변환된 양력 날짜 표시 + 윤달 체크박스 (윤달 있는 달만)
  - 일 피커 `itemCount` → `vm.maxDaysForCurrentMonth()` 동적 처리

**아이콘 에셋**
- `assets/icons/zodiac/` — 12간지 PNG 아이콘 12개 추가
- `assets/icons/constellation/` — 별자리 PNG 아이콘 12개 추가
- `pubspec.yaml` — assets 경로 등록

**테스트**
- `test/domain/usecases/age_calculate_usecase_test.dart` — 단위 테스트 19케이스 (신규)
  - 만 나이(생일 전후/오늘), 세는 나이/연 나이, 윤년 2/29 생일(비윤년·윤년), 띠(설날 경계), 별자리(4케이스), 살아온 날, 다음 생일 D-day, 태어난 요일

**문서**
- `docs/dev/AGE_CALCULATOR.md` — 구현 명세 작성 (신규)
- `docs/specs/AGE_CALCULATOR.md` — UI 변경사항 현행화 (세는 나이 Primary, 아이콘, 음력 UI)
- `docs/prompts/answers/Q0022.md` — 디자인 통일성 점검 답변

### 커밋
- (이번 커밋)

---

## 2026-03-04 — 나이 계산기 스펙 문서 및 화면 구현

### 완료 항목

**기획 명세**
- `docs/specs/AGE_CALCULATOR.md` — 나이 계산기 기획 명세 작성
  - 양력/음력 입력 모드, 드럼롤 피커 UX, 결과 카드 그룹 설계
  - 설날 기준 띠 보정, 윤달 처리, 음력 변환 정책 정의
  - 기존 어두운 계통 테마와 차별화된 크림/복숭아 라이트 테마 선정

**Domain 계층**
- `core/constants/lunar_new_year_dates.dart` — 설날 양력 날짜 룩업 테이블 (1900~2050)
- `domain/models/age_calculator_state.dart` — AgeCalculatorState (Freezed), AgeCalendarType enum
- `domain/usecases/age_calculate_usecase.dart` — AgeCalculateUseCase
  - 만 나이, 세는 나이, 연 나이
  - 설날 기준 띠 보정 (출생일이 설날 이전이면 전년도 띠)
  - 별자리 (MMDD 기반 12궁도)
  - 살아온 날수, 태어난 요일, 다음 생일 D-day
  - kZodiacs, kConstellations, kWeekdays 정적 데이터

**Presentation 계층**
- `presentation/age_calculator/age_calculator_viewmodel.dart` — Notifier + sealed Intent 5종
  - calendarTypeChanged, yearChanged, monthChanged, dayChanged, leapMonthToggled
  - ageResult getter (연/월 변경 시 일 자동 클램프), refreshToday
- `presentation/age_calculator/age_calculator_screen.dart` — 화면 구현
  - 크림(#FFF8F0) → 복숭아(#FFE4CC) 라이트 그라디언트 테마, 웜 앰버(#D4845A) 포인트
  - 양력/음력 세그먼트 컨트롤
  - ListWheelScrollView 드럼롤 피커 (연·월·일), 복숭아색 선택 하이라이트 + 상하 페이드
  - 연/월 변경 시 일 컨트롤러 자동 동기화 (ref.listen + animateToItem)
  - 나이 카드 (만 나이 56sp 골드 강조), 다음 생일 D-day / 살아온 날 / 띠 / 별자리 / 요일 카드
  - AppLifecycleObserver 백그라운드 복귀 시 기준일 갱신
  - 음력 모드 UI 구조 포함, 변환 기능은 다음 업데이트 예정 안내
- `presentation/main/main_screen.dart` — age_calculator 라우팅 추가

---

## 2026-03-04 — 부가세 계산기 Clean Architecture 분리

### 완료 항목

**Domain 계층**
- `domain/usecases/vat_calculate_usecase.dart` — 부가세 별도/포함 계산 UseCase
  - `VatMode` enum (exclusive, inclusive), `VatResult` 클래스
  - 포함 모드: `(total * 100 / (100 + taxRate)).floorToDouble()` (부동소수점 정밀도 보장)
- `domain/models/vat_calculator_state.dart` — Freezed 불변 상태 (mode, inputTarget, input, isResult, taxRate, taxRateInput, toastMessage)
- `core/constants/default_tax_rates.dart` — 15개국 세율 매핑 + 로케일 기반 기본 세율 함수
- `domain/utils/number_formatter.dart` — `formatVatResult` 메서드 추가

**Presentation 계층**
- `presentation/vat_calculator/vat_calculator_viewmodel.dart` — Notifier + sealed Intent 3종 (keyTapped, modeChanged, taxRateTapped)
  - 계산 getters: `evaluatedInput`, `vatResult`, `formattedInput`, `displayRate`
  - Private 핸들러: `_handleAmountKey`, `_handleTaxRateKey`, `_checkDigitLimit`, `_applyTaxRate`
- `presentation/vat_calculator/vat_calculator_screen.dart` — StatefulWidget → ConsumerStatefulWidget 전환
  - 인라인 상태 필드 및 비즈니스 로직 전체 제거
  - `ref.watch()` / `ref.read().handleIntent()` 연결
  - `ref.listen()` 토스트 처리

**환율 계산기 수정**
- `presentation/currency/currency_calculator_viewmodel.dart` — `%` 동작을 즉시 계산으로 변경 (부가세 계산기와 동일)

**테스트**
- `test/domain/usecases/vat_calculate_usecase_test.dart` — 14케이스
- `test/core/constants/default_tax_rates_test.dart` — 12케이스
- `test/presentation/vat_calculator/vat_calculator_viewmodel_test.dart` — 40케이스

**문서**
- `docs/specs/VAT_CALCULATOR.md` — `=` 결과만 표시, 키패드 `00`/`0` 순서 수정

### 커밋
- (이번 커밋)

---

## 2026-03-04 — 기본 계산기 키패드 전면 개편

### 완료 항목

**Domain 계층**
- `domain/usecases/evaluate_expression_usecase.dart` — 2-pass 평탄 평가기 → 재귀 하강 파서로 리라이트
  - 괄호, 중첩 괄호, 단항 마이너스, mod(`%`) 지원
  - 문법: `expression → term → atom` (연산자 우선순위 반영)
- `domain/utils/calculator_input_utils.dart` — 헬퍼 메서드 추가 및 resolvePercent 리라이트
  - `unclosedParenCount()`, `isNegativePending()`, `hasOperator()` 추가
  - `resolvePercent()`: 괄호 depth 추적 좌→우 파서로 변경, `)%` 문맥 처리 (base 기준 퍼센트)
- `domain/utils/number_formatter.dart` — `formatResult` 소수점 최대 9자리로 변경 (아이폰 동일)

**Presentation 계층**
- `presentation/calculator/basic_calculator_viewmodel.dart` — Intent 변경 및 핸들러 전면 리라이트
  - `negatePressed` 제거 → `parenthesesPressed` 추가
  - `_onClear`: 항상 전체 초기화 (AC/C 분기 제거)
  - `_onParentheses`: 신규 스마트 괄호 핸들러
  - `_onOperator`: 초기 상태/`(` 뒤 `-`만 허용, 음수 대기 처리
  - `_onDecimal`: `(` 뒤 `0.`, 음수 대기 `-0.`, `)` 뒤 `×0.`, `%` 뒤 `×0.`
  - `_onPercent`: 연산자 뒤 교체, `%` 중복 시 마지막 피연산자만 괄호 감싸기, 결과 상태 수식 초기화
  - `_onNumber`: `)` 뒤 암묵적 `×` 삽입
  - `_onEquals`: 숫자만/불완전 수식 무시, 미닫힌 괄호 자동 닫기
- `presentation/calculator/basic_calculator_screen.dart` — UI 업데이트
  - `+/-` → `()` 버튼 교체, AC 항상 고정, `_buildPlusMinusLabel` 제거, `_wrapNegatives` 제거

**테스트**
- `test/domain/usecases/evaluate_expression_usecase_test.dart` — 29케이스 (괄호, mod, trailing dot 추가)
- `test/domain/utils/calculator_input_utils_test.dart` — 35케이스 (신규)
- `test/presentation/calculator/basic_calculator_viewmodel_test.dart` — 52케이스 (신규)

**문서**
- `docs/specs/BASIC_CALCULATOR.md` — 스펙 현행화 (괄호, mod, 소수점 9자리, `%` 중복 수식 중간 예시)
- `docs/dev/BASIC_CALCULATOR_IMPL.md` — 구현 명세 전면 리라이트
- `docs/DOC_MAP.md` — BASIC_CALCULATOR.md 설명 현행화

### 커밋
- (이번 커밋)

---

## 2026-03-02 — 단위 변환기 로직 구현 완료 (Phase 3)

### 완료 항목

**Domain 계층**
- `domain/models/unit_definition.dart` — UnitDef, UnitCategory const 클래스 (Freezed 미사용, 변환 상수)
- `core/constants/unit_definitions.dart` — 10개 카테고리 단위 상수 (스펙 비율 표 반영)
- `domain/usecases/convert_unit_usecase.dart` — 비율 기반 변환 + 온도/연비 특수 공식
- `domain/models/unit_converter_state.dart` — Freezed State (input, isResult, activeUnitCode, convertedValues)
- `test/domain/usecases/convert_unit_usecase_test.dart` — TDD 24케이스 (일반/온도/연비/엣지)

**Presentation 계층**
- `presentation/unit_converter/unit_converter_viewmodel.dart` — sealed Intent 4종 (keyTapped, categorySelected, unitTapped, arrowTapped) + Notifier ViewModel + 포맷팅
- `presentation/unit_converter/unit_converter_screen.dart` — ConsumerStatefulWidget + TabBarView 스와이프 + ViewModel 연결
  - 카테고리 탭 ↔ 스와이프 양방향 연동 (TabController.animation 실시간 감지)
  - 카테고리 칩 자동 스크롤 (Scrollable.ensureVisible)
  - 키패드 입력 → 실시간 변환, 자릿수 제한 (정수 12, 소수 8) + 토스트
  - 단위 전환 시 isResult 패턴 (첫 키 입력으로 기존 값 대체)
  - 결과 포맷팅: 천 단위 콤마, 지수 표기법 (극소/극대), 후행 0 제거, 온도 소수점 3자리
  - 더미 데이터 전체 제거, unitCategories 상수로 대체

**버그 수정**
- 연비 `L/100km` 입력값 0 → division by zero 방지 (zero guard 추가)
- `_addCommas` 소수점 포함 문자열 처리 (`273,.15` → `273.15`)
- `_UnitListState` 스크롤 리스너 해제 누락 수정 (dispose에 removeListener 추가)

**코드 품질 개선 (기존 파일)**
- `calc_page_route.dart` — 불필요한 material.dart import 제거, 불필요한 `!` 제거
- `basic_calculator_screen.dart` — 로컬 변수 `_maxFittingSize` → `maxFittingSize` (언더스코어 규칙)
- `basic_calculator_viewmodel.dart` — 문자열 연결 → interpolation
- `main_screen.dart` — `withOpacity()` → `withValues(alpha:)`
- `calc_mode_card.dart` — 다중 언더스코어 정리, `withOpacity()` 5곳 → `withValues(alpha:)`

**문서**
- `docs/specs/UNIT_CONVERTER.md` — 결과 표시 규칙 현행화 (극대값 지수 표기법, 온도 3자리, isResult 패턴)

### 커밋
- (이번 커밋)

---

## 2026-03-02 — 단위 변환기 화면 UI 구현 (Phase 3)

### 완료 항목

**단위 변환기 UI** (`presentation/unit_converter/unit_converter_screen.dart`)
- AppBar: Hero 애니메이션 (아이콘/타이틀) + 뒤로가기 — CurrencyCalculatorScreen 패턴 동일
- 카테고리 탭: 10개 카테고리 가로 스크롤 칩 (아이콘 + 이름), 선택 시 하이라이트
- 단위 리스트: ListView, 활성 행 하이라이트 (배경색 + 테두리), 탭으로 활성 행 전환
- 키패드: 4×4 레이아웃 (7-9/⌫, 4-6/AC, 1-3/., 0/00/±)
- 다크 그라디언트 테마 (`#1A1A2E` → `#16213E`), 포인트 컬러 `#E94560`
- 더미 데이터 기반 정적 UI — 변환 로직 미포함

**메인 화면** (`presentation/main/main_screen.dart`)
- `entry.id == 'unit_converter'` 네비게이션 분기 추가 (CalcPageRoute + Hero)

### 커밋
- (이번 커밋)

---

## 2026-03-02 — 환율 계산기 UX 대폭 개선 및 목업 환율 fallback 구현

### 완료 항목

**환율 계산기 구조 변경**
- From 1개 + To 3개 구조로 전환 (기존 1:1, 스왑 버튼 제거)
- From 통화 변경 시 To에 이미 있으면 swap, To 통화 중복 선택 차단 + 토스트
- State: `toCode` → `toCodes` (List), `isFromActive`/`Swapped`/`ActiveRowChanged` 제거

**목업 환율 Fallback**
- `data/datasources/exchange_rate_fallback.dart` — USD 기준 24개 통화 근사 환율 상수
- `exchange_rate_repository_impl.dart` — 모든 소스 실패 시 fallback 반환 (`timestamp: 0`)
- ViewModel: fallback 감지 시 토스트 "임시 환율을 사용 중입니다", `lastUpdated: null`
- Screen: `_formatLastUpdated()` — fallback 시 "임시 환율 사용 중" 표시

**키패드 레이아웃 변경**
- `+/-` 버튼 제거, `0` / `00` 레이아웃으로 변경
- `00` 키 처리: 선행 0 방지, 자릿수 제한(정수 12, 소수 8)에 따라 0 1~2개 추가

**환율 계산기 UI 개선**
- 새로고침 버튼 + 업데이트 시간 표시 (CupertinoActivityIndicator, 최소 800ms)
- 1단위 환율 힌트 (`1 KRW = 0.0007 USD`) — Positioned로 금액 위에 표시
- 원형 국기 표시 (`country_flags` 패키지), 국기+코드 세로 배치
- 로딩 오버레이 (BackdropFilter blur + "환율 정보를 가져오는 중...")
- 입력값 천 단위 콤마 자동 적용, 자릿수 제한 토스트
- 국기 사이즈 32, 코드 폰트 12, 금액 폰트 28로 축소 (행 간격 확보)
- 좌우 여백 균형 조정 (`left: 16, right: 24`)

**기본 계산기 개선**
- 수식 표시 영역: 너비 초과 시 연산 기호 기준 줄바꿈 + 좌우 스크롤
- 입력값/결과 영역: BouncingScrollPhysics 적용
- 하단 SafeArea 중복 패딩 제거

**문서**
- `docs/specs/EXCHANGE_RATE.md` — 현행 구현에 맞춰 전면 업데이트
- `docs/specs/BASIC_CALCULATOR.md` — 수정 요청 형식 변경, 완료 항목 기록
- `docs/specs/_SPEC_TEMPLATE.md` — 수정 요청 형식 통일
- `docs/dev/REFACTORING_CHECKLIST.md` — 리팩토링 점검 체크리스트 작성
- `docs/prompts/PROPMTS.md` — 답변 완료/중복 질문 정리
- `docs/DOC_MAP.md` — 문서 맵 추가
- `docs/prompts/answers/Q0005.md` — 앱 등록 절차 답변

**기타**
- `pubspec.yaml` — `country_flags: ^4.1.2` 의존성 추가
- `README.md` — 미구현 계산기(연봉) 제거
- 스크린샷 이미지 업데이트

### 커밋
- (이번 커밋)

---

## 2026-03-02 — Cloud Scheduler 도입 및 환율 계산기 UX 개선

### 완료 항목

**Firebase 백엔드 개선**
- `functions/src/index.ts` — `fetchAndStoreRates()` 공통 함수 분리
  - `scheduledExchangeRateRefresh` — Cloud Scheduler (`0 * * * *`, `Asia/Seoul`) 추가
  - `refreshExchangeRates` — 수동 테스트용 HTTP 트리거로 유지

**Data 계층 단순화**
- `data/datasources/exchange_rate_remote_datasource.dart` — Function 트리거 로직 제거 (Firestore 직접 읽기만)
- `data/repositories/exchange_rate_repository_impl.dart` — 3단계 → 2단계 fallback (로컬캐시→Firestore)
- `core/di/providers.dart` — `ExchangeRateRemoteDataSource` 생성 시 `dio` 파라미터 제거

**버그 수정**
- `basic_calculator_viewmodel.dart` — `NotifierProvider.autoDispose` 적용 (화면 재진입 시 상태 초기화)
- `currency_calculator_viewmodel.dart` — `NotifierProvider.autoDispose` 적용, 기본 통화 KRW/USD로 변경
- `currency_calculator_viewmodel.freezed.dart` — build_runner 재생성 (기본값 변경 반영)

**환율 계산기 UI 개선**
- `currency_calculator_screen.dart`
  - 스왑 버튼 좌측 통화 코드 아래로 이동 (기존: 두 통화 행 사이 중앙)
  - `_CurrencyCodeButton` + `_AmountDisplay`로 Row 구조 개선
  - 금액 텍스트 `FittedBox(fit: BoxFit.scaleDown)` 적용 (오버플로우 방지)
  - Progress indicator Stack 오버레이 + Center로 화면 정중앙 배치

**문서 및 커맨드**
- `.claude/commands/deploy-functions.md` — `/deploy-functions` 슬래시 커맨드 추가
- `docs/dev/firebase/FIREBASE_EXCHANGE_RATE_BACKEND.md` — Cloud Scheduler 도입 반영, 아키텍처 다이어그램 업데이트
- `docs/dev/firebase/FIREBASE_SETUP_GUIDE.md` — 빌드/배포/확인 섹션 추가
- `docs/specs/EXCHANGE_RATE.md` — 수정 요청 4개 항목 완료 체크

### 커밋
- (이번 커밋)

---

## 2026-03-01 — Phase 2 환율 계산기 Firebase 연동 및 Clean Architecture 구현

### 완료 항목

**Firebase 백엔드**
- Firebase 프로젝트 생성 (`calcmate-353ed`, Firestore 리전 `asia-northeast3`)
- `functions/src/index.ts` — `refreshExchangeRates` Function 배포 (Double Check Locking, TTL 1시간)
- `firestore.rules` — exchange_rates 읽기만 허용, 쓰기 차단 (Admin SDK 우회)
- Blaze 플랜 전환 (Functions 배포에 필요, 무료 한도 내 운영)

**Data 계층**
- `data/datasources/exchange_rate_remote_datasource.dart` — Firestore 직접 읽기 + Function HTTP 트리거
- `data/datasources/exchange_rate_local_datasource.dart` — SharedPreferences 캐시 (TTL 1시간)
- `data/dto/exchange_rate_dto.dart` — Firestore 문서 DTO (Freezed + json_serializable)
- `data/repositories/exchange_rate_repository_impl.dart` — 3단계 fallback (로컬→Firestore→Function)

**Domain 계층**
- `domain/models/exchange_rate_entity.dart` — ExchangeRateEntity (Freezed, base/rates/fetchedAt/timestamp)
- `domain/repositories/exchange_rate_repository.dart` — Repository 인터페이스
- `domain/usecases/get_exchange_rate_usecase.dart` — 환율 조회 UseCase

**Presentation 계층**
- `presentation/currency/currency_calculator_viewmodel.dart` — ExchangeRateViewModel (Notifier + sealed Intent, 교차환율 계산)
- `presentation/currency/currency_calculator_screen.dart` — StatefulWidget → ConsumerWidget 전환, 24개 통화 지원

**DI 및 초기화**
- `core/di/providers.dart` — Firestore, SharedPreferences, 환율 DataSource/Repository/UseCase Provider 등록
- `main.dart` — Firebase.initializeApp() + SharedPreferences override 추가
- `pubspec.yaml` — firebase_core, cloud_firestore 의존성 추가

**문서**
- `docs/dev/firebase/FIREBASE_EXCHANGE_RATE_BACKEND.md` — 백엔드 구현 명세 (기존 파일 이동)
- `docs/dev/firebase/FIREBASE_SETUP_GUIDE.md` — 다른 컴퓨터 개발 환경 셋업 가이드
- `docs/dev/firebase/FIREBASE_DEPLOY_GUIDE.md` — Function 배포 가이드

### 커밋
- (이번 커밋)

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
- `ce34147` — chore: Phase 0 인프라 완성 — 의존성 추가 및 DI/네트워크 설정

---

## 2026-02-28 — Phase 1 기본 계산기 로직 구현 완료

### 완료 항목

**계산기 상태 모델** (`domain/models/calculator_state.dart`)
- `CalculatorState` (Freezed) — input, expression, isResult 3필드

**계산 로직** (`domain/usecases/evaluate_expression_usecase.dart`)
- 순수 Dart 파서 — 외부 패키지 미사용
- 2단계 파싱: `*·/` 먼저 처리 후 `+·-` 처리 (연산자 우선순위 반영)
- 음수 부호, 소수점, 0 나누기(infinity) 처리
- TDD 14케이스 전부 통과 (`test/domain/usecases/evaluate_expression_usecase_test.dart`)

**ViewModel** (`presentation/calculator/basic_calculator_viewmodel.dart`)
- `CalculatorIntent` (sealed class) — 8가지 Intent 정의
- `BasicCalculatorViewModel` (Riverpod Notifier) — handleIntent로 state 전이
- 계산 완료 후 숫자 입력 시 새 수식 시작, % / +/- 처리 포함

**화면 연결** (`presentation/calculator/basic_calculator_screen.dart`)
- `StatelessWidget` → `ConsumerWidget` 전환
- 디스플레이: state.input / state.expression 구독, FittedBox로 긴 숫자 자동 축소
- 버튼 탭 → handleIntent 연결 완료

### 커밋
- (이번 커밋)

---

## 2026-02-28 — 기본 계산기 UI 구현 (Phase 1 - 1단계)

### 완료 항목

**기본 계산기 화면** (`presentation/calculator/basic_calculator_screen.dart`)
- 플레이스홀더 → 뉴모피즘 디자인 전체 UI로 교체
- 디스플레이: 수식(위, 회색, 계산 완료 후 표시) + 입력값/결과(아래, 48px) 하단 정렬
- 버튼 레이아웃: iOS 계산기 동일 구조 (⌫·AC·%·÷ / 7~1 / +/-·0·.·=)
  - `LayoutBuilder` 기반 정사각형 셀 계산 (cellH = cellW)
  - `⌫` 버튼: `Icons.backspace_outlined` 아이콘
  - 연산자(÷·×·-·+) 폰트 28px, = 버튼 코랄(`#E8735A`) 포인트
  - 뉴모피즘 그림자: 흰색(-4,-4) + 회색(+4,+4)
- AppBar: 반투명 다크 컨테이너(black 20%) + 흰색 아이콘, 타이틀 20px

**메인 화면** (`presentation/main/main_screen.dart`)
- 기본 계산기 진입 color: `Colors.blue` → `Colors.black.withOpacity(0.2)` 변경

**구현 명세**
- `docs/dev/basic_calculator.md` — State/Intent/UseCase/ViewModel 구현 명세 작성

### 커밋
- (이번 커밋)

---

## 2026-02-27 — 카드 리스트 리팩터링 (Phase 1 선행)

### 완료 항목

**데이터 모델**
- `domain/models/calc_mode_entry.dart` — CalcModeEntry (Freezed) 불변 모델
  - id, title, description, icon, imagePath, isVisible, order 필드

**설정 상수**
- `core/config/calc_mode_config.dart` — 13개 항목 `kCalcModeEntries` 상수 정의

**ViewModel**
- `presentation/main/main_screen_viewmodel.dart` — MVVM + Intent 패턴 적용
  - `MainScreenState` (Freezed), `MainScreenIntent` (sealed class)
  - `MainScreenViewModel` (Riverpod Notifier, handleIntent)

**메인 화면 전환**
- `presentation/main/main_screen.dart` — StatefulWidget → ConsumerStatefulWidget
  - 하드코딩 카드 목록 제거, `state.entries` 구독으로 전환
  - 스크롤 상태를 `setState` 대신 ViewModel Intent로 위임

**인프라**
- `pubspec.yaml` — retrofit 버전 충돌 수정 (`^4.4.1` → `>=4.4.1 <4.9.0`)
  - retrofit 4.9.2 + retrofit_generator 9.7.0 호환성 문제로 build_runner 실패하던 이슈 해결

**문서**
- `docs/dev/CARD_LIST_REFACTOR.md` — 리팩터링 구현 명세
- `docs/dev/_IMPL_SPEC_TEMPLATE.md` — 구현 명세 템플릿
- `docs/prompts/answers/Q0011.md` — Android Statusbar 아이콘 색상 이슈
- `docs/prompts/answers/Q0013.md` — Freezed/@freezed 개념 (코틀린 data class 비교)

### 커밋
- (이번 커밋)
