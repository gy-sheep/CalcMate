# 부가세 계산기 — 화면 디자인

> 구현 참조용. 레이아웃·위젯·스타일·색상을 한 곳에서 확인한다.
> 색상 상수는 `vat_calculator_colors.dart` 참조.

---

## 배경

| 속성 | 값 |
|------|----|
| 종류 | `LinearGradient` · topCenter → bottomCenter |
| 상단 | `kVatGradientTop` #141218 |
| 하단 | `kVatGradientBottom` #231F2E |
| 비고 | `extendBodyBehindAppBar: true` → 그라디언트가 상태바 뒤까지 연장 |

---

## 레이아웃 & 스타일

```
┌──────────────────────────────────┐
│  ←  부가세 계산기                │  ← ❶ AppBar
├──────────────────────────────────┤
│  ╭~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~╮  ← ❷ 영수증 카드 (ReceiptCard)
│  │              120,000          │     상단/하단 스캘럽(톱니) 테두리
│  │  ····························  │     ← ❸ 점선 구분선
│  │  ☐  부가세 별도              │     ← ❹ 모드 체크박스
│  │  ····························  │     ← ❸ 점선 구분선
│  │                                │
│  │  공급가액          109,091    │     ← ❺ 세액 명세 행
│  │  부가세 (10% ℹ)    10,909    │     ← ❻ 세율 행 (탭하여 직접 편집)
│  │  ────────────────────────────  │     ← ❼ 실선 구분선
│  │  합계             120,000    │     ← ❽ 합계 행
│  ╰~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~╯
├──────────────────────────────────┤  ← ❾ 구분선
│  7  │   8  │   9  │  ⌫         │  ← ❿ 숫자·기능 버튼
│  4  │   5  │   6  │  AC        │
│  1  │   2  │   3  │            │
│  00 │   0  │   .  │  ↵ (= 2행) │  ← ⓫ = 버튼 (강조 배경, 2행 병합)
└──────────────────────────────────┘
```

> **구조 메모**: `ReceiptCard`(Expanded) + `Divider` + `VatNumberPad` + `AdBannerPlaceholder` 의 세로 구성.
> 영수증 카드는 `ClipPath(ReceiptClipper)`로 상단·하단에 스캘럽(반원 톱니) 효과를 적용한다.
> 세율 행의 `%` 수치를 탭하면 `InputTarget.taxRate`로 전환되어 키패드 입력이 세율을 수정한다.
> 키패드는 연산자 버튼 없이 숫자·기능 버튼만 구성되며, `=` 버튼이 우측 하단 2행을 병합한다.

---

## ❶ AppBar

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❶ | 뒤로가기 아이콘 | `Icon(arrow_back_ios)` | `sizeAppBarBackIcon` 20 | `Colors.white` |
| ❶ | 타이틀 | `Text` | `textStyleAppBarTitle` 18sp / w600 | `Colors.white` |

> `backgroundColor: Colors.transparent` / `elevation: 0` / `scrolledUnderElevation: 0` / `centerTitle: false`

---

## ❷ 영수증 카드 (`ReceiptCard`)

**카드 컨테이너**

| 속성 | 값 |
|------|----|
| 외부 패딩 | horizontal: 20 / vertical: 8 |
| 클리핑 | `ClipPath(ReceiptClipper)` — 반원 반지름: 5 / 반원 간격: 6 |
| 배경색 | `kVatReceiptBg` #F5F5F0 (연한 크림색) |
| 그림자 | `Colors.black` 30% / blurRadius: 16 / offset: (0, 4) |
| 내부 패딩 | fromLTRB(24, 28, 24, 28) |

**카드 내부 구성 요소**

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❷ | 입력 디스플레이 | `FittedBox` > `Text` | `textStyleResult40` 40sp / w300 / letterSpacing:-1 | `kVatReceiptText` #2C2C2C |
| ❸ | 점선 구분선 | `CustomPaint(DashedLinePainter)` | — | `kVatReceiptDash` #CCCCCC / dash:5 space:3 |
| ❹ | 체크박스 | `Checkbox` (`sizeCheckboxLarge` 20 × 20) | shrinkWrap / visualDensity(-4,-4) | 활성배경: `kVatReceiptText` / 체크: `kVatReceiptBg` / 테두리: `kVatReceiptSecondary` w1.5 |
| ❹ | 체크박스↔라벨 간격 | `SizedBox` | — | width: 6 |
| ❹ | 체크박스 레이블 | `Text` | `textStyleCheckboxLabelLarge` 16sp / w400 / height:1.0 | `kVatReceiptSecondary` #888888 |
| ❺ | 공급가액 라벨 | `ReceiptRow` > `Text` | `textStyleCaption` 14sp / w400 | `kVatReceiptSecondary` #888888 |
| ❺ | 공급가액 금액 | `ReceiptRow` > `Text` | `textStyleCaption` 14sp / w400 | `kVatReceiptSecondary` #888888 |
| ❻ | 세율 레이블 "부가세 (" ")") | `Text` | `textStyleCaption` 14sp / w400 | `kVatReceiptSecondary` #888888 |
| ❻ | 세율 칩 (비활성) | `Container` > `Text` | `textStyleCaption` 14sp / w400 | `kVatReceiptSecondary` / 배경 transparent |
| ❻ | 세율 칩 (활성·편집 중) | `Container` > `Text` | `textStyleCaption` 14sp / w700 | `kVatColorEquals` / 배경 `kVatColorEquals` 15% / 실선 테두리 `kVatColorEquals` w1.5 / radius:4 |
| ❻ | 세율 칩 내부 패딩 | — | — | horizontal: 6 / vertical: 2 |
| ❻ | 세율 정보 아이콘 | `Icon(info_outline)` | `sizeIconSmall` 20 | `kVatReceiptSecondary` #888888 |
| ❻ | 부가세 금액 | `Text` | `textStyleCaption` 14sp / w400 | `kVatReceiptSecondary` #888888 |
| ❼ | 실선 구분선 | `Container` | h: 1.5 | `kVatReceiptDivider` #444444 |
| ❽ | 합계 라벨 | `Text` | `textStyleResult18` 18sp / w700 | `kVatReceiptText` #2C2C2C |
| ❽ | 합계 금액 | `Text` | `textStyleResult22` 22sp / w700 | `kVatReceiptText` #2C2C2C |

---

## ❿⓫ 키패드 (`VatNumberPad`)

4×4 레이아웃. Enter 버튼이 우측 하단 2행을 병합.

```
┌────┬────┬────┬────┐
│  7 │  8 │  9 │  ⌫ │
├────┼────┼────┼────┤
│  4 │  5 │  6 │ AC │
├────┼────┼────┤    │
│  1 │  2 │  3 │ ↵  │
├────┼────┼────┤    │
│ 00 │  0 │  . │    │
└────┴────┴────┴────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❾ | 구분선 | `Divider` | — | `kVatDivider` · thickness:0.5 |
| ❿ | ⌫ | `Icon(backspace_outlined)` | `sizeKeypadBackspace` 26 | `kVatColorFunction` |
| ❿ | AC | `VatKeypadButton` > `Text` | `textStyleKeypadNumber` 22sp / w400 | `kVatColorFunction` |
| ❿ | 0~9 · . · 00 | `VatKeypadButton` > `Text` | `textStyleKeypadNumber` 22sp / w400 | `kVatColorNumber` |
| ❿ | 버튼 높이 | `SizedBox` | — | `heightButtonLarge` 68 |
| ⓫ | ↵ Enter | `Icon(keyboard_return)` | `sizeKeypadBackspace` 26 | `Colors.white` · 배경 `kVatColorEquals` · 높이 `heightButtonLarge` × 2 |

---

## 세율 참고 Bottom Sheet (`TaxRateInfoSheet`)

세율 정보 아이콘 탭 시 표시.

```
┌──────────────────────────────────┐
│  세율 참고                    ✕  │  ← ⓬ 헤더
│  ──────────────────────────────  │  ← 구분선
│  🇰🇷  대한민국       10%         │  ← ⓭ 국가 행
│       부가가치세                 │
│  🇯🇵  일본           10%         │
│       소비세 (일반)              │
│  ...                             │
└──────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ⓬ | 드래그 핸들 | `Container` | — | `Colors.white38` · w:40 h:4 · radius:2 · margin top:12 |
| ⓬ | 타이틀 | `Text` | `textStyleAppBarTitle` 18sp / w600 | `Colors.white` |
| ⓬ | 닫기 버튼 | `Icon(close)` | `sizeIconSmall` 20 | `Colors.white54` |
| ⓬ | 헤더 하단 구분선 | `Divider` | — | `kVatDivider` · thickness:0.5 |
| ⓭ | 국기 | `CountryFlag.fromCountryCode()` | `sizeFlagSmall` 24×24 · 원형(Circle) | — |
| ⓭ | 국가명 | `Text` | `textStyleLabelLarge` 14sp / w500 | `Colors.white` |
| ⓭ | 세율명 | `Text` | `textStyleLabelMedium` 12sp / w500 | `Colors.white54` |
| ⓭ | 세율 수치 | `Text` | `textStyleValue` 16sp / w600 | `Colors.white` |
| — | 항목 구분선 | `Divider` | — | `kVatDivider` · thickness:0.3 |
| — | 항목 수직 패딩 | — | — | vertical: 12 |
| — | 국기↔텍스트 간격 | — | — | 12 |

**레이아웃 속성**

| 속성 | 값 |
|------|----|
| 배경 그라디언트 | 메인 화면과 동일 (`kVatGradientTop` → `kVatGradientBottom`) |
| 상단 border radius | `radiusBottomSheet` 20 |
| 높이 | 화면 높이 × 0.6 |
| 헤더 패딩 | 16 (전체) |
| 목록 패딩 | horizontal: 16 / vertical: 8 |

---

## 색상 팔레트

| 상수 | hex / 값 | 용도 |
|------|---------|------|
| `kVatGradientTop` | `#141218` | 배경 그라디언트 상단 (딥 다크) |
| `kVatGradientBottom` | `#231F2E` | 배경 그라디언트 하단 (다크 퍼플) |
| `kVatReceiptBg` | `#F5F5F0` | 영수증 카드 배경 (크림색) |
| `kVatReceiptText` | `#2C2C2C` | 영수증 카드 주 텍스트 |
| `kVatReceiptSecondary` | `#888888` | 영수증 카드 보조 텍스트 |
| `kVatReceiptDash` | `#CCCCCC` | 점선 구분선 |
| `kVatReceiptDivider` | `#444444` | 실선 구분선 (합계 위) |
| `kVatDivider` | `Colors.white` 33% | 키패드 구분선 · Bottom Sheet 구분선 |
| `kVatColorNumber` | `Colors.white` | 숫자 버튼 텍스트 |
| `kVatColorOperator` | `#A78BFA` | 연산자 버튼 텍스트 (라벤더) — 정의됨, 현재 키패드 미사용 |
| `kVatColorFunction` | `#FFFFFFCC` (80% 불투명) | 기능 버튼 텍스트 (⌫ · AC) |
| `kVatColorEquals` | `#7C3AED` | = 버튼 배경 · 세율 칩 활성 색상 (딥 퍼플) |
