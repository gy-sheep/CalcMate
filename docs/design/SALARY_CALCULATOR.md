# 실수령액 계산기 — 화면 디자인

> 구현 참조용. 레이아웃·위젯·스타일·색상을 한 곳에서 확인한다.
> 색상 상수는 `net_pay_calculator_colors.dart` 참조.

---

## 배경

| 속성 | 값 |
|------|-----|
| 종류 | `LinearGradient` · topCenter → bottomCenter |
| 상단 | `kNetPayBgTop` #F5F0E6 (따뜻한 크림) |
| 하단 | `kNetPayBgBottom` #EDE8D8 (어두운 크림) |
| 비고 | `extendBodyBehindAppBar: true` → 그라디언트가 상태바 뒤까지 연장 |

---

## 레이아웃 & 스타일

```
┌──────────────────────────────────┐
│  ←  실수령액 계산기               │  ← ❶ AppBar
├──────────────────────────────────┤
│     월급      │      연봉         │  ← ❷ 탭바
├──────────────────────────────────┤  ↑
│                                  │  │
│  ┌────────────────────────────┐  │  │  ← ❸ 급여 입력 카드 (슬라이더 포함)
│  │ 연봉                  ✎   │  │  │
│  │    45,000,000 원          │  │  │
│  │                월 3,750,000│  │  │  (연봉 모드일 때 월 환산 표시)
│  │  ●━━━━━━━━━━━○─────────── │  │  │  ← 슬라이더
│  │  2,400만             1억  │  │  │
│  └────────────────────────────┘  │  │
│                                  │  │
│  ┌────────────────────────────┐  │  │  ← ❺ 결과 카드
│  │ 실수령액                   │  │  │
│  │              3,737,310 원  │  │  │  (금액 우측 정렬)
│  │        연 환산 44,847,720 원│  │  │
│  └────────────────────────────┘  │  │
│                                  │  │
│  ┌────────────────────────────┐  │  │  ← ❻ 공제 내역 카드
│  │ 공제 합계          512,690 │  │  │
│  │ ─────────────────────────  │  │  │
│  │ 국민연금           185,850 │  │  │
│  │ 건강보험           132,740 │  │  │
│  │ 장기요양            17,190 │  │  │
│  │ 고용보험            33,750 │  │  │
│  │ 소득세             131,650 │  │  │
│  │ 지방소득세          13,165 │  │  ↓
│  └────────────────────────────┘  │
├──────────────────────────────────┤
│  부양가족 수  ⓘ   [−]  1명  [+]  │  ← ❼ 부양가족 바 (고정 하단)
└──────────────────────────────────┘
```

> **구조 메모**: `Scaffold` + `Stack(배경그라디언트 / SafeArea(Column) / BlurStatusBarOverlay)`.
> SafeArea Column = `AppAnimatedTabBar` + `Expanded(ScrollFadeView)` + `_DependentsBar`.
> ScrollFadeView 내부 = 급여카드(슬라이더 포함) + 결과카드 + 공제카드 세로 배열.

---

## ❶ AppBar

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❶ | 뒤로가기 아이콘 | `Icon(arrow_back_ios)` | `sizeAppBarBackIcon` 20 | `kNetPayTextPrimary` |
| ❶ | 타이틀 | `Text` | `textStyleAppBarTitle` 20sp / w700 | `kNetPayTextPrimary` |

> `backgroundColor: Colors.transparent` / `elevation: 0` / `scrolledUnderElevation: 0`
> `centerTitle: false` / `systemOverlayStyle: SystemUiOverlayStyle.dark`

---

## ❷ 탭바 (`AppAnimatedTabBar`)

탭 2개: `['월급', '연봉']`. PageController 오프셋과 실시간 연동.

| 속성 | 값 |
|------|----|
| accentColor | `kNetPayGold` #8B6914 |
| dividerColor | `kNetPayTabDivider` #CFC0A0 |
| inactiveColor | `kNetPayTextSecondary` #6B7A99 |

**탭 레이블 상태**

| 상태 | 색상 |
|------|------|
| 활성 | `kNetPayGold` w700 |
| 비활성 | `kNetPayTextSecondary` w400 |

---

## ❸ 급여 입력 카드 (`_SalaryDisplay`)

탭 전체가 `GestureDetector` → 탭 시 키패드 모달 열림. 슬라이더 포함.

```
┌──────────────────────────────────────┐  padding: CmInputCard.padding (h:20 v:18)
│ 연봉                            ✎   │  ← 타이틀 + 편집 아이콘
│                                      │
│                45,000,000 원         │  ← 금액 (우측 정렬)
│                     월 3,750,000 원  │  ← 연봉 모드일 때만 표시
│                                      │
│  ●━━━━━━━━━━━━━○───────────────      │  ← 슬라이더
│  2,400만                       1억  │
└──────────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | 컨테이너 | `Container` | `CmInputCard.padding` / `CmInputCard.radius` 16 | bg: `kNetPayCardBg` / border: `kNetPayCardBorder` / shadow: `kNetPayCardShadow` blur:8 |
| ❸ | 타이틀 | `Text` (좌) | `CmInputCard.titleText` 13sp / w600 | `kNetPayTextSecondary` |
| ❸ | 편집 아이콘 | `Icon(edit_outlined)` | `CmIcon.inputCard` 16 | `kNetPayTextSecondary` |
| ❸ | 금액 | `Text` (우측) | `CmInputCard.inputText` 32sp / w300 | `kNetPayTextPrimary` |
| ❸ | "원" 단위 | `Text` | `CmInputCard.unitText` 16sp / w400 | `kNetPayTextSecondary` |
| ❸ | 월 환산 (연봉 모드) | `Text` (우측) | `CmInputCard.subText` 14sp / w400 | `kNetPayTextSecondary` |
| ❸ | 슬라이더 | `SliderTheme` + `Slider` | `CmSlider.*` | `kNetPayGold` / `kNetPaySliderTrack` |
| ❸ | 최소·최대 레이블 | `Text` | `CmSlider.rangeLabel` 14sp / w500 | `kNetPayTextSecondary` |

> 타이틀↔금액: `CmInputCard.titleSpacing` 8dp / 금액↔월환산: `CmInputCard.subSpacing` 4dp
> 월환산↔슬라이더: 12dp / 금액 Row: `mainAxisAlignment: end`

**슬라이더 범위**

| 모드 | 최솟값 | 최댓값 | 레이블 |
|------|--------|--------|--------|
| 월급 | 1,000,000 | 10,000,000 | 100만 / 1,000만 |
| 연봉 | 24,000,000 | 100,000,000 | 2,400만 / 1억 |

> 범위 초과 직접입력 시 슬라이더는 최대/최소 끝 고정, 금액 표시는 입력값 유지

---

## ❺ 결과 카드 (`_ResultCard`)

```
┌──────────────────────────────────────┐  padding: 20
│ 실수령액                              │  ← 레이블 (좌측)
│                                      │
│                    3,737,310 원      │  ← 금액 + 단위 (우측 정렬)
│              연 환산 44,847,720 원   │  ← 보조 텍스트 (우측)
└──────────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❻ | 컨테이너 | `Container` | padding:`paddingCard` 20 / radius:`radiusCard` 16 | bg: `kNetPayResultBg` #EEE4CC / border: `kNetPayResultBorder` #CDB99A / shadow: `kNetPayCardShadow` blur:8 |
| ❻ | "실수령액" 레이블 | `Text` (좌측 `Align`) | `textStyleSectionTitle` 13sp / w600 | `kNetPayTextSecondary` |
| ❻ | 금액 | `Text` (우측) | `textStyleResult48` 48sp / w400 | `kNetPayGold` #8B6914 |
| ❻ | "원" 단위 | `Text` | `textStyleBody` 16sp / w400 | `kNetPayTextSecondary` |
| ❻ | 보조 텍스트 | `Text` (우측) | `textStyleCaption` 14sp / w400 | `kNetPayTextSecondary` |

> 레이블→금액 Row: 8dp / 금액↔"원": 6dp, baseline 정렬 ("원"은 bottom padding 6dp)
> 금액 Row: `mainAxisAlignment: end` / `crossAxisAlignment: end`
> Column: `crossAxisAlignment: end`
> 보조 텍스트: 금액 Row 아래 6dp / 입력값 0일 때 `—` 표시 (보조 텍스트 숨김)

**보조 텍스트 내용**

| 모드 | 보조 레이블 | 값 |
|------|------------|-----|
| 월급 | "연 환산" | 월 실수령 × 12 |
| 연봉 | "연 실수령" | 월 실수령 × 12 |

---

## ❻ 공제 내역 카드 (`_DeductionCard`)

```
┌──────────────────────────────────────┐
│  공제 합계              512,690 원    │  ← 헤더 (h:14 v:14)
├──────────────────────────────────────┤  ← 구분선
│  국민연금               185,850 원   │
├──────────────────────────────────────┤
│  건강보험               132,740 원   │
├──────────────────────────────────────┤
│  장기요양                17,190 원   │
├──────────────────────────────────────┤
│  고용보험                33,750 원   │
├──────────────────────────────────────┤
│  소득세                 131,650 원   │
├──────────────────────────────────────┤
│  지방소득세               13,165 원  │
└──────────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❼ | 컨테이너 | `Container` | radius:`radiusCard` 16 | bg: `kNetPayDeductionBg` #F0E8D4 / border: `kNetPayDeductionLine` #DDD0B0 / shadow: `kNetPayCardShadow` blur:8 |
| ❼ | "공제 합계" 레이블 | `Text` | `textStyleSectionTitle` 13sp / w600 | `kNetPayTextSecondary` |
| ❼ | 공제 합계 금액 | `Text` | `textStyleValue` 16sp / w600 | `kNetPayTextPrimary` |
| ❼ | 헤더 구분선 | `Container` h:1 | — | `kNetPayDeductionLine` |
| ❼ | 항목 레이블 | `Text` | `textStyleCaption` 14sp / w400 | `kNetPayTextSecondary` |
| ❼ | 항목 금액 | `Text` | `textStyleValue` 16sp (fontSize:15) / w600 | `kNetPayTextPrimary` |
| ❼ | 항목 구분선 | `Container` h:1 | margin: h:16 | `kNetPayDeductionLine` |

> 헤더 패딩: h:16 v:14 / 항목 패딩: h:16 v:12
> 마지막 항목 아래 구분선 없음 / 입력값 0이면 모든 금액 `—` 표시

**공제 항목 순서**

| 순서 | 항목 |
|------|------|
| 1 | 국민연금 |
| 2 | 건강보험 |
| 3 | 장기요양 |
| 4 | 고용보험 |
| 5 | 소득세 |
| 6 | 지방소득세 |

---

## ❼ 부양가족 바 (`_DependentsBar`) — 고정 하단

```
┌──────────────────────────────────────┐
│  부양가족 수  ⓘ         [−]  1명  [+] │  padding: h:20 v:12
└──────────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❼ | 컨테이너 | `Container` | padding: h:20 v:12 | bg: `kNetPayCardBg` / 상단 border: `kNetPayCardBorder` |
| ❼ | "부양가족 수" | `Text` | `rowLabel` 16sp / w500 | `kNetPayTextPrimary` |
| ❼ | 툴팁 아이콘 | `Tooltip` + `Icon(info_outline)` | `CmIcon.tooltip` 16 | `kNetPayTextSecondary` |
| ❼ | 숫자 "N명" | `Text` (w:`CmStepValue.width` 44, 가운데) | `CmStepValue.text` 18sp / w600 | `kNetPayGold` |
| ❼ | [−] [+] 컨테이너 | `CmRoundButton.medium` (w:28 h:28 / radius:14) | — | 활성: bg `kNetPayGoldSoft` / border `kNetPayGold` 40% / 비활성: bg 투명 / border `kNetPayTextDisabled` |
| ❼ | [−] [+] 아이콘 | `Icon(remove / add)` | `CmRoundButton.medium.iconSize` 18 | 활성: `kNetPayGold` / 비활성: `kNetPayTextDisabled` |

> 툴팁 메시지: "본인 포함 기준, 소득세 계산에 반영됩니다"
> 범위: 1 ~ 11명 / 경계값에서 해당 버튼 비활성화
> "부양가족 수"↔아이콘: 4dp / 숫자↔버튼 좌우: 균등 배치

---

## 키패드 모달 (`showModalBottomSheet`)

급여 입력 카드 탭 시 표시. 현재 급여값 초기 표시.

```
┌──────────────────────────────────┐
│          ━━━━━━                  │  ← 핸들
│  ┌────────────────────────────┐  │  ← 입력 표시
│  │          45,000,000 원     │  │  (우측 정렬)
│  └────────────────────────────┘  │
│  ┌───┐ ┌───┐ ┌───┐             │
│  │ 7 │ │ 8 │ │ 9 │             │  ← 키패드 3열
│  ├───┤ ├───┤ ├───┤             │
│  │ 4 │ │ 5 │ │ 6 │             │
│  ├───┤ ├───┤ ├───┤             │
│  │ 1 │ │ 2 │ │ 3 │             │
│  ├───┤ ├───┤ ├───┤             │
│  │00 │ │ 0 │ │ ⌫ │            │
│  └───┘ └───┘ └───┘             │
│  ┌────────── 확인 ──────────┐  │  ← 확인 버튼
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| — | 시트 배경 | `Container` | radius: top `radiusBottomSheet` 20 / padding: fromLTRB(16,12,16,0) | `kNetPayBgTop` |
| — | 핸들 | `Container` | w:36 h:4 / radius:2 / bottom margin:20 | `kNetPayCardBorder` |
| — | 입력 표시 컨테이너 | `Container` | padding: h:20 v:16 / radius:`radiusInput` 12 | bg: `kNetPayDeductionBg` / border: `kNetPayGold` 40% |
| — | 입력 금액 | `Text` (우측) | `textStyleResult36` 36sp / w300 | `kNetPayTextPrimary` |
| — | 0~9 · 00 버튼 컨테이너 | `Container` | h:56 / radius:12 | bg: `kNetPayCardBg` / border: `kNetPayCardBorder` |
| — | 0~9 · 00 텍스트 | `Text` | `textStyleKeypadNumber` 22sp / w400 | `kNetPayTextPrimary` |
| — | ⌫ 버튼 컨테이너 | `Container` | h:56 / radius:12 | bg: `kNetPayGoldSoft` / border: `kNetPayGold` 40% |
| — | ⌫ 아이콘 | `Icon(backspace_outlined)` | `sizeKeypadBackspace` 26 | `kNetPayGold` |
| — | 확인 버튼 | `ElevatedButton` | h:52 / radius:12 | bg: `kNetPayAccent` #8B1A2E / fg: `Colors.white` |
| — | 확인 텍스트 | `Text` | `textStyleBody` 16sp / w600 | `Colors.white` |

> 키패드 행 간격: bottom 8dp / 확인 버튼 상단 margin: 8dp
> 확인 버튼 하단 여백: `MediaQuery.padding.bottom + 16`
> 최대 입력 자리수: 10자리 / 첫 자리 0 입력 불가 / ⌫ 롱프레스 → 전체 삭제

---

## 스크롤 페이드

| 속성 | 값 |
|------|----|
| 위젯 | `ScrollFadeView` (공통 위젯) |
| fadeColor | `kNetPayBgBottom` |
| 수평 패딩 | `paddingScreenH` 16 |

---

## 상단 블러 오버레이

| 속성 | 값 |
|------|----|
| 위젯 | `BlurStatusBarOverlay` |
| isVisible | `true` |
| backgroundColor | `kNetPayBgTop` |

---

## 간격 요약

| 위치 | 값 |
|------|----|
| 화면 수평 패딩 | `paddingScreenH` 16 |
| 스크롤 최상단 여백 | 28 |
| 급여 카드 내부 패딩 | `CmInputCard.padding` h:20 v:18 |
| 급여 카드↔결과 카드 | 28 |
| 결과 카드↔공제 카드 | 12 |
| 공제 카드↔스크롤 끝 | 24 |
| 결과 카드 내부 패딩 | `CmResultCard.padding` 20 |
| 부양가족 바 패딩 | h:20 v:12 |

---

## 색상 팔레트

| 상수 | hex / 값 | 용도 |
|------|---------|------|
| `kNetPayBgTop` | `#F5F0E6` | 배경 상단·키패드 시트 배경 |
| `kNetPayBgBottom` | `#EDE8D8` | 배경 하단·스크롤 페이드 |
| `kNetPayAccent` | `#8B1A2E` | 키패드 확인 버튼 (딥 버건디) |
| `kNetPayAccentSoft` | `#148B1A2E` (8%) | — |
| `kNetPayAccentGlow` | `#338B1A2E` (20%) | — |
| `kNetPayGold` | `#8B6914` | 탭 활성·슬라이더·결과 금액·조절 버튼·부양가족 숫자 (딥 앤틱 골드) |
| `kNetPayGoldSoft` | `#188B6914` (9%) | 단위 버튼 배경·슬라이더 오버레이·부양가족 버튼 활성 배경 |
| `kNetPayGoldBorder` | `#558B6914` (33%) | — |
| `kNetPayCardBg` | `#F5EFDF` | 급여 카드·부양가족 바·키패드 숫자 버튼 배경 (양피지) |
| `kNetPayCardBorder` | `#D8C9A8` | 카드 테두리·핸들 |
| `kNetPayCardShadow` | `#14000000` (8%) | 카드 그림자 |
| `kNetPayTabDivider` | `#CFC0A0` | 탭 구분선 |
| `kNetPayDivider` | `#E4D8BC` | — |
| `kNetPayTextPrimary` | `#1A2540` | 주 텍스트 (네이비 잉크) |
| `kNetPayTextSecondary` | `#6B7A99` | 보조 텍스트 |
| `kNetPayTextDisabled` | `#B8AE98` | 비활성 버튼·텍스트 |
| `kNetPaySliderTrack` | `#DDD0B0` | 슬라이더 비활성 트랙 |
| `kNetPayResultBg` | `#EEE4CC` | 결과 카드 배경 (진한 양피지) |
| `kNetPayResultBorder` | `#CDB99A` | 결과 카드 테두리 |
| `kNetPayDeductionBg` | `#F0E8D4` | 공제 카드 배경·키패드 입력 표시 배경 |
| `kNetPayDeductionLine` | `#DDD0B0` | 공제 카드 구분선·항목 구분선 |
