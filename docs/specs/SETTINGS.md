# 설정 화면 기획서

> **Phase**: `Phase 14`
> **한 줄 설명**: 앱 전반의 표시·동작 방식을 사용자가 직접 조정하는 설정 화면

---

## 개요

사용자가 CalcMate의 테마, 계산기 기본값 등 앱 전반의 동작을 개인화할 수 있는 화면.
현재 하드코딩된 `ThemeMode.system`, BMI 단위계, 환율 기본 통화 등을 사용자가 직접 변경하고
SharedPreferences에 저장한다. 메인 화면 우상단 설정 드롭다운 → "설정" 항목을 통해 진입한다.

---

## 진입 경로

- 메인 화면 앱바 우상단 **⋮ 메뉴** → **설정**
- (향후 확장) 딥링크 / 온보딩 화면에서 직접 진입

---

## 화면 구성

> **UI 스타일**: Toss 앱 스타일 카드 기반 레이아웃.
> 배경: 라이트 `#F2F2F7`, 다크 `Colors.black`.
> 카드: 라이트 `Colors.white`, 다크 `#1C1C1E`, 라운드 `radiusCard(16)`.
> 행 높이 48dp, 섹션 타이틀 `textStyleValue` + `w700`.
> 스크롤 시 상태바+AppBar 영역 블러 오버레이 (`BlurStatusBarOverlay`).

```
┌───────────────────────────────────┐
│  ← 설정                           │  AppBar (투명, 좌측 정렬)
├───────────────────────────────────┤
│  ┌─────────────────────────────┐  │
│  │  언어              한국어 › │  │  → 바텀시트 선택 (UI only)
│  │  화면 테마       시스템 기준 › │  │  → 바텀시트 선택
│  └─────────────────────────────┘  │
│                                   │
│  ┌─────────────────────────────┐  │
│  │  일반                       │  │  섹션 타이틀 (w700)
│  │  [메인 리스트]              │  │  서브 섹션 헤더 (배경 tint)
│  │  계산기 관리          9개 › │  │  → 서브 화면 Push
│  │  [환율 계산기]              │  │  서브 섹션 헤더 (배경 tint)
│  │  환율 기준 통화       KRW › │  │  → 바텀시트 선택
│  └─────────────────────────────┘  │
│                                   │
│  ┌─────────────────────────────┐  │
│  │  앱 정보                    │  │  섹션 타이틀 (w700)
│  │  버전 정보          1.0.0 › │  │  (표시 전용)
│  │  오픈소스 라이선스        › │  │  → 커스텀 라이선스 화면 Push
│  │  개인정보 처리방침        › │  │  → 외부 브라우저
│  └─────────────────────────────┘  │
└───────────────────────────────────┘
```

### 계산기 관리 서브 화면

```
┌───────────────────────────────────┐
│  ← 계산기 관리                  │
├───────────────────────────────────┤
│  메인 화면에 표시할   전체 선택  │  안내 텍스트 + 전체 선택/해제
│  계산기를 선택하세요.            │
│  ┌─────────────────────────────┐ │
│  │ [📐] 기본 계산기         ✓  │ │  아이콘 + 타이틀 + 체크
│  │ ───────────────────────────│ │
│  │ [💱] 환율 계산기         ✓  │ │
│  │ ───────────────────────────│ │
│  │ [📏] 단위 변환기         ○  │ │  비활성: dim + 빈 원형
│  │ ───────────────────────────│ │
│  │ ...                        │ │
│  └─────────────────────────────┘ │
└───────────────────────────────────┘
```

> **카드 스타일**: 라운드 카드(`radiusCard`) 안에 전체 항목 배치. 배경: 라이트 `#F2F2F7`, 다크 `Colors.black`.
> **체크 인디케이터**: 활성 — 원형 채움 + 체크 아이콘, 비활성 — 빈 원형 테두리.
> **활성 색상**: 라이트 딥 블루 `#5B7FCC`, 다크 슬레이트 `#6B7B8D` (아이콘·체크·전체 선택 텍스트 공유).
> **전체 선택/해제**: 안내 텍스트 우측 텍스트 버튼. 전부 활성 시 "전체 해제", 하나라도 비활성 시 "전체 선택".
> **`setAllVisibility(bool)` intent**: 전체 선택 시 모두 활성, 전체 해제 시 첫 번째 항목만 유지.

### 오픈소스 라이선스 화면

커스텀 구현 (`OpenSourceLicensesScreen`). Flutter 기본 `showLicensePage` 미사용.

```
┌───────────────────────────────────┐
│  ← 오픈소스 라이선스             │
├───────────────────────────────────┤
│  abseil-cpp            1개 라이선스 › │
│  ─────────────────────────────── │
│  cloud_firestore       3개 라이선스 › │
│  ─────────────────────────────── │
│  ...                              │
└───────────────────────────────────┘
```

- `LicenseRegistry.licenses`로 패키지별 라이선스 수집
- 패키지명 알파벳 정렬, 라이선스 개수 표시
- 탭 시 `_LicenseDetailScreen`으로 Push (전체 라이선스 텍스트 표시)
- `paragraph.indent.clamp(0, 10)` — 음수 indent 크래시 방지

---

## 섹션별 기능 요구사항

### 1. 첫 번째 카드 (타이틀 없음)

#### 1-1. 언어
- 선택지: **한국어** (기본), **English**, **中文**, **日本語**
- 탭 시 바텀시트(라디오 리스트)로 선택
- **현재 UI만 구현** — 실제 l10n 전환 기능 미구현 (추후 Phase)
- 기본값: 한국어 고정

#### 1-2. 화면 테마
- 선택지: **시스템 기준** (기본) / **라이트** / **다크**
- 탭 시 바텀시트(라디오 리스트)로 선택
- 선택 즉시 `MaterialApp.themeMode` 반영 (앱 재시작 불필요)
- `SharedPreferences` 키: `'theme_mode'` — 값: `'system'` | `'light'` | `'dark'`
- 현재 `main.dart`의 `ThemeMode.system` 하드코딩을 Provider로 교체

---

### 2. 일반

#### 2-1. 계산기 관리
- 설정 화면에서 타일 탭 → **서브 화면**(`계산기 관리`)으로 푸시
- 서브 화면: 전체 계산기 목록(13개)을 Switch 토글로 표시
- 타일 우측 값: 현재 표시 중인 계산기 수 (예: `9개`)
- ON → 메인 화면 목록에 표시 / OFF → 메인 화면 목록에서 제거
- `SharedPreferences` 키: `'calc_entry_hidden'` — 숨긴 항목의 id 목록 (StringList)
  - 기본값: 빈 리스트 (전체 표시)
  - ON/OFF 변경 즉시 메인 화면에 반영
- **최소 1개 이상** 표시 상태 유지 (마지막 1개는 OFF 불가)
- `CalcModeEntry.isVisible` 필드 활용 (이미 모델에 존재)
- `MainScreenViewModel`에 `toggleVisibility(String id)` intent 추가
- 메인 화면 리스트는 `isVisible == true` 항목만 렌더링
- **메인 화면 카드 스와이프 숨기기와 동일 로직 공유** — 어느 쪽에서 변경해도 즉시 동기화

#### 2-2. 환율 기준 통화
- 환율 계산기의 **fromCode** 초기값을 결정
- 선택지: KRW, USD, EUR, JPY, CNY, GBP, AUD, CAD, CHF, HKD (10개 주요 통화)
- 탭 시 바텀시트(라디오 리스트 + 통화 코드/이름 표시)로 선택
- `SharedPreferences` 키: `'default_currency'`
  - 저장값 없으면 기기 로케일의 국가 코드로 통화 추론 (KR → KRW, US → USD, JP → JPY 등)
  - 사용자가 수동 변경하면 해당 값을 저장 후 이후 로케일 무시
- **현재 UI 타일만 구현** — 바텀시트 및 SharedPreferences 연동 미구현

#### 2-3. BMI 단위
- BMI 계산기의 단위계 초기값을 결정
- 선택지: **kg / cm**, **lb / in**
- 탭 시 바텀시트(라디오 리스트)로 선택
- `SharedPreferences` 키: `'bmi_unit_system'` — 값: `'metric'` | `'imperial'`
  - 저장값 없으면 기기 로케일 기반 자동 설정
- **현재 UI 타일만 구현** — 바텀시트 및 SharedPreferences 연동 미구현

---

### 3. 앱 정보

#### 3-1. 버전 정보
- `package_info_plus` 패키지로 앱 버전 표시 (예: `1.0.0 (1)`)
- **현재 하드코딩** `'1.0.0'` 표시

#### 3-2. 오픈소스 라이선스
- 커스텀 `OpenSourceLicensesScreen`으로 Push
- 패키지 목록 화면 + 라이선스 상세 화면 2단계 구조
- `LicenseRegistry.licenses` 사용 (Flutter 내장 라이선스 레지스트리)

#### 3-3. 개인정보 처리방침
- 탭 시 외부 브라우저(`url_launcher`)로 개인정보처리방침 URL 열기
- 앱 언어에 따라 한국어/영어 URL 분기
  - 한국어: `https://gy-sheep.github.io/CalcMate/privacy-policy-ko.html`
  - 영어: `https://gy-sheep.github.io/CalcMate/privacy-policy.html`

---

## SharedPreferences 키 정리

| 키 | 타입 | 기본값 | 기존 존재 여부 |
|----|------|--------|--------------|
| `theme_mode` | String | `'system'` | 신규 |
| `calc_entry_hidden` | StringList | `[]` | 신규 |
| `default_currency` | String | `'KRW'` | 신규 (미구현) |
| `bmi_unit_system` | String | `'metric'` | 기존 (BMI ViewModel에서 사용, 설정 연동 미구현) |

---

## 화면 전환

| 트리거 | 동작 |
|--------|------|
| 뒤로가기 / ← 버튼 | 메인 화면으로 Pop |
| 오픈소스 라이선스 탭 | 커스텀 `OpenSourceLicensesScreen` Push |
| 개인정보 처리방침 탭 | 외부 브라우저 열기 (한국어/영어 분기) |
| 계산기 관리 탭 | 서브 화면 Push |
| 화면 테마 / 언어 탭 | 바텀시트 열기 |

---

## 공통 위젯

### BlurStatusBarOverlay
- 스크롤 시 상태바+AppBar 영역에 블러+그라디언트 오버레이 표시
- `isVisible` (bool) + `backgroundColor` (Color) 파라미터
- `BackdropFilter(sigma: 20)` + `ShaderMask` + `AnimatedOpacity(250ms)`
- 적용 화면: 설정, 계산기 관리, 오픈소스 라이선스 목록, 라이선스 상세, BMI 계산기

### _SectionCard
- 선택적 `title` 파라미터 (null이면 타이틀 없음)
- 라운드 카드 (`radiusCard`), 라이트 white / 다크 `#1C1C1E`

### _SettingsTile
- 선택적 `value` 파라미터 (null이면 값 미표시)
- 행 높이 48dp, chevron_right 아이콘

---

## 예외 / 엣지 케이스

| 상황 | 기대 동작 |
|------|-----------|
| SharedPreferences 읽기 실패 | 각 항목의 기본값 사용 |
| 계산기 관리 1개만 남은 상태에서 OFF 시도 | Switch 비활성화 (dim 처리) |
| 시스템 테마 변경 후 `시스템 기준` 선택 중 | 즉시 시스템 테마로 반영 |
| `bmi_unit_system` 키가 이미 BMI ViewModel에 저장된 값 | 설정 화면에서 해당 값 그대로 읽어 표시 |
| 라이선스 paragraph.indent 음수 | `.clamp(0, 10)` 적용 |

---

## 미포함 항목 (추후 고려)

- **언어 전환 실제 기능**: 현재 UI만 구현, l10n 전환은 별도 Phase
- **환율 기준 통화 바텀시트**: UI 타일만 구현, 바텀시트+SP 연동 별도 구현
- **BMI 단위 바텀시트**: UI 타일만 구현, 바텀시트+SP 연동 별도 구현
- **버전 정보 동적 표시**: `package_info_plus` 연동 필요
- **문의하기**: 이메일 앱 연동 (`mailto:` 스킴) — 향후 추가
- **버튼 진동 피드백**: 제외됨 (설정 항목에 포함하지 않음)
- **계산 히스토리 설정**: 히스토리 기능 개발 시 추가
- **알림 설정**: 현재 알림 기능 없음
- **광고 제거 (프리미엄)**: 별도 Phase로 분리
- **메인 화면 순서 편집**: 이미 메인 화면 ⋮ 메뉴에 독립 기능으로 존재

---

## 참고 / 레퍼런스

- `lib/presentation/settings/settings_screen.dart` — 설정 메인 화면 (카드 기반 레이아웃)
- `lib/presentation/settings/settings_viewmodel.dart` — 테마 모드 상태 관리
- `lib/presentation/settings/calculator_management_screen.dart` — 계산기 관리 서브 화면
- `lib/presentation/settings/open_source_licenses_screen.dart` — 커스텀 라이선스 목록/상세 화면
- `lib/presentation/widgets/blur_status_bar_overlay.dart` — 블러 오버레이 공통 위젯
- `lib/main.dart` — `ThemeMode.system` → `settingsViewModelProvider` 연동 완료
- `lib/presentation/bmi_calculator/bmi_calculator_viewmodel.dart` — `'bmi_unit_system'` 키 재사용
