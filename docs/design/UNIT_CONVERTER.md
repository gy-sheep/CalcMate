# 단위 변환기 — 화면 디자인

> 구현 참조용. 레이아웃·위젯·스타일·색상을 한 곳에서 확인한다.
> 색상 상수는 `unit_converter_colors.dart` 참조.

---

## 배경

| 속성 | 값 |
|------|----|
| 종류 | `LinearGradient` · topCenter → bottomCenter |
| 상단 | `kUnitBg1` #1B2838 |
| 하단 | `kUnitBg2` #2C3E50 |
| 비고 | `extendBodyBehindAppBar: true` → 그라디언트가 상태바 뒤까지 연장 |

---

## 레이아웃 & 스타일

```
┌──────────────────────────────────┐
│  ←  단위 변환기                  │  ← ❶ AppBar
├──────────────────────────────────┤
│ [길이▸] [온도] [무게] [부피] ...  │  ← ❷ 카테고리 탭 (가로 스크롤 칩)
│  ──────────────────────────────  │     탭 하단 divider + 슬라이딩 언더라인
│                                  │
│  m       미터                1   │  ← ❸ 활성 행 (강조 배경 + 테두리)
│  km      킬로미터          0.001  │  ← ❹ 비활성 행
│  cm      센티미터            100  │
│  mm      밀리미터          1,000  │
│  ...                             │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  ← ❺ 스크롤 페이드 (목록 넘칠 때)
├──────────────────────────────────┤  ← ❻ 구분선
│  7  │  8  │  9  │  ⌫           │  ← ❼ 숫자 버튼 / 기능 버튼
│  4  │  5  │  6  │  AC          │
│  1  │  2  │  3  │  ▲           │  ← ❽ 화살표 — 활성 단위 위/아래 이동
│  00 │  0  │  .  │  ▼           │     온도 카테고리 시 00 → +/-
└──────────────────────────────────┘
```

> **구조 메모**: `CategoryTabs` + `SizedBox(height:8)` + `Expanded(TabBarView)` + `Divider` + `UnitNumberPad` + `AdBannerPlaceholder` 의 세로 구성.
> 단위 목록은 `TabBarView` + `ListView.builder`로 구성되며, 카테고리별 `ScrollController`를 독립 관리한다.
> 활성 단위 변경 시 `Scrollable.ensureVisible`로 해당 행이 자동 스크롤된다.

---

## ❶ AppBar

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❶ | 뒤로가기 아이콘 | `Icon(arrow_back_ios)` | `CmAppBar.backIconSize` 20 | `Colors.white` |
| ❶ | 타이틀 | `Text` | `CmAppBar.titleText` 20sp / w700 | `Colors.white` |

> `backgroundColor: Colors.transparent` / `elevation: 0` / `scrolledUnderElevation: 0` / `centerTitle: false`

---

## ❷ 카테고리 탭 (`CategoryTabs`)

```
┌─────────────────────────────────────────────┐  height: 48
│  [길이▸]  [온도]  [무게]  [부피]  [넓이]    │  ← 칩 (가로 스크롤)
│  ══════                                      │  ← 슬라이딩 언더라인
│  ─────────────────────────────────────────  │  ← 하단 divider
└─────────────────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❷ | 탭 전체 높이 | `SizedBox` | — | h: 48 |
| ❷ | 스크롤 패딩 | `SingleChildScrollView` | — | horizontal: `screenPaddingH` |
| ❷ | 칩 (선택) 배경 | `Positioned` > `DecoratedBox` | — | `kUnitChipActiveBg` · `CmTab.radius` 20 · border `kUnitChipActiveBg` 25% · glow shadow (blurRadius:8 spreadRadius:1 `kUnitChipActiveBg` 25%) |
| ❷ | 칩 내부 패딩 | `Container` | — | `CmTab.padding` (horizontal: 14 / vertical: 8) |
| ❷ | 칩 스케일 | `Transform.scale` | — | 선택 시 최대 ×1.08 (`1.0 + proximity × 0.08`) |
| ❷ | 칩 아이콘 | `Icon` | `sizeIconXSmall` 16 | `Color.lerp(Colors.white60, Colors.white, proximity)` |
| ❷ | 칩 텍스트 | `Text` | `CmTab.text` 14sp · proximity>0.5: w600 / 그 외: w400 | `Color.lerp(Colors.white60, Colors.white, proximity)` |
| ❷ | 칩 간격 | `Padding` | — | 첫 칩: 0 / 이후 칩: left 8 |
| ❷ | 슬라이딩 언더라인 | `Positioned(left:rect.left+4, bottom:1, width:rect.width-8)` > `DecoratedBox` | h: 2.5 · radius: 2 | `kUnitChipActiveBg` · glow shadow (blurRadius:6 spreadRadius:1 `kUnitChipActiveBg` 60%) |
| ❷ | 하단 divider | `Positioned(left:0, right:0, bottom:4)` > `Container` | h: 0.5 | `kUnitDivider` |

**슬라이딩 하이라이트 보간**: 탭 전환 시 `tabAnimation.value` 기준으로 좌측은 `easeInCubic`, 우측은 `easeOutCubic`으로 탄성 스트레치 효과. 칩 Row 크기를 기준으로 각 칩의 `Rect`를 측정하여 보간한다.

---

## ❸❹ 단위 목록 행 (`UnitList`)

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | 활성 행 배경 | `AnimatedContainer` | — | `kUnitActiveRow` · radius: `radiusCard` 16 |
| ❸ | 활성 행 테두리 | `Border.all` | — | `kUnitChipActiveBg` 40% |
| ❸ | 단위 코드 (활성) | `Text` (SizedBox w:80) | `textStyle16` 16sp / w600 | `kUnitChipActiveBg` |
| ❸ | 단위 이름 (활성) | `Text` | `textStyleCaption` 12sp / w400 | `Colors.white` |
| ❸ | 변환값 (활성) | `Text` | `textStyle18` 18sp / w500(copyWith) / letterSpacing:-0.5 | `Colors.white` |
| ❹ | 비활성 행 배경 | — | — | `Colors.transparent` |
| ❹ | 단위 코드 (비활성) | `Text` (SizedBox w:80) | `textStyle16` 16sp / w600 | `Colors.white70` |
| ❹ | 단위 이름 (비활성) | `Text` | `textStyleCaption` 12sp / w400 | `Colors.white54` |
| ❹ | 변환값 (비활성) | `Text` | `textStyle18` 18sp / w300(copyWith) / letterSpacing:-0.5 | `Colors.white70` |
| ❸❹ | 행 내부 패딩 | — | — | horizontal: 16 / vertical: 14 |
| ❸❹ | 행 수직 마진 | — | — | vertical: 2 |

---

## ❺ 스크롤 페이드

스크롤 가능하고 하단 끝에 도달하지 않은 경우에만 표시 (`_showBottomFade`).

| 속성 | 값 |
|------|----|
| 위젯 | `Positioned(left:0, right:0, bottom:0)` > `IgnorePointer` > `DecoratedBox` (Stack 내부) |
| 높이 | 48 |
| 그라디언트 | `kUnitBg2` α0 → α0.7 → α1.0 (topCenter → bottomCenter) |
| stops | `[0.0, 0.6, 1.0]` |
| 숨김 조건 | `pos.pixels >= pos.maxScrollExtent - 8` 또는 스크롤 불가 시 |

---

## ❼❽ 키패드 (`UnitNumberPad`)

4×4 레이아웃. 온도 카테고리 선택 시 `00` → `+/-` 로 변경.

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❻ | 구분선 | `Divider` | — | `kUnitDivider` · thickness:0.5 |
| ❼ | ⌫ | `Icon(backspace_outlined)` | `keypadBackspaceSize` 26 | `kUnitKeyFunction` |
| ❼ | AC · 00 | `UnitKeypadButton` > `Text` | `keypadNumberText` 22sp / w400 | `kUnitKeyFunction` |
| ❼ | 0~9 · . | `UnitKeypadButton` > `Text` | `keypadNumberText` 22sp / w400 | `kUnitKeyNumber` |
| ❽ | ▲ | `Icon(keyboard_arrow_up)` | size: 28 | `kUnitKeyFunction` |
| ❽ | ▼ | `Icon(keyboard_arrow_down)` | size: 28 | `kUnitKeyFunction` |
| ❽ | +/- (온도) | `Row` > `Text` × 3 | `+` 18sp w500 / `/` 20sp w300 / `-` **24sp** w500 | `kUnitKeyFunction` |
| ❼❽ | 버튼 높이 | `SizedBox` | — | h: 56 |

---

## 색상 팔레트

| 상수 | hex / 값 | 용도 |
|------|---------|------|
| `kUnitBg1` | `#1B2838` | 배경 그라디언트 상단 |
| `kUnitBg2` | `#2C3E50` | 배경 그라디언트 하단 |
| `kUnitActiveRow` | `Colors.red` 20% (`0x33E94560`) | 활성 단위 행 배경 |
| `kUnitChipActiveBg` | `#F0A500` | 선택된 탭 칩·언더라인·활성 행 테두리 |
| `kUnitDivider` | `Colors.white` 33% (`0x55FFFFFF`) | 탭 하단 divider · 키패드 상단 구분선 |
| `kUnitChipBg` | `Colors.white` 27% (`0x44FFFFFF`) | 칩 기본 배경 (정의됨, 현재 미사용) |
| `kUnitKeyNumber` | `Colors.white` | 숫자 버튼 텍스트 |
| `kUnitKeyFunction` | `#FFFFFFCC` (80% 불투명) | 기능 버튼 텍스트 (⌫ AC ▲ ▼ +/-) |
