# BMI 계산기 — 화면 디자인

> 구현 참조용. 레이아웃·위젯·스타일·색상을 한 곳에서 확인한다.
> 색상 상수는 `bmi_calculator_screen.dart` 상단 `_k*` 상수 참조.

---

## 배경

| 속성 | 값 |
|------|----|
| 종류 | `LinearGradient` · topCenter → bottomCenter |
| 상단 | `_kBgTop` #1A2E44 (다크 네이비 블루) |
| 하단 | `_kBgBottom` #0D1B2A (딥 다크 네이비) |
| 비고 | `extendBodyBehindAppBar: true` → 그라디언트가 상태바 뒤까지 연장 |

---

## 레이아웃 & 스타일

```
┌──────────────────────────────────┐
│  ←   BMI 계산기      [kg · cm]  │  ← ❶ AppBar (centerTitle: true, 스크롤 시 블러)
├──────────────────────────────────┤
│    ╭──── 컬러 아크 게이지 ────╮   │  ← ❷ 아크 게이지 영역
│   ╱  [저체중][정상][과체중][비만]╲  │     (CustomPaint, 반원 180°)
│  │                              │ │
│  │           22.4               │ │  ← BMI 수치 (textStyleResult52)
│  │         정상 체중             │ │  ← 범주 라벨 (범주 색상)
│  │   WHO 아시아태평양 기준 …     │ │  ← 기준 배지 (textStyleLabelSmall)
│   ╲──────────────────────────╱  │
├──────────────────────────────────┤
│  ┌──────────────────────────┐   │  ← ❸ 키 슬라이더 카드
│  │ 키              [170 cm✎]│   │
│  │  ├──────────●────────┤   │   │     (Slider, 100~220 cm)
│  │  100                 220 │   │
│  └──────────────────────────┘   │
│  ┌──────────────────────────┐   │  ← ❹ 몸무게 슬라이더 카드
│  │ 몸무게         [65.0 kg✎]│   │
│  │  ├──────────●────────┤   │   │     (Slider, 20~150 kg)
│  │  20                  150 │   │
│  └──────────────────────────┘   │
│  ┌──────────────────────────┐   │  ← ❺ 건강 체중 범위 카드
│  │ [⊙]  건강 체중 범위       │   │
│  │      55.8 kg – 69.5 kg   │   │
│  │      (범위 내 시 확인 메시지)│   │
│  └──────────────────────────┘   │
│  ┌──────────────────────────┐   │  ← ❻ BMI 범주 안내 그리드
│  │저체중│  정상  │과체중│비만│   │     (4셀 1행 or 5셀 3+2행)
│  │<18.5│18.5–  │23.0–│≥25 │   │
│  │     │22.9   │24.9 │    │   │
│  └──────────────────────────┘   │
└──────────────────────────────────┘
```

> **구조 메모**: `ScrollFadeView(controller: _scrollController)` 내부에 `_BmiGauge` → `_InputSlider(키)` → `SizedBox(16)` → `_InputSlider(몸무게)` → `SizedBox(20)` → `_HealthyWeightCard` → `SizedBox(16)` → `_CategoryGrid` → `SizedBox(8)` 순서.
> 키패드 없음. 슬라이더 값 버튼 탭 시 `AlertDialog` 직접 입력.

---

## ❶ AppBar

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❶ | 뒤로가기 | `Icon(arrow_back_ios_new)` | `sizeAppBarBackIcon` 20 | `_kTextPrimary` (white) |
| ❶ | 타이틀 | `Text('BMI 계산기')` | `textStyleAppBarTitle` 18sp / w600 | `_kTextPrimary` |
| ❶ | 단위 토글 버튼 (actions) | `GestureDetector` > `Container` > `Text` | `textStyleCaption` 14sp / w400 | 텍스트: `_kAccent` / 테두리: `_kAccent` 50% |

> `backgroundColor: Colors.transparent` / `elevation: 0` / `scrolledUnderElevation: 0` / `centerTitle: true`
> 단위 토글: margin `paddingAppBarH (16)`, padding `paddingChip (h14 v8)`, `Border.all` + `radiusChip 20`. 표시 텍스트: `_isMetric ? 'kg · cm' : 'lb · ft'`.

### 스크롤 연동 AppBar

`PreferredSize` > `ClipRect` > `BackdropFilter` > `AnimatedContainer` > `AppBar` 구조.

| 상태 | blur | 배경색 |
|------|------|--------|
| 미스크롤 | `sigmaX/Y: 0` | `Colors.transparent` |
| 스크롤 중 | `sigmaX/Y: 20` | `_kBgTop` 85% (`0xD91A2E44`) |

> `_scrollController.offset > 0` 감지 → `setState(() => _isScrolled = ...)` → `AnimatedContainer(duration: 200ms)` 전환.

---

## ❷ 아크 게이지 영역 (`_BmiGauge`)

```
┌─────────────────────────────────────┐  height: screenWidth/2 + 8
│  ╭── CustomPaint (_GaugePainter) ──╮│
│ ╱   [컬러 구간 아크 + 경계선]       ╲│
│                     ↑ 바늘          │
│                                     │
│           22.4  ← TweenAnimationBuilder (textStyleResult52, white)
│         정상 체중← AnimatedSwitcher (textStyleValue, cat.color)
│   WHO 아시아태평양 기준 (대한비만학회 준용)
│                    ← textStyleLabelSmall, _kTextSecondary
└─────────────────────────────────────┘
```

### _GaugePainter 명세

| 항목 | 값 |
|------|----|
| 아크 중심 | `(cx, height)` — canvas 하단 중앙 (반원 상단만 노출) |
| 외반경 `outerR` | `screenWidth/2 - 8` |
| 내반경 `innerR` | `outerR × 0.72` |
| 아크 중심반경 `arcR` | `(outerR + innerR) / 2` |
| 아크 폭 `arcW` | `outerR - innerR` |
| 트랙 배경 | `drawArc` strokeWidth: `arcW` / `_kSliderTrack` / `StrokeCap.butt` |
| 컬러 구간 | `drawArc` strokeWidth: `arcW - 3` / 각 범주 color / `StrokeCap.butt` |
| BMI 범위 | 10.0 ~ 40.0 (게이지 표시 범위) |
| 경계선 | 범주 경계 BMI에서 innerR → outerR 직선 / `_kBgBottom` 70% / strokeWidth 2 |
| 바늘 | innerR×0.55 → outerR×0.95 / white / strokeWidth 2.5 / `StrokeCap.round` |
| 바늘 중심원 | 반지름 6 white + 반지름 4 `_kBgBottom` (도넛) |
| 각도 매핑 | BMI 10 → π(좌), BMI 40 → 0(우) (수학 좌표계) |
| 애니메이션 | `AnimationController(600ms)` + `easeOutCubic` / BMI 변경 시 트리거 |

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❷ | BMI 수치 | `TweenAnimationBuilder` > `Text` | `textStyleResult52` 52sp / w300 / height 1.0 | `_kTextPrimary` |
| ❷ | 범주 라벨 | `AnimatedSwitcher` > `Text` | `textStyleValue` 16sp / w600 | `category.color` |
| ❷ | 기준 배지 | `Text` | `textStyleLabelSmall` 10sp / w500 | `_kTextSecondary` |

> BMI 수치 `TweenAnimationBuilder` duration 400ms + easeOutCubic. 범주 라벨 `AnimatedSwitcher` duration 250ms.

---

## ❸ 키 슬라이더 카드 (`_InputSlider`)

```
┌─────────────────────────────────────────────┐  _kCardBg / radiusCard 16 / paddingCard all20
│  키                          [170 cm  ✎]   │  ← 레이블 + 값 버튼
│  ├──────────────●────────────────────────┤  │  ← SliderTheme 슬라이더
│  100                                   220  │  ← 최솟·최대값 레이블
└─────────────────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | 레이블 | `Text` | `textStyleSectionTitle` 13sp / w600 / letterSpacing:0.3 | `_kTextSecondary` |
| ❸ | 값 버튼 배경 | `Container` | — | `_kAccent` 12% |
| ❸ | 값 버튼 padding | `paddingChip` | h14 v8 | — |
| ❸ | 값 버튼 테두리 | `Border.all` | — | `_kAccent` 30% |
| ❸ | 값 버튼 borderRadius | — | — | `radiusChip` 20 |
| ❸ | 값 텍스트 | `Text` | `textStyleValue` 16sp / w600 | `_kAccent` |
| ❸ | 편집 아이콘 | `Icon(edit_outlined)` | `sizeIconXSmall` 16 | `_kAccent` 70% |
| ❸ | 슬라이더 활성 트랙 | `SliderTheme` | `heightSliderTrack` 4 | `_kAccent` |
| ❸ | 슬라이더 비활성 트랙 | `SliderTheme` | — | `_kSliderTrack` |
| ❸ | 슬라이더 thumb | `RoundSliderThumbShape(r: radiusSliderThumb 10)` | — | `Colors.white` |
| ❸ | 슬라이더 오버레이 | `SliderTheme` | — | `_kAccent` 15% |
| ❸ | 최솟·최대값 레이블 | `Text` | `textStyleCaption` 14sp / w400 | `_kTextSecondary` |

> 키 슬라이더: min 100, max 220, divisions 120 (1cm 단위).
> 값 버튼 탭 → `_editHeight()` 다이얼로그. cm ↔ ft 단위 자동 반영.

---

## ❹ 몸무게 슬라이더 카드 (`_InputSlider`)

❸과 동일 구조.

> 몸무게 슬라이더: min 20, max 150, divisions 260 (0.5kg 단위).
> 값 버튼 탭 → `_editWeight()` 다이얼로그. kg ↔ lb 단위 자동 반영.

---

## ❺ 건강 체중 범위 카드 (`_HealthyWeightCard`)

```
┌─────────────────────────────────────────────┐  _kCardBg / radiusCard 16 / paddingCard all20
│  ╔══════╗  건강 체중 범위                    │
│  ║  ⊙  ║  55.8 kg – 69.5 kg               │  ← 항상 표시
│  ╚══════╝  현재 체중이 건강 범위 안에 있습니다 │  ← 범위 내일 때만 표시
└─────────────────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❺ | 카드 테두리 (범위 내) | `Border.all` | — | `#4CAF50` (green) 40% |
| ❺ | 카드 테두리 (범위 밖) | `Border.all` | — | `_kTextSecondary` 15% |
| ❺ | 아이콘 영역 | `Container` `sizeIconContainer` 44×44 | — | `#4CAF50` 12% / `radiusIconContainer` 10 |
| ❺ | 아이콘 (범위 내) | `Icon(check_circle_outline)` `sizeIconMedium` 22 | — | `#4CAF50` |
| ❺ | 아이콘 (범위 밖) | `Icon(monitor_weight_outlined)` `sizeIconMedium` 22 | — | `_kTextSecondary` |
| ❺ | "건강 체중 범위" 레이블 | `Text` | `textStyleSectionTitle` 13sp / w600 | `_kTextSecondary` |
| ❺ | 체중 범위 텍스트 | `Text` | `textStyleValue` 16sp / w600 | `_kTextPrimary` |
| ❺ | 범위 내 확인 메시지 | `Text` | `textStyleCaption` 14sp / w400 | `#4CAF50` |

> 글로벌 기준: 정상 BMI 18.5 ~ 24.9 역산. 아시아태평양: 18.5 ~ 22.9 역산.
> `_isMetric` 에 따라 kg / lb로 표시. 아이콘 영역과 텍스트 영역 간격: `SizedBox(width: 14)`.

---

## ❻ BMI 범주 안내 그리드 (`_CategoryGrid`)

```
── 4범주 (글로벌) — 1행 ──────────────────────────
┌──────────┬──────────┬──────────┬──────────┐
│  저체중   │   정상   │  과체중  │   비만   │
│ 18.5 미만│18.5–24.9│25.0–29.9│30.0 이상│
└──────────┴──────────┴──────────┴──────────┘

── 5범주 (아시아태평양) — 2행 (3+2) ─────────────
┌──────────┬──────────┬──────────┐
│  저체중   │   정상   │  과체중  │
│ 18.5 미만│18.5–22.9│23.0–24.9│
└──────────┴──────────┴──────────┘
     ┌──────────────┬──────────────┐
     │  비만 1단계   │  비만 2단계  │
     │  25.0–29.9   │  30.0 이상   │
     └──────────────┴──────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❻ | 행 간격 | `SizedBox(height: 8)` | — | — |
| ❻ | 셀 margin | `EdgeInsets.symmetric(horizontal: 3)` | — | — |
| ❻ | 셀 padding | `EdgeInsets.symmetric(vertical: 9, horizontal: 4)` | — | — |
| ❻ | 셀 배경 (활성) | `AnimatedContainer` | — | `cat.color` 18% |
| ❻ | 셀 배경 (비활성) | `AnimatedContainer` | — | `_kCardBg` |
| ❻ | 셀 테두리 (활성) | `Border.all` w1.5 | — | `cat.color` 60% |
| ❻ | 셀 테두리 (비활성) | `Border.all` | — | `Colors.transparent` |
| ❻ | 셀 borderRadius | `radiusInput` 12 | — | — |
| ❻ | 범주명 (활성) | `Text` | `textStyleCaption` 14sp / **w600** | `cat.color` |
| ❻ | 범주명 (비활성) | `Text` | `textStyleCaption` 14sp / w400 | `_kTextSecondary` |
| ❻ | BMI 범위 (활성) | `Text` | `textStyleLabelMedium` 12sp / w500 | `cat.color` 80% |
| ❻ | BMI 범위 (비활성) | `Text` | `textStyleLabelMedium` 12sp / w500 | `_kTextSecondary` 60% |
| ❻ | 애니메이션 | `AnimatedContainer(250ms)` | — | — |

> 5셀일 때: `categories.sublist(0, 3)` 첫 행 / `categories.sublist(3)` 둘째 행. `Expanded`로 균등 분배.

---

## 직접 입력 다이얼로그

| 항목 | 값 |
|------|----|
| 위젯 | `AlertDialog` |
| 배경 | `_kCardBg` #1E3248 |
| 제목 | `textStyleValue` 16sp w600 / `_kTextPrimary` |
| 입력 스타일 | `textStyleValue` / `_kTextPrimary` |
| 단위 suffix | `textStyleCaption` / `_kTextSecondary` |
| 활성 테두리 | `UnderlineInputBorder` strokeWidth 2 / `_kAccent` |
| 비활성 테두리 | `UnderlineInputBorder` / `_kAccent` |
| "취소" | `textStyleCaption` / `_kTextSecondary` |
| "확인" | `textStyleCaption` / `_kAccent` |

> 키보드: `numberWithOptions(decimal: true)`. 범위 초과 값은 `clamp` 처리.

---

## 스크롤 페이드

| 속성 | 값 |
|------|----|
| 위젯 | `ScrollFadeView(controller: _scrollController)` |
| fadeColor | `_kBgBottom` #0D1B2A |
| 패딩 top | `MediaQuery.padding.top + kToolbarHeight` |
| 패딩 bottom | `MediaQuery.padding.bottom + 24` |
| 패딩 horizontal | `paddingScreenH` 16 |

---

## 색상 팔레트

| 상수 | hex / 값 | 용도 |
|------|---------|------|
| `_kBgTop` | `#1A2E44` | 배경 그라디언트 상단 / 스크롤 시 AppBar 배경 (85%) |
| `_kBgBottom` | `#0D1B2A` | 배경 그라디언트 하단 / 스크롤 페이드 색상 |
| `_kAccent` | `#4FC3F7` | 액센트 (스카이 블루) — 슬라이더 트랙·값 버튼·다이얼로그 |
| `_kTextPrimary` | `Colors.white` | 주 텍스트 (BMI 수치, 체중 범위, 버튼 레이블) |
| `_kTextSecondary` | `#B0BEC5` | 보조 텍스트 (레이블, 기준 배지, 최솟·최대값) |
| `_kCardBg` | `#1E3248` | 카드 배경 (슬라이더·건강범위·범주 셀) |
| `_kSliderTrack` | `#2A4060` | 슬라이더 비활성 트랙 + 게이지 트랙 배경 |
| BMI 저체중 | `#5B9BD5` | 범주 색상 (파랑) |
| BMI 정상 | `#4CAF50` | 범주 색상 (초록) |
| BMI 과체중 (아시아) | `#FFCC02` | 범주 색상 (노랑) |
| BMI 과체중 (글로벌) / 비만1 | `#FF9800` | 범주 색상 (주황) |
| BMI 비만 / 비만2 | `#F44336` | 범주 색상 (빨강) |
