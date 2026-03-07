# 환율 계산기 — 화면 디자인

> 구현 참조용. 레이아웃·위젯·스타일·색상을 한 곳에서 확인한다.
> 색상 상수는 `currency_calculator_colors.dart` 참조.

---

## 배경

| 속성 | 값 |
|------|----|
| 종류 | `LinearGradient` · topCenter → bottomCenter |
| 상단 | `kCurrencyGradientTop` #0D1B3E |
| 하단 | `kCurrencyGradientBottom` #0A4D52 |
| 비고 | `extendBodyBehindAppBar: true` → 그라디언트가 상태바 뒤까지 연장 |

---

## 레이아웃 & 스타일

```
┌──────────────────────────────────┐
│  ←  환율 계산기                  │  ← ❶ AppBar
├──────────────────────────────────┤
│                                  │
│  [CurrencyCodeButton❷] [AmountDisplay❷]
│  🇰🇷                    120,000  │  ← ❷ From 통화 행 (활성)
│  KRW              ─────────────  │
│                                  │
│  [CurrencyCodeButton❸] [AmountDisplay❸]
│  🇺🇸            1 KRW = 0.0007 USD  ← ❸ To 통화 행 (비활성)
│  USD                   0.0840   │     힌트는 AmountDisplay 내부 Positioned
│                   ─────────────  │
│                                  │
│  [CurrencyCodeButton❹] [AmountDisplay❹]
│  🇪🇺            1 KRW = 0.0006 EUR  ← ❹ To 통화 행 × 3개 (동일 구조)
│  EUR                   0.0773   │
│                   ─────────────  │
│                                  │
│  🇯🇵            1 KRW = 0.1034 JPY
│  JPY                  12.41     │
│                   ─────────────  │
│                                  │
│  2026.03.02. 오후 3:00 기준  🔄  │  ← ❺ 업데이트 시간 + 새로고침
├──────────────────────────────────┤  ← ❻ 구분선
│  ⌫  │  AC  │   %  │  ÷         │  ← ❼ 기능 버튼 / 연산자 버튼
│  7  │   8  │   9  │  ×         │  ← ❽ 숫자 버튼 / 연산자 버튼
│  4  │   5  │   6  │  -         │
│  1  │   2  │   3  │  +         │
│  00 │   0  │   .  │  =         │  ← ❾ = 버튼 (강조 배경)
└──────────────────────────────────┘
```

> **구조 메모**: 각 통화 행은 `Row`로 구성. 좌측 `CurrencyCodeButton`(국기+코드), 우측 `AmountDisplay`(힌트+금액+밑줄).
> 힌트 텍스트("1 KRW = 0.0007 USD")는 `AmountDisplay` 내부에서 `Positioned(top: -16)`으로 금액 위에 오버레이.
> 각 통화 행은 `ConstrainedBox(minHeight: 80)`으로 감싸 화면 크기에 따라 간격이 자동 조정되는 최소 높이를 보장.

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❶ | AppBar 뒤로가기 아이콘 | `Icon(arrow_back_ios)` | `sizeAppBarBackIcon` 20 | `Colors.white` |
| ❶ | AppBar 타이틀 | `Text` | `textStyleAppBarTitle` 18sp / w600 | `Colors.white` |
| ❷ | 국기 (From) | `CurrencyCodeButton` > `CountryFlag` | `sizeFlagMedium` 32×32 · 원형(Circle) | — |
| ❷ | 통화 코드 (From) | `CurrencyCodeButton` > `Text` | `textStyleLabelMedium` 12sp / w500 | `Colors.white` |
| ❷ | 금액 (From, 활성) | `AmountDisplay` > `FittedBox` > `Text` | `textStyleResult28` 28sp / w300 / letterSpacing:-1 | `Colors.white` |
| ❷ | 밑줄 (From, 활성) | `AppInputUnderline(full)` > `Container` | `thicknessInputUnderline` 1.5 | `Colors.white` |
| ❸ | 국기 (To) | `CurrencyCodeButton` > `CountryFlag` | `sizeFlagMedium` 32×32 · 원형(Circle) | — |
| ❸ | 통화 코드 (To) | `CurrencyCodeButton` > `Text` | `textStyleLabelMedium` 12sp / w500 | `Colors.white` |
| ❸ | 1단위 환율 힌트 | `AmountDisplay` > `Text` (금액 위에 오버레이) | `textStyleCaption` 14sp / w400 | `Colors.white38` |
| ❸ | 금액 (To, 비활성) | `AmountDisplay` > `FittedBox` > `Text` | `textStyleResult28` 28sp / w300 / letterSpacing:-1 | `Colors.white` |
| ❸ | 밑줄 (To, 비활성) | `AppInputUnderline(full)` > `Container` | `thicknessInputUnderline` 1.5 | `Colors.white38` |
| ❹ | To 행 × 3개 | ❸과 동일 구조 반복 | | |
| ❺ | 업데이트 시간 | `Text` | `textStyleCaption` 14sp / w400 | `Colors.white38` |
| ❺ | 새로고침 아이콘 | `Icon(refresh)` | `sizeIconSmall` 20 | `Colors.white54` |
| ❺ | 새로고침 로딩 중 | `CupertinoActivityIndicator` | `radiusActivityIndicator` 10 | `Colors.white54` |
| ❻ | 구분선 | `Divider` | — | `kCurrencyDivider` · thickness:0.5 |
| ❼ | ⌫ | `Icon(backspace_outlined)` | `sizeKeypadBackspace` 26 | `kCurrencyColorFunction` |
| ❼ | AC · % | `CurrencyKeypadButton` > `Text` | `textStyleKeypadNumber` 22sp / w400 | `kCurrencyColorFunction` |
| ❼ | ÷ · × · - · + | `CurrencyKeypadButton` > `Text` | `textStyleKeypadOperator` 28sp / w400 | `kCurrencyColorOperator` |
| ❼ | 버튼 높이 | — | — | `AppTokens.heightButtonLarge` 68 |
| ❽ | 0~9 · . · 00 | `CurrencyKeypadButton` > `Text` | `textStyleKeypadNumber` 22sp / w400 | `kCurrencyColorNumber` |
| ❾ | = | `CurrencyKeypadButton` > `Text` | `textStyleKeypadOperator` 28sp / w400 | `Colors.white` · 배경 `kCurrencyColorEquals` |

---

## 통화 선택 Bottom Sheet (`CurrencyPickerSheet`)

국기 또는 통화 코드 탭 시 표시.

```
┌──────────────────────────────────┐
│            ────                  │  ← ⓫ 드래그 핸들
│  🔍  통화 검색 (USD, 달러...)    │  ← ⓬ 검색창
│                                  │
│  🇰🇷  KRW              ✓        │  ← ⓭ 선택된 항목
│       대한민국 원                │
│  🇺🇸  USD                        │  ← ⓮ 일반 항목
│       미국 달러                  │
│  🇪🇺  EUR                        │  ← ⓯ 사용 중 항목 (dim)
│       유로                       │
│       ...                        │
└──────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ⓫ | 드래그 핸들 | `Container` | — | `Colors.white38` · w:40 h:4 · radius:2 |
| ⓬ | 검색 입력창 | `AppTextField.search()` | `textStyleBody` (본문) / `textStyleHint` (힌트) | border `Colors.white30` / 포커스 `Colors.white70` · `radiusInput` 12 |
| ⓬ | 검색 아이콘 | `AppTextField.search()` 내장 | size: 기본 | `Colors.white54` (hintColor 기본값) |
| ⓭ | 통화 코드 (선택됨) | `ListTile` > `Text` (title) | `textStyleBody` 16sp / w400 · `FontWeight.bold` | `Colors.white` |
| ⓮ | 통화 코드 (일반) | `ListTile` > `Text` (title) | `textStyleBody` 16sp / w400 | `Colors.white` |
| ⓯ | 통화 코드 (사용 중) | `ListTile` > `Text` (title) | `textStyleBody` 16sp / w400 | `Colors.white38` |
| ⓭⓮ | 통화 이름 (일반) | `ListTile` > `Text` (subtitle) | `textStyleCaption` 14sp / w400 | `Colors.white60` |
| ⓯ | 통화 이름 (사용 중) | `ListTile` > `Text` (subtitle) | `textStyleCaption` 14sp / w400 | `Colors.white24` |
| ⓭⓮⓯ | 국기 | `CountryFlag` | `sizeFlagMedium` 32×32 · 원형(Circle) | — |
| ⓭ | 체크 아이콘 | `Icon(check)` | — | `Colors.white` |

**레이아웃 속성**

| 속성 | 값 |
|------|----|
| 배경 그라디언트 | 메인 화면과 동일 (`kCurrencyGradientTop` → `kCurrencyGradientBottom`) |
| 상단 border radius | 20 |
| 높이 | 화면 높이 × 0.6 |
| 패딩 | 16 (전체) |

---

## 스크롤 페이드

통화 행이 화면을 초과할 때 하단 페이드 표시.

| 속성 | 값 |
|------|----|
| 위젯 | `Positioned` (Stack 내부) |
| 높이 | 48 |
| 그라디언트 | `kCurrencyGradientBottom` 0% → 70% → 100% |
| stops | `[0.0, 0.6, 1.0]` |

---

## 로딩 오버레이

환율 데이터 초기 로딩 중에 화면 전체에 표시.

```
┌──────────────────────────────────┐
│                                  │
│       ╔════════════════╗         │
│       ║  ◌  환율 정보를  ║         │  ← ❿ 로딩 카드
│       ║    가져오는 중...║         │
│       ╚════════════════╝         │
│                                  │
└──────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❿ | 배경 딤 | `Container` | — | `Colors.black45` |
| ❿ | 카드 블러 | `BackdropFilter(blur: 10)` | — | — |
| ❿ | 카드 배경 | `Container` | — | `Colors.white` 12% · 테두리 `Colors.white` 24% · radius:16 |
| ❿ | 스피너 | `CircularProgressIndicator` | strokeWidth: 2 | `Colors.white70` |
| ❿ | 로딩 텍스트 | `Text` | `textStyleBody` 16sp / w500 | `Colors.white70` |

---

## 색상 팔레트

| 상수 | hex / 값 | 용도 |
|------|---------|------|
| `kCurrencyGradientTop` | `#0D1B3E` | 배경 그라디언트 상단 |
| `kCurrencyGradientBottom` | `#0A4D52` | 배경 그라디언트 하단 |
| `kCurrencyDivider` | `Colors.white` 33% | 키패드 상단 구분선 |
| `kCurrencyColorNumber` | `Colors.white` | 숫자 버튼 텍스트 |
| `kCurrencyColorOperator` | `#FF9F7A` | 연산자 버튼 텍스트 |
| `kCurrencyColorFunction` | `#FFFFFFCC` (80% 불투명) | 기능 버튼 텍스트 (⌫ AC %) |
| `kCurrencyColorEquals` | `#FF6B4A` | = 버튼 배경 |
