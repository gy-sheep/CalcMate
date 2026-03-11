# 나이 계산기 — 화면 디자인

> 구현 참조용. 레이아웃·위젯·스타일·색상을 한 곳에서 확인한다.
> 색상 상수는 `age_calculator_colors.dart` 참조.

---

## 배경

| 속성 | 값 |
|------|----|
| 종류 | `LinearGradient` · topCenter → bottomCenter |
| 상단 | `kAgeBg1` #FFF8F0 (크림) |
| 하단 | `kAgeBg2` #FFE4CC (복숭아) |
| 비고 | `extendBodyBehindAppBar: true` → 그라디언트가 상태바 뒤까지 연장 |

---

## 레이아웃 & 스타일

```
┌──────────────────────────────────┐
│  ←  나이 계산기                  │  ← ❶ AppBar
├──────────────────────────────────┤
│  생년월일              □ 음력    │  ← ❷ 헤더 행
│  ┌──────────────────────────┐   │  ← ❸ 피커 컨테이너 (글라스모피즘)
│  │  1989년  │  3월  │ 15일  │   │     하이라이트 바 (44px)
│  │ ═══════════════════════  │   │     ShaderMask 상하 페이드
│  │  1990년  │  4월  │ 16일  │   │
│  └──────────────────────────┘   │
│  2026년 3월 7일 기준             │  ← ❹ 기준일 텍스트
├──────────────────────────────────┤  ← ❺ 구분선
│  ┌──────────────────────────┐   │  ← ❻ AgeCard
│  │  35세        [세는 나이] │   │
│  │  ──────────────────────  │   │
│  │  만 나이        34세     │   │
│  │  연 나이        35세     │   │
│  │  태어난 요일  금요일     │   │
│  └──────────────────────────┘   │
│  ┌───────────┐ ┌───────────┐   │  ← ❼ 다음 생일 / 살아온 날 카드
│  │ 다음 생일 │ │ 살아온 날 │   │
│  │   D-24    │ │ 12,847일  │   │
│  │ 4월1일(화)│ │ 약 35년   │   │
│  └───────────┘ └───────────┘   │
│  ┌───────────┐ ┌───────────┐   │  ← ❽ 띠 / 별자리 카드
│  │ 띠         │ │ 별자리    │   │
│  │ 🐴 말띠   │ │ ♓ 물고기  │   │
│  └───────────┘ └───────────┘   │
└──────────────────────────────────┘
```

> **구조 메모**: `PickerSection` + `Divider` + `Expanded(ResultScrollView or EmptyState)` + `AdBannerPlaceholder` 의 세로 구성.
> 결과 영역은 `ScrollFadeView(fadeColor: kAgeBg2, padding: fromLTRB(16,16,16,32))`로 스크롤 페이드 처리.
> 미래 날짜 선택 시 결과 대신 `EmptyState`를 표시.

---

## ❶ AppBar

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❶ | 뒤로가기 아이콘 | `Icon(arrow_back_ios)` | `sizeAppBarBackIcon` 20 | `Colors.white` |
| ❶ | 타이틀 | `Text` | `textStyleAppBarTitle` 18sp / w600 | `Colors.white` |

> `backgroundColor: Colors.transparent` / `elevation: 0` / `scrolledUnderElevation: 0` / `centerTitle: false`

---

## ❷❸❹ 생년월일 피커 섹션 (`PickerSection`)

**❷ 헤더 행**

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❷ | "생년월일" 라벨 | `Text` | `textStyleLabelLarge` 14sp / **w600** / letterSpacing:0.5 | `kAgeTextSecondary` |
| ❷ | 음력 체크박스 | `Checkbox` (`sizeCheckboxMedium` 18 × 18) | shrinkWrap / visualDensity(-4,-4) | 활성: `kAgeAccent` / 체크: `Colors.white` / 테두리: `kAgeTextSecondary` w1.5 |
| ❷ | 체크박스↔라벨 간격 | `SizedBox` | — | width: 6 |
| ❷ | "음력" 레이블 | `Text` | `textStyleCheckboxLabelMedium` 14sp / w400 / height:1.0 | `kAgeTextSecondary` |

**❸ 피커 컨테이너**

| 속성 | 값 |
|------|----|
| 외부 패딩 | horizontal: 16 |
| 테두리 | `Colors.white` 50% / 1px / radius: 16 |
| 블러 | `BackdropFilter(ImageFilter.blur(sigmaX:12, sigmaY:12))` |
| 글라스 틴트 | `Colors.white` 22% |
| 높이 | 136 |
| 클리핑 | `ClipRRect(radius:15)` |

*선택 하이라이트 바*

| 속성 | 값 |
|------|----|
| 높이 | 44 |
| 배경 | `kAgePickerHighlight` 45% |
| 상하 테두리 | `Colors.white` 60% / 0.8px |

*상하 페이드 (ShaderMask)*

| 속성 | 값 |
|------|----|
| colors | `[transparent, white, white, transparent]` |
| stops | `[0.0, 0.34, 0.66, 1.0]` |
| blendMode | `BlendMode.dstIn` |

*스페큘러 하이라이트 (빛 반사)*

| 속성 | 값 |
|------|----|
| 위치 | top:0 / 좌우 full |
| 높이 | 36 |
| 그라디언트 | `Colors.white` 40% → 0% (topCenter→bottomCenter) |
| 비고 | `IgnorePointer` 적용 |

*피커 열 비율*

| 열 | flex | 범위 |
|----|------|------|
| 연도 | 4 | 1900 ~ 현재 연도 |
| 월 | 3 | 1 ~ 12 |
| 일 | 3 | 1 ~ 해당 월 최대일 |

**❹ 기준일 텍스트**

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❹ | "YYYY년 MM월 DD일 기준" | `Text` | `textStyleLabelLarge` 14sp / w500 | `kAgeTextSecondary` |

> 패딩: top:10 / bottom:8 / left:4

---

## `AgePicker` (드럼롤 피커)

`ListWheelScrollView.useDelegate` 기반. 피커 컨테이너 내부에서 사용.

| 속성 | 값 |
|------|----|
| itemExtent | 40 |
| physics | `FixedExtentScrollPhysics` |
| perspective | 0.003 |
| diameterRatio | 1.8 |
| 전환 효과 | `AnimatedDefaultTextStyle(duration: 150ms)` |

| 상태 | 폰트 | 색상 |
|------|------|------|
| 선택됨 | 18sp / w700 | `kAgeAccent` |
| 비선택 | 15sp / w400 | `kAgeTextPrimary` 50% |

---

## `LunarInfo` (음력 모드 시 표시)

피커 컨테이너 하단에 표시. 양력 변환 날짜 및 윤달 체크박스.

| 속성 | 값 |
|------|----|
| 컨테이너 | `Colors.white` 60% / radius:10 / border `kAgeDivider` 1px |
| 패딩 | horizontal:12 / vertical:8 |

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| — | "양력 " 레이블 | `Text` | `textStyleLabelMedium` 12sp / w600 | `kAgeTextSecondary` |
| — | 변환 날짜 | `Text` | `textStyleLabelMedium` 12sp / w400 | `kAgeTextPrimary` |
| — | "윤달" 레이블 | `Text` | `textStyleCheckboxLabelSmall` 12sp / **w600** / height:1.0 | `kAgeTextSecondary` |
| — | 라벨↔체크박스 간격 | `SizedBox` | — | width: 6 |
| — | 윤달 체크박스 | `Checkbox` (`sizeCheckboxSmall` 16 × 16) | shrinkWrap / visualDensity(-4,-4) | 활성: `kAgeAccent` / 체크: `Colors.white` / 테두리: `kAgeTextSecondary` w1.5 / 해당 연·월에 윤달 있을 때만 표시 |

---

## ❺ 구분선

`Divider(color: kAgeDivider, height: 1, thickness: 1)`

---

## ❻ AgeCard

**`AgeInfoCard` 공통 컨테이너** — 결과 카드 전체 공통 적용.

| 속성 | 값 |
|------|----|
| 배경 | `Colors.white` |
| radius | 16 |
| 그림자 | `kAgeCardShadow` 12% / blurRadius:12 / offset:(0,4) |

**카드 내부**

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❻ | 카드 패딩 | — | — | all: 20 |
| ❻ | 세는나이 숫자 | `Text` | `textStyleResult56` 56sp / w800 / height:1.0 | `kAgeAccent` |
| ❻ | "세" 단위 | `Text` | `textStyleResult22` 22sp / w600 / baseline 정렬 | `kAgeAccent` |
| ❻ | "세는 나이" 뱃지 | `Container` > `Text` | `textStyleLabelMedium` 12sp / w600 / padding h:8 v:3 / `radiusTag` 6 | `kAgeAccent` / 배경 `kAgeAccent` 12% |
| ❻ | 구분선 | `Divider` | height:1 | `kAgeDivider` |
| ❻ | 만 나이 · 연 나이 · 태어난 요일 | `AgeRow` | label: `textStyleBody` / value: `textStyleValue` | label: `kAgeTextSecondary` / value: `kAgeTextPrimary` |

> `AgeRow`: `Row(mainAxisAlignment: spaceBetween)` — 라벨 + 값

---

## ❼ 다음 생일 · 살아온 날 (`NextBirthdayCard` / `DaysLivedCard`)

두 카드 `Expanded` 동일 너비. `SizedBox(width:12)` 간격.

**NextBirthdayCard**

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❼ | 카드 높이 / 패딩 | — | — | h:110 / all:14 |
| ❼ | "다음 생일" 라벨 | `Text` | `textStyleLabelMedium` 12sp / w600 | `kAgeTextSecondary` |
| ❼ | D-N 숫자 | `Text` | `textStyleResult28` 28sp / w800 / height:1.0 | `kAgeAccent` |
| ❼ | 날짜 문자열 | `Text` | `textStyleLabelSmall` 10sp / w500 | `kAgeTextSecondary` |

> 오늘 생일인 경우: 🎂(`textStyleResult28` 28sp) + "오늘이 생일이에요!"(`textStyleSectionTitle` 13sp / w700 / `kAgeAccent`) · `Center` 배치

**DaysLivedCard**

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❼ | 카드 높이 / 패딩 | — | — | h:110 / all:14 |
| ❼ | "살아온 날" 라벨 | `Text` | `textStyleLabelMedium` 12sp / w600 | `kAgeTextSecondary` |
| ❼ | N일 숫자 | `Text` | `textStyleResult22` 22sp / w700 / height:1.0 | `kAgeTextPrimary` |
| ❼ | "약 N년 M개월" | `Text` | `textStyleLabelSmall` 10sp / w500 | `kAgeTextSecondary` |

---

## ❽ 띠 · 별자리 (`ZodiacCard` / `ConstellationCard`)

두 카드 `Expanded` 동일 너비. `SizedBox(width:12)` 간격.

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❽ | 카드 패딩 | — | — | all:14 |
| ❽ | "띠" · "별자리" 라벨 | `Text` | `textStyleLabelMedium` 12sp / w600 | `kAgeTextSecondary` |
| ❽ | 아이콘 | `Image.asset` | 36×36 | — |
| ❽ | 이름 | `Text` | `textStyleValue` 16sp / w700 | `kAgeTextPrimary` |
| — | 라벨↔아이콘 간격 | `SizedBox` | — | height:12 |
| — | 아이콘↔이름 간격 | `SizedBox` | — | width:8 |

---

## EmptyState

미래 날짜 선택 시 결과 영역 대신 표시.

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| — | 안내 문구 | `Center` > `Text` | 15sp / w400 | `kAgeTextSecondary` |

> 내용: "미래 날짜는 계산할 수 없어요"

---

## 색상 팔레트

| 상수 | hex / 값 | 용도 |
|------|---------|------|
| `kAgeBg1` | `#FFF8F0` | 배경 그라디언트 상단 (크림) |
| `kAgeBg2` | `#FFE4CC` | 배경 그라디언트 하단 (복숭아) · 스크롤 페이드 색상 |
| `kAgeAccent` | `#D4845A` | 강조 색상 (세는나이, D-N, 체크박스, 뱃지) |
| `kAgeAccentLight` | `#F0A87A` | 보조 강조 |
| `kAgeTextPrimary` | `#3D2B1F` | 주 텍스트 (dark brown) |
| `kAgeTextSecondary` | `#8B6651` | 보조 텍스트 (라벨, 단위) |
| `kAgePickerHighlight` | `#FFDCB8` | 피커 선택 하이라이트 바 |
| `kAgeCardShadow` | `#D4845A` | 카드 그림자 (`kAgeAccent`와 동일) |
| `kAgeDivider` | `#E8C9B0` | 구분선 (화면·카드 내부·LunarInfo 테두리) |
