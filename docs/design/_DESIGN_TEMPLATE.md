# {기능명} — 화면 디자인

> 구현 참조용. 레이아웃·위젯·스타일·색상을 한 곳에서 확인한다.
> 색상 상수는 `{feature}_colors.dart` 참조.

---

## 배경

| 속성 | 값 |
|------|-----|
| 종류 | `LinearGradient` · topCenter → bottomCenter |
| 상단 | `k{Feature}GradientTop` #{HEX} |
| 하단 | `k{Feature}GradientBottom` #{HEX} |
| 비고 | `extendBodyBehindAppBar: true` → 그라디언트가 상태바 뒤까지 연장 |

---

## 레이아웃 & 스타일

```
┌──────────────────────────────────┐
│  ←  {화면 제목}                  │  ← ❶ AppBar
├──────────────────────────────────┤
│                                  │  ← ❷ {영역명}
│                                  │
│                                  │  ← ❸ {영역명}
│                                  │
│                                  │  ← ❹ {영역명}
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  ← ❺ 스크롤 페이드 (목록 넘칠 때)
├──────────────────────────────────┤  ← ❻ 구분선
│                                  │  ← ❼ {영역명}
│                                  │
└──────────────────────────────────┘
```

> **구조 메모**: {주요 위젯 구성 설명}.

---

## ❶ AppBar

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❶ | 뒤로가기 아이콘 | `Icon(arrow_back_ios)` | `sizeAppBarBackIcon` 20 | `Colors.white` |
| ❶ | 타이틀 | `Text` | `textStyleAppBarTitle` 18sp / w600 | `Colors.white` |

> `backgroundColor: Colors.transparent` / `elevation: 0` / `scrolledUnderElevation: 0` / `centerTitle: false`

---

## ❷ {영역명}

```
┌─────────────────────────────────────────────┐  height: {N}
│  {내부 레이아웃 상세}                         │
└─────────────────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❷ | {요소} | `{Widget}` | — | {color} |
| ❷ | {요소} | `{Widget}` | {style} | {color} |

---

## ❸ {영역명}

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | {요소} | `{Widget}` | — | {color} |
| ❸ | {요소} | `{Widget}` | {style} | {color} |

---

## ❹ {영역명}

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❹ | {요소} | `{Widget}` | — | {color} |
| ❹ | {요소} | `{Widget}` | {style} | {color} |

---

## ❺ 스크롤 페이드

목록이 화면을 초과할 때 하단 페이드 표시.

| 속성 | 값 |
|------|-----|
| 위젯 | `Positioned` (Stack 내부) |
| 높이 | 48 |
| 그라디언트 | `k{Feature}GradientBottom` 0% → 70% → 100% |
| stops | `[0.0, 0.6, 1.0]` |

---

## ❻ 구분선

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❻ | 구분선 | `Divider` | — | `k{Feature}Divider` · thickness:0.5 |

---

## ❼ {영역명 — 키패드 등}

{레이아웃 설명 (e.g. 4×4 레이아웃. 특정 조건 시 버튼 변경 등)}

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❼ | ⌫ | `Icon(backspace_outlined)` | `sizeKeypadBackspace` 26 | `k{Feature}ColorFunction` |
| ❼ | AC · 00 | `{Widget}` > `Text` | `textStyleKeypadNumber` 22sp / w400 | `k{Feature}ColorFunction` |
| ❼ | 0~9 · . | `{Widget}` > `Text` | `textStyleKeypadNumber` 22sp / w400 | `k{Feature}ColorNumber` |
| ❼ | {특수 버튼} | `{Widget}` | {style} | `k{Feature}ColorFunction` |
| ❼ | 버튼 높이 | `SizedBox` | — | `heightButtonMedium` 56 |

---

## 색상 팔레트

| 상수 | hex / 값 | 용도 |
|------|---------|------|
| `k{Feature}GradientTop` | `#{HEX}` | 배경 그라디언트 상단 |
| `k{Feature}GradientBottom` | `#{HEX}` | 배경 그라디언트 하단 |
| `k{Feature}ActiveColor` | `{value}` | 활성 요소 배경/강조 |
| `k{Feature}AccentColor` | `#{HEX}` | 선택/하이라이트 색상 |
| `k{Feature}Divider` | `Colors.white` 33% (`0x55FFFFFF`) | 구분선 |
| `k{Feature}ColorNumber` | `Colors.white` | 숫자 버튼 텍스트 |
| `k{Feature}ColorFunction` | `#FFFFFFCC` (80% 불투명) | 기능 버튼 텍스트 |
