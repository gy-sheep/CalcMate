# 할인 계산기 — 화면 디자인

> 구현 참조용. 레이아웃·위젯·스타일·색상을 한 곳에서 확인한다.
> 색상 상수는 `discount_calculator_colors.dart` 참조.

---

## 배경

| 속성 | 값 |
|------|----|
| 종류 | `LinearGradient` · topCenter → bottomCenter |
| 상단 | `kDiscountGradientTop` #5580D0 |
| 하단 | `kDiscountGradientBottom` #3A5CB8 |
| 비고 | `extendBodyBehindAppBar: true` → 그라디언트가 상태바 뒤까지 연장 |

---

## 레이아웃 & 스타일

```
┌──────────────────────────────────┐
│  ←  할인 계산기                  │  ← ❶ AppBar
├──────────────────────────────────┤
│  원가                            │  ← ❷ 원가 입력 필드
│  [                 120,000 ]     │
│                                  │
│  할인율                          │  ← ❸ 할인율 섹션
│  [ 5% ][ 10% ][ 20% ][ 30% ]...  │     ← 빠른 선택 칩
│  [                      30   % ] │     ← 직접 입력 필드
│                                  │
│  ＋ 추가 할인 쌓기               │  ← ❹ 추가 할인 토글
│  (토글 시 칩 + 입력 필드 표시)   │
│                                  │
│  ┌──────────────────────────┐    │  ← ❺ 결과 카드 (값 있을 때만)
│  │ ₩120,000 → ₩84,000      │    │
│  │ ─────────────────────── │    │
│  │ 절약액         -₩36,000 │    │
│  │ 할인율              30% │    │
│  │                          │    │
│  │ 최종가                   │    │
│  │                 ₩84,000 │    │
│  └──────────────────────────┘    │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  ← 스크롤 페이드
├──────────────────────────────────┤  ← ❻ 구분선
│  7  │  8  │  9                  │  ← ❼ 숫자 키패드
│  4  │  5  │  6                  │
│  1  │  2  │  3                  │
│  00 │  0  │  ⌫                  │
└──────────────────────────────────┘
```

> **구조 메모**: `ScrollFadeView`(Expanded) + `Divider` + `_DiscountKeypad` + `AdBannerPlaceholder` 의 세로 구성.
> `ScrollFadeView` 내부: `_OriginalPriceField` → `_DiscountRateSection` → `_ExtraDiscountSection` → `_ResultCard`(조건부).
> `_activeField` 상태(`originalPrice` / `discountRate` / `extraDiscountRate`)에 따라 키패드 입력 대상이 달라진다.
> 결과 카드는 원가 > 0 AND 할인율 > 0 일 때만 표시된다.

---

## ❶ AppBar

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❶ | 뒤로가기 아이콘 | `Icon(arrow_back_ios)` | `sizeAppBarBackIcon` 20 | `Colors.white` |
| ❶ | 타이틀 | `Text` | `textStyleAppBarTitle` 18sp / w600 | `Colors.white` |

> `backgroundColor: Colors.transparent` / `elevation: 0` / `scrolledUnderElevation: 0` / `centerTitle: false`

---

## ❷ 원가 입력 필드 (`_OriginalPriceField`)

```
┌──────────────────────────────────────┐  radius: radiusInput 12 / padding: paddingInputField h20 v14
│                           120,000   │
└──────────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❷ | 레이블 "원가" | `Text` | `textStyleLabelLarge` 14sp / w600 / letterSpacing:0.5 | `kDiscountTextSecondary` |
| ❷ | 필드 배경 | `AnimatedContainer` | — | `kDiscountFieldBg` |
| ❷ | 필드 테두리 (비활성) | `Border.all` w1 | — | `kDiscountFieldBorder` |
| ❷ | 필드 테두리 (활성) | `Border.all` w1.5 | — | `kDiscountFieldBorderActive` |
| ❷ | 통화 기호 | `Text` (기호 있을 때만 표시) | `textStyleResult18` 18sp / w500 | 활성: `kDiscountAccent` / 비활성: `kDiscountTextSecondary` |
| ❷ | 금액 텍스트 | `Text` | `textStyleResult24` 24sp / w300 | 입력 전: `kDiscountTextSecondary` / 입력 후: `kDiscountTextPrimary` |

> 금액은 3자리 콤마 포맷. 최대 9,999,999,999. 소수점 입력 불가.
> 통화 기호는 `_getCurrencySymbol()`로 결정. 기호 없는 국가는 텍스트 미표시.
> 필드 탭 시 `_activeField = originalPrice`로 전환.

---

## ❸ 할인율 섹션 (`_DiscountRateSection`)

```
[ 5% ][ 10% ][ 20% ][ 30% ][ 50% ]   ← 가로 스크롤 칩
┌──────────────────────────────────┐
│                            30  % │  ← 직접 입력 필드
└──────────────────────────────────┘
```

**빠른 선택 칩**

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | 레이블 "할인율" | `Text` | `textStyleLabelLarge` 14sp / w600 / letterSpacing:0.5 | `kDiscountTextSecondary` |
| ❸ | 칩 (비활성) | `AnimatedContainer` | `textStyleChip` 14sp / w400 / `paddingChip` h14 v8 | 텍스트: `kDiscountChipText` / 배경: `kDiscountChipBg` / 테두리: `kDiscountFieldBorder` |
| ❸ | 칩 (활성) | `AnimatedContainer` | `textStyleChip` 14sp / w600 / `paddingChip` h14 v8 | 텍스트: `kDiscountChipActiveText` / 배경: `kDiscountChipActiveBg` / 테두리: `kDiscountChipActiveBg` |
| ❸ | 칩 border radius | — | — | `radiusChip` 20 |
| ❸ | 칩 간격 | `Padding` | — | right: 8 (마지막 칩 제외) |

**직접 입력 필드**

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | 필드 배경 | `AnimatedContainer` | `paddingInputField` h20 v14 | `kDiscountFieldBg` |
| ❸ | 필드 테두리 (비활성 / 활성) | — | — | `kDiscountFieldBorder` w1 / `kDiscountFieldBorderActive` w1.5 |
| ❸ | 할인율 텍스트 | `Text` | `textStyleResult24` 24sp / w300 | 입력 전: `kDiscountTextSecondary` / 입력 후: `kDiscountTextPrimary` |
| ❸ | % 기호 | `Text` | `textStyleResult18` 18sp / w500 | 활성: `kDiscountAccent` / 비활성: `kDiscountTextSecondary` |

> 할인율은 0–99.9 범위. 칩 선택 시 해당 값으로 직접 입력 필드 동기화.
> 필드 탭 시 `_activeField = discountRate`로 전환.

---

## ❹ 추가 할인 섹션 (`_ExtraDiscountSection`)

```
＋ 추가 할인 쌓기                   ← 토글 버튼 (접힘 상태)

── 펼침 상태 ──────────────────────
－ 추가 할인 제거
[ 5% ][ 10% ][ 20% ][ 30% ][ 50% ]
┌──────────────────────────────────┐
│                            10  % │
└──────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❹ | 토글 아이콘 | `Icon(add_circle_outline / remove_circle_outline)` | `sizeIconSmall` 20 | `kDiscountAccent` |
| ❹ | 토글 텍스트 | `Text` | `textStyleSectionTitle` 13sp / w600 / letterSpacing:0.3 | `kDiscountAccent` |
| ❹ | 칩 / 입력 필드 | ❸과 동일 구조 | — | — |

> 추가 할인 토글 시 `_activeField = extraDiscountRate`로 자동 전환.
> 추가 할인 제거 시 `_extraRate` 초기화 후 `_activeField = discountRate`로 복귀.

---

## ❺ 결과 카드 (`_ResultCard`)

원가 > 0 AND 할인율 > 0 일 때만 표시.

```
┌──────────────────────────────────────────┐  padding: paddingCard all 20 / radius: radiusCard 16
│  ₩120,000  →  ₩84,000                   │  ← 원가 → 최종가 (취소선)
│  ──────────────────────────────────────  │
│  절약액                     -₩36,000    │
│  할인율                          30%    │  (추가 할인 시: "실질 할인율 (30% + 10%)")
│                                          │
│  최종가                                  │
│                              ₩84,000    │  ← 큰 숫자
└──────────────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❺ | 카드 배경 | `Container` | — | `kDiscountCardBg` |
| ❺ | 카드 테두리 | `Border.all` | — | `kDiscountCardBorder` |
| ❺ | 원가 (취소선) | `Text` | `textStyleBody` 16sp / w400 / lineThrough | `kDiscountTextSecondary` |
| ❺ | 화살표 | `Icon(arrow_forward)` | `sizeIconXSmall` 16 | `kDiscountTextSecondary` |
| ❺ | 최종가 (행 내) | `Text` | `textStyleBody` 16sp / w500 | `kDiscountTextPrimary` |
| ❺ | 카드 내 구분선 | `Divider` | — | `kDiscountCardBorder` · height:1 |
| ❺ | "절약액" 레이블 | `Text` | `textStyleBody` 16sp / w400 | `kDiscountTextSecondary` |
| ❺ | 절약액 수치 | `Text` | `textStyleBody` 16sp / w600 | `kDiscountTextSavings` |
| ❺ | 할인율 레이블 | `Text` | `textStyleBody` 16sp / w400 | `kDiscountTextSecondary` |
| ❺ | 할인율 수치 | `Text` | `textStyleBody` 16sp / w500 | `kDiscountTextSecondary` |
| ❺ | "최종가" 레이블 | `Text` | `textStyleBody` 16sp / w400 | `kDiscountTextSecondary` |
| ❺ | 최종가 금액 | `Text` | `textStyleResult36` 36sp / w300 / letterSpacing:-1 | `kDiscountTextFinalPrice` |

> 추가 할인 적용 시 할인율 레이블이 "실질 할인율 (30% + 10%)" 형태로 표시.
> 금액이 표시되는 모든 위치(원가 취소선·최종가 행·절약액·최종가 대형)에 `_getCurrencySymbol()` 반환값이 앞에 붙는다. 기호 없는 국가는 숫자만 표시.

---

## ❻ 구분선

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❻ | 구분선 | `Divider` | — | `kDiscountDivider` · thickness:0.5 · height:1 |

---

## ❼ 숫자 키패드 (`_DiscountKeypad`)

3×4 레이아웃. AC 없음. ⌫(백스페이스)만 기능 버튼.

```
┌────┬────┬────┐
│  7 │  8 │  9 │
├────┼────┼────┤
│  4 │  5 │  6 │
├────┼────┼────┤
│  1 │  2 │  3 │
├────┼────┼────┤
│ 00 │  0 │  ⌫ │
└────┴────┴────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❼ | 0~9 · 00 | `_KeypadButton` > `Text` | `textStyleKeypadNumber` 22sp / w400 | `kDiscountKeyNumber` |
| ❼ | ⌫ | `_KeypadButton` > `Icon(backspace_outlined)` | `sizeKeypadBackspace` 26 | `kDiscountKeyFunction` |
| ❼ | 버튼 높이 | `SizedBox` | — | `heightButtonLarge` 68 |
| ❼ | 버튼 터치 효과 | `Material` + `InkWell` | — | splashColor / highlightColor: `Colors.white10` |

> 원가 입력 시 소수점(.) 불가. 할인율 입력 시 정수만 가능 (최대 99).

---

## 스크롤 페이드

결과 카드가 화면을 초과할 때 하단 페이드 표시.

| 속성 | 값 |
|------|----|
| 위젯 | `ScrollFadeView` |
| fadeColor | `kDiscountGradientBottom` #3A5CB8 |
| 패딩 | horizontal: `paddingScreenH` 16 / vertical: 20 |

---

## 색상 팔레트

| 상수 | hex / 값 | 용도 |
|------|---------|------|
| `kDiscountGradientTop` | `#5580D0` | 배경 그라디언트 상단 (퍼플블루) |
| `kDiscountGradientBottom` | `#3A5CB8` | 배경 그라디언트 하단 (딥 퍼플블루) |
| `kDiscountAccent` | `#FFB8D6` | 활성 테두리 · 칩 배경 · 토글 버튼 |
| `kDiscountAccentSoft` | `#FFB8D6` 20% | 소프트 액센트 (예비) |
| `kDiscountChipBg` | `Colors.white` 13% | 비활성 칩 배경 |
| `kDiscountChipActiveBg` | `#FFB8D6` | 활성 칩 배경 |
| `kDiscountChipText` | `Colors.white` 80% | 비활성 칩 텍스트 |
| `kDiscountChipActiveText` | `Colors.white` | 활성 칩 텍스트 |
| `kDiscountFieldBg` | `Colors.white` 9% | 입력 필드 배경 |
| `kDiscountFieldBorder` | `Colors.white` 25% | 입력 필드 테두리 (비활성) |
| `kDiscountFieldBorderActive` | `#FFB8D6` | 입력 필드 테두리 (활성) |
| `kDiscountCardBg` | `Colors.white` 13% | 결과 카드 배경 |
| `kDiscountCardBorder` | `Colors.white` 20% | 결과 카드 테두리 |
| `kDiscountDivider` | `Colors.white` 20% | 키패드 구분선 |
| `kDiscountTextPrimary` | `Colors.white` | 주 텍스트 |
| `kDiscountTextSecondary` | `Colors.white` 80% | 보조 텍스트 · 레이블 |
| `kDiscountTextSavings` | `#FFB8D6` | 절약액 강조 텍스트 |
| `kDiscountTextFinalPrice` | `Colors.white` | 결과 카드 최종가 |
| `kDiscountKeyNumber` | `Colors.white` | 숫자 버튼 텍스트 |
| `kDiscountKeyFunction` | `Colors.white` 80% | ⌫ 버튼 아이콘 |
| `kDiscountKeySpecial` | `#FFB8D6` | 특수 버튼 (예비) |
