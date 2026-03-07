# 날짜 계산기 — 화면 디자인

> 구현 참조용. 레이아웃·위젯·스타일·색상을 한 곳에서 확인한다.
> 색상 상수는 `date_calculator_colors.dart` 참조.

---

## 배경

| 속성 | 값 |
|------|----|
| 종류 | `LinearGradient` · topCenter → bottomCenter (3색) |
| 상단 | `kDateBg1` #FBF0F0 (라이트 핑크) |
| 중단 | `kDateBg2` #F5E2E2 (웜 로즈) |
| 하단 | `kDateBg3` #EDD1D1 (더스티 로즈) |
| 비고 | `extendBodyBehindAppBar: true` → 그라디언트가 상태바 뒤까지 연장 |

---

## 레이아웃 & 스타일

```
┌──────────────────────────────────┐
│  ←  날짜 계산기                  │  ← ❶ AppBar
├──────────────────────────────────┤
│ [ 기간 계산 | 날짜 계산 | D-Day ] │  ← ❷ 탭바 (탄성 스트레치)
├──────────────────────────────────┤
│  ┌────────────────────────────┐  │
│  │       301일                │  │  ← ❸ 결과 카드 (모드별 상이)
│  │   43주 0일  ·  9개월 27일  │  │
│  └────────────────────────────┘  │
│  시작 날짜                        │  ← ❹ 날짜 카드 (모드별 1~2개)
│  ┌────────────────────────────┐  │
│  │  2026년  3월  4일  수요일  │  │
│  └────────────────────────────┘  │
│  종료 날짜                        │
│  ┌────────────────────────────┐  │
│  │  2026년 12월 31일  목요일  │  │
│  └────────────────────────────┘  │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  ← ❺ 스크롤 페이드 (목록 넘칠 때)
├──────────────────────────────────┤  ← ❻ 글라스모피즘 구분 (날짜 계산 모드만)
│  7   8   9                       │  ← ❼ 키패드 (날짜 계산 모드만)
│  4   5   6                       │
│  1   2   3                       │
│  +/- 0   ⌫                      │
└──────────────────────────────────┘
```

> **구조 메모**: `DateTabBar` + `PageView(3 pages)` + `AdBannerPlaceholder`.
> 기간 계산·D-Day 모드는 `ScrollFadeView` 전체 스크롤. 날짜 계산 모드만 `ScrollFadeView(상단)` + `DateKeypad(하단 고정)` 분할 레이아웃.
> 모든 스크롤 영역은 `ScrollFadeView(fadeColor: kDateBg3)` 적용.

---

## ❶ AppBar

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❶ | 뒤로가기 아이콘 | `Icon(arrow_back_ios)` | `sizeAppBarBackIcon` 20 | `kDateTextPrimary` |
| ❶ | 타이틀 | `Text` | `textStyleAppBarTitle` 18sp / w600 | `Colors.white` |

> `backgroundColor: Colors.transparent` / `elevation: 0` / `scrolledUnderElevation: 0` / `centerTitle: false`

---

## ❷ 탭바 (`DateTabBar` → `AppAnimatedTabBar`)

탭 3개: `['기간 계산', '날짜 계산', 'D-Day']`. PageView 오프셋과 실시간 연동.

| 속성 | 값 |
|------|----|
| 탭 행 높이 | 40 |
| 칩 배경 | `kDateAccent` 12% |
| 칩 테두리 | `kDateAccent` 25% / radius:20 |
| 칩 글로우 | `kDateAccent` 25% / blur:8 / spread:1 |
| 하단 언더라인 (전체) | 1px `kDateDivider` |
| 하단 언더라인 (활성) | 2px `kDateAccent` + 글로우 (`kDateAccent` 60% / blur:6 / spread:1) |
| 칩 패드 비율 | 양쪽 0.18 (칩이 탭보다 좁음) |
| 스트레치 이징 | 좌: `easeInCubic` / 우: `easeOutCubic` |
| 외부 패딩 | `fromLTRB(16, 0, 16, 12)` |

**탭 레이블 애니메이션** (pageOffset 기반 실시간)

| 상태 | 폰트 | 스케일 | 색상 |
|------|------|--------|------|
| 활성 (distance = 0) | `textStyleChip` 14sp / w600 | 1.08× | `kDateAccent` |
| 비활성 (distance ≥ 1) | `textStyleChip` 14sp / w400 | 1.0× | `kDateTextTertiary` |
| 중간 | `Color.lerp` | `1.0 + (1 - distance) * 0.08` | lerp 보간 |

---

## ❸ 결과 카드 (`ResultCard`)

모든 모드에서 공통으로 사용하는 결과 표시 컨테이너.

| 속성 | 값 |
|------|----|
| 너비 | `double.infinity` |
| 패딩 | vertical:24 / horizontal:20 |
| 배경 | `kDateCardBg` #FFFFFF 80% |
| 모서리 | `radiusCard` 16 |
| 테두리 | `kDateCardBorder` (#9E4A50 20%) |

### 모드별 결과 카드 내용

**기간 계산 모드**

```
┌─────────────────────────────────┐
│           301일                  │  ← 메인 결과
│  ─────────────────────────────  │  ← kDateDivider
│  43주 0일    │    9개월 27일    │  ← 보조 결과 (Row spaceEvenly + 수직 구분선)
│         0년 9개월 27일          │  ← 보조 결과 (center)
└─────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | 메인 결과 ("N일") | `Text` | `textStyleResult56` 56sp / **w700** / height:1.0 | `kDateAccent` |
| ❸ | 구분선 | `Divider` | — | `kDateDivider` |
| ❸ | 보조 결과 (주·일 / 개월·일) | `buildSubText()` | `textStyleCaption` 14sp / w400 | `kDateTextSecondary` |
| ❸ | 수직 구분선 | `Container` | w:1 / h:16 | `kDateDivider` |
| ❸ | 보조 결과 (년·개월·일) | `buildSubText()` | `textStyleCaption` 14sp / w400 | `kDateTextSecondary` |

> 메인→구분선: 14dp / 구분선→보조: 10dp / 보조→보조: 6dp

**날짜 계산 모드**

```
┌─────────────────────────────────┐
│      2026년 6월 12일            │  ← 결과 날짜
│           금요일                │  ← 요일
│  ─────────────────────────────  │  ← kDateDivider
│      오늘부터 100일 후          │  ← 설명 텍스트
└─────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | 결과 날짜 | `Text` | `textStyleResult28` 28sp / **w700** | `kDateTextPrimary` |
| ❸ | 요일 | `Text` | `textStyleResult18` 18sp / w500 | `kDateAccent` |
| ❸ | 구분선 | `Divider` | — | `kDateDivider` |
| ❸ | 설명 텍스트 | `Text` | `textStyleBody` 16sp / w400 | `kDateTextSecondary` |

> 날짜→요일: 4dp / 요일→구분선: 12dp / 구분선→설명: 10dp

**D-Day 모드**

```
┌─────────────────────────────────┐
│           D - 302               │  ← 메인 (미래: kDateAccent / 당일: #FFD54F)
│  ─────────────────────────────  │  ← kDateDivider (당일 아닐 때만)
│  43주 1일 후 (2027.01.01)       │  ← 보조 (당일 아닐 때만)
│  9개월 28일 후                   │
└─────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | 메인 D-Day | `Text` | `textStyleResult48` 48sp / **w700** / height:1.0 | 미래·과거: `kDateAccent` / 당일: `#FFD54F` |
| ❸ | 구분선 | `Divider` | — | `kDateDivider` (당일 미표시) |
| ❸ | 보조 (주·일 + 날짜) | `buildSubText()` | `textStyleCaption` 14sp / w400 | `kDateTextSecondary` |
| ❸ | 보조 (개월·일) | `buildSubText()` | `textStyleCaption` 14sp / w400 | `kDateTextSecondary` |

> D-Day 표기: 미래 `D − N` (유니코드 마이너스) / 당일 `D-DAY` / 과거 `D + N`

---

## ❹ 날짜 카드 (`DateCard`)

날짜 선택 UI. 탭 → 캘린더 바텀 시트. 모드별 1~2개 사용.

```
┌─────────────────────────────────────────────┐
│  Column                                      │
│    Text (label)              ← caption       │
│    SizedBox(h: 6)                            │
│    ┌──────────────────────────────────────┐  │
│    │  Column        Spacer  Text  □ Icon  │  │
│    │  ├ Text(year)          (요일) (›)    │  │
│    │  ├ SizedBox(h:2)                     │  │
│    │  └ Text(월 일)                       │  │
│    └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❹ | 라벨 ("시작 날짜" 등) | `Text` | `textStyleCaption` 14sp / w400 | `kDateTextSecondary` |
| ❹ | 카드 컨테이너 | `Container` (full width) | padding: h:16 v:14 | 배경: `kDateCardBg` / radius:16 / border: `kDateCardBorder` |
| ❹ | 연도 | `Text` | `textStyleCaption` 14sp / w400 | `kDateTextSecondary` |
| ❹ | 월·일 | `Text` | `textStyleResult22` 22sp / w600 | `kDateAccent` |
| ❹ | 요일 | `Text` | `textStyleLabelLarge` 14sp / w500 | `kDateAccent` |
| ❹ | 화살표 | `Icon(chevron_right)` | 18 | `kDateTextTertiary` |

> 요일↔화살표 간격: 6dp / 연도↔월일 간격: 2dp / 라벨↔카드 간격: 6dp

### 모드별 DateCard 사용

| 모드 | 카드 수 | 라벨 |
|------|---------|------|
| 기간 계산 | 2 | "시작 날짜" / "종료 날짜" |
| 날짜 계산 | 1 | "기준 날짜" |
| D-Day | 2 | "기준일" 또는 "기준일 (오늘)" / "목표 날짜" |

---

## ❺ 스크롤 페이드

목록이 화면을 초과할 때 하단 페이드 표시. 하단 도달 시 (8px 이내) 페이드 비표시.

| 속성 | 값 |
|------|----|
| 위젯 | `ScrollFadeView` (공통 위젯) |
| 높이 | 48 |
| 그라디언트 | `kDateBg3` 0% → 70% → 100% |
| stops | `[0.0, 0.6, 1.0]` |
| 수평 패딩 | `paddingScreenH` 16 |

---

## ❻ 글라스모피즘 구분 (키패드 상단)

날짜 계산 모드에서 키패드와 상단 스크롤 영역 사이 구분.

| 속성 | 값 |
|------|----|
| 블러 | `BackdropFilter(ImageFilter.blur(sigmaX:20, sigmaY:20))` |
| 배경 | `Colors.white` 22% |
| 상단 테두리 | `Colors.white` 45% |

---

## ❼ 키패드 (`DateKeypad`) — 날짜 계산 모드 전용

글라스모피즘 효과. 스크롤 영역 하단에 고정 배치.

**레이아웃**: 4행 × 3열

```
┌─────────┬─────────┬─────────┐
│    7    │    8    │    9    │
├─────────┼─────────┼─────────┤
│    4    │    5    │    6    │
├─────────┼─────────┼─────────┤
│    1    │    2    │    3    │
├─────────┼─────────┼─────────┤
│   +/−   │    0    │    ⌫   │
└─────────┴─────────┴─────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❼ | 0~9 | `Text` | `textStyleKeypadNumber` 22sp / w400 | `kDateTextPrimary` |
| ❼ | +/− | `Text` | `textStyleKeypadNumber` 22sp / w400 | `kDateTextPrimary` |
| ❼ | ⌫ | `Icon(backspace_outlined)` | `sizeKeypadBackspace` 26 | `kDateTextSecondary` |
| ❼ | 버튼 높이 | — | — | 56 |
| ❼ | 버튼 배경 | `Container` | — | `Colors.white` 28% / border `Colors.white` 30% w:0.5 |

---

## 모드별 고유 위젯

### 기간 계산 — 시작일 포함 토글

```
Row
  Text "시작일 포함"    AnimatedContainer(42×24)    Text "기념일 계산 시 ON 권장"
                       ┌──────────────────┐
                  OFF: │  ● ─────────     │  배경: kDateDivider
                       └──────────────────┘
                       ┌──────────────────┐
                  ON:  │  ───────── ●     │  배경: kDateAccent
                       └──────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| — | "시작일 포함" | `Text` | `textStyleBody` 16sp / w400 | `kDateTextSecondary` |
| — | 스위치 트랙 | `AnimatedContainer` (200ms) | 42×24 / radius:12 | ON: `kDateAccent` / OFF: `kDateDivider` |
| — | 스위치 썸 | `Container` | 18×18 / circle | `Colors.white` |
| — | 힌트 | `Text` | `textStyleLabelSmall` 10sp / w500 | `kDateTextTertiary` |
| — | 라벨↔스위치 간격 | `SizedBox` | — | width: 8 |

### 날짜 계산 — 스텝 버튼 + 숫자 + 단위 선택

```
┌────────────────────────────────────────┐
│  ⏪  ◀    +100    ▶  ⏩               │  ← 스텝 버튼 행
│  [ 일 ] [ 주 ] [ 월 ] [ 년 ]          │  ← 단위 선택 행
└────────────────────────────────────────┘
```

**스텝 버튼**

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| — | ⏪ (−5) | `Icon(keyboard_double_arrow_left)` | `sizeIconStep` 18 | `kDateAccent` |
| — | ◀ (−1) | `Icon(keyboard_arrow_left)` | `sizeIconStep` 18 | `kDateAccent` |
| — | ▶ (+1) | `Icon(keyboard_arrow_right)` | `sizeIconStep` 18 | `kDateAccent` |
| — | ⏩ (+5) | `Icon(keyboard_double_arrow_right)` | `sizeIconStep` 18 | `kDateAccent` |
| — | 버튼 컨테이너 | `Container` | 48×48 / circle | 배경: `kDateCardBg` / border: `kDateCardBorder` |
| — | 중앙 숫자 | `Text` | `textStyleResult40` 40sp / **w700** / height:1.0 / center | `kDateAccent` |

> 방향 표시: calcDirection == 0 → `+N` / calcDirection == 1 → `−N` (유니코드 마이너스)
> 스텝 버튼 간격: 8dp / 숫자 행→단위 행: 10dp

**단위 선택 (4개 버튼 Row)**

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| — | 단위 버튼 (일/주/월/년) | `Container` > `Text` | `textStyleBody` 16sp | 선택: `kDateAccent` w600 / 미선택: `kDateTextSecondary` w400 |
| — | 버튼 높이 | — | — | 44 |
| — | 선택 상태 배경 | — | — | `kDateAccent` 15% / border `kDateAccent` 50% / radius:10 |
| — | 미선택 상태 배경 | — | — | `kDateCardBg` / border `kDateCardBorder` / radius:10 |
| — | 버튼 간격 | `SizedBox` | — | width: 8 (마지막 제외) |

---

## 날짜 선택 캘린더 (바텀 시트)

DateCard 탭 시 `showDatePicker` 호출.

| 속성 | 값 |
|------|----|
| `primary` | `kDateAccent` #9E4A50 |
| `onPrimary` | `Colors.white` |
| `surface` | `kDateBg1` #FBF0F0 |
| 날짜 범위 | 1900-01-01 ~ 2100-12-31 |

---

## 간격 요약

| 위치 | 값 |
|------|----|
| 화면 수평 패딩 | `paddingScreenH` 16 |
| 탭바 하단 여백 | 12 |
| 결과 카드 → 첫 번째 DateCard | 16 |
| DateCard 간 간격 | 12 |
| DateCard → 하위 콘텐츠 | 12 |
| 각 모드 하단 여백 | 24 |
| ResultCard 내부 패딩 | v:24 / h:20 |
| DateCard 내부 패딩 | h:16 / v:14 |
| 스크롤 페이드 높이 | 48 |

---

## 애니메이션

| 대상 | 시간 | 곡선 |
|------|------|------|
| PageView 전환 | 300ms | `easeInOut` |
| 탭바 칩·언더라인 | pageOffset 실시간 | 좌: `easeInCubic` / 우: `easeOutCubic` |
| 탭 레이블 스케일 | pageOffset 실시간 | 선형 보간 |
| 탭 레이블 색상 | pageOffset 실시간 | `Color.lerp` |
| 시작일 포함 토글 | 200ms | 기본 (linear) |

---

## 색상 팔레트

| 상수 | hex / 값 | 용도 |
|------|---------|------|
| `kDateBg1` | `#FBF0F0` | 배경 그라디언트 상단 (라이트 핑크) |
| `kDateBg2` | `#F5E2E2` | 배경 그라디언트 중단 (웜 로즈) |
| `kDateBg3` | `#EDD1D1` | 배경 그라디언트 하단 (더스티 로즈) · 스크롤 페이드 색상 |
| `kDateAccent` | `#9E4A50` | 주요 강조 (결과, 날짜, 탭, 토글, 스텝 버튼) |
| `kDateCardBg` | `#FFFFFF` 80% (`0xCCFFFFFF`) | 카드 배경 (반투명 흰색) |
| `kDateCardBorder` | `#9E4A50` 20% (`0x339E4A50`) | 카드 테두리 |
| `kDateTextPrimary` | `#4A2030` | 주 텍스트 (다크 플럼) |
| `kDateTextSecondary` | `#7A4455` | 보조 텍스트 (뮤트 마룬) |
| `kDateTextTertiary` | `#B08898` | 3차 텍스트 (페이드 로즈) |
| `kDateDivider` | `#E2C4CC` | 구분선 (라이트 모브) |
| D-Day 당일 | `#FFD54F` | D-DAY 강조 (앰버/골드, 상수 아닌 인라인) |
