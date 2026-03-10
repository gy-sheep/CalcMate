# 기본 계산기 — 화면 디자인

> 구현 참조용. 레이아웃·위젯·스타일·색상을 한 곳에서 확인한다.
> 색상 상수는 `basic_calculator_colors.dart` 참조.

---

## 배경

| 속성 | 값 |
|------|----|
| 종류 | `LinearGradient` · topCenter → bottomCenter |
| 상단 | `kCalcGradientTop` #0D2137 |
| 하단 | `kCalcGradientBottom` #0A3D2B |
| 비고 | `extendBodyBehindAppBar: true` → 그라디언트가 상태바 뒤까지 연장 |

---

## 레이아웃 & 스타일

```
┌─────────────────────────────────┐
│  ← [아이콘]  기본 계산기         │  ← ❶ AppBar
│                                 │
│                   5 × (3 + 2)   │  ← ❷ 수식 (계산 완료 후에만 표시)
│                                 │
│                        15       │  ← ❸ 입력값 / 결과 (동적 폰트)
│  ─────────────────────────────  │  ← ❹ 하단 구분선
│                                 │
├─────────────────────────────────┤  ← ❺ 키패드 상단 구분선
│  ⌫  │  AC  │   %  │  ÷        │  ← ❻ 기능 버튼 / 연산자 버튼
│  7  │   8  │   9  │  ×        │  ← ❼ 숫자 버튼 / 연산자 버튼
│  4  │   5  │   6  │  -        │
│  1  │   2  │   3  │  +        │
│ ( ) │   0  │   .  │  =        │  ← ❽ = 버튼 (강조 배경)
└─────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❶ | AppBar 뒤로가기 아이콘 | `Icon(arrow_back_ios)` | `CmAppBar.backIconSize` 20 | `Colors.white` |
| ❶ | AppBar 타이틀 | `Text` | `CmAppBar.titleText` 20sp / w700 | `Colors.white` |
| ❷ | 수식 표시 | `DisplayPanel` > `Text` | 20sp / w400 / h:1.4 | `Colors.white54` |
| ❷ | (동작) 한 줄 초과 시 | 연산자 앞 줄바꿈 → 최대 2줄, 그래도 넘치면 우측 기준 가로 스크롤 | | |
| ❸ | 입력값 / 결과 | `DisplayPanel` > `Text` | **동적** 10~80sp / w300 / h:1.1 | `Colors.white` |
| ❸ | (동작) 기준 범위 | `'123,456,789'` 기준 최대 / `'12,345,678,323'` 기준 최소로 범위 산정 후 텍스트 너비에 맞춰 결정 | | |
| ❸ | (동작) 넘칠 때 | 우측 기준 가로 스크롤 (`BouncingScrollPhysics`) | | |
| ❹ | 하단 구분선 | `AppInputUnderline(full)` > `Container` | `thicknessInputUnderline` 1.5 | `Colors.white60` |
| ❺ | 키패드 상단 구분선 | `Divider` | — | `Colors.white` 20% · thickness:0.5 |
| ❻ | ⌫ | `Icon(backspace_outlined)` | `keypadBackspaceSize` 26 | `kCalcColorFunction` |
| ❻ | AC · % · () | `CalcButton` > `Text` | `keypadNumberText` 22sp / w400 | `kCalcColorFunction` |
| ❻ | ÷ · × · - · + | `CalcButton` > `Text` | `keypadOperatorText` 28sp / w400 | `kCalcColorOperator` |
| ❻ | 버튼 높이 | — | — | `keypadButtonHeightLarge` 68 |
| ❼ | 0~9 · . | `CalcButton` > `Text` | `keypadNumberText` 22sp / w400 | `kCalcColorNumber` |
| ❽ | = | `CalcButton` > `Text` | `keypadOperatorText` 28sp / w400 | `Colors.white` · 배경 `kCalcColorEquals` |

---

## 색상 팔레트

| 상수 | hex / 값 | 용도 |
|------|---------|------|
| `kCalcGradientTop` | `#0D2137` | 배경 그라디언트 상단 |
| `kCalcGradientBottom` | `#0A3D2B` | 배경 그라디언트 하단 |
| `kCalcColorNumber` | `Colors.white` | 숫자 버튼 텍스트 |
| `kCalcColorOperator` | `#FF9F7A` | 연산자 버튼 텍스트 (÷ × - +) |
| `kCalcColorFunction` | `#FFFFFFCC` (80% 불투명) | 기능 버튼 텍스트 (⌫ AC %) |
| `kCalcColorEquals` | `#FF6B4A` | = 버튼 배경 |
