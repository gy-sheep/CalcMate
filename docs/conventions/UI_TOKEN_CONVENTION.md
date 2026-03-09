# UI 토큰 컨벤션

> CalcMate 계산기 화면을 구현할 때 **어떤 토큰을 어떤 상황에서 써야 하는지** 정의한 문서.
> 토큰 값 자체는 `lib/core/theme/app_design_tokens.dart` 참조.

---

## 기본 원칙

- `fontSize`를 직접 숫자로 쓰지 않는다. 항상 `AppTokens.textStyle*`를 사용하고 `.copyWith(color:)`로 색상만 주입한다.
- `BorderRadius`, 패딩, 크기도 동일하다. 토큰이 있으면 반드시 토큰을 쓴다.
- 토큰이 없는 값은 위젯 파일 상단에 `_k*` 로컬 상수로 선언하고 사용한다.

---

## 1. 금액 / 결과 표시

### 1-1. 숫자 크기 선택 기준

| 컨텍스트 | 토큰 | 대표 사용처 |
|---------|------|-----------|
| 화면 전체를 채우는 단독 입력·결과 | `textStyleResult56` | 기본 계산기, 나이 계산기 |
| 화면의 주요 공간을 차지하는 단독 수치 | `textStyleResult52` | BMI |
| 카드 내 주요 결과 (단독) | `textStyleResult48` | 날짜 계산기, 실수령액 |
| 카드 내 입력 표시 / 주요 결과 | `textStyleResult40` | 부가세, 실수령액 급여 입력 |
| 카드 내 핵심 결과 (여러 결과 중 대표) | `textStyleResult36` | 더치페이 1인당, 할인 최종가 |
| 카드 내 합계·총액 | `textStyleResult32` | 더치페이 총액 |
| 나란히 표시되는 변환 쌍 | `textStyleResult28` | 환율 계산기 |
| 나란히 표시되는 두 입력 필드 | `textStyleResult24` | 할인 계산기 원가·할인율 |
| 단위 보조 숫자 ("세", "개월") | `textStyleResult22` | 나이 계산기 |
| 목록 내 결과 행 | `textStyleResult18` | 단위 변환기 |

### 1-2. 금액 카드 내부 구성 요소

하나의 금액/결과 카드 안에는 아래 요소들이 조합된다. 각 역할에 맞는 토큰을 사용한다.

```
┌────────────────────────────────┐
│  실수령액                       │  ← 카드 레이블
│                                │
│              3,737,310 원      │  ← 결과 숫자 + 단위
│        연 환산 44,847,720 원   │  ← 보조 텍스트
└────────────────────────────────┘
```

| 요소 | 토큰 | 비고 |
|------|------|------|
| 카드 레이블 ("실수령액", "총 금액") | `textStyleSectionTitle` | 좌측 정렬 |
| 결과 숫자 | `textStyleResult*` | 컨텍스트에 따라 위 표 참고 |
| 주 단위 ("원", "USD") | `textStyleBody` | 숫자와 baseline 정렬 |
| 보조 텍스트 ("연 환산", "월 급여") | `textStyleCaption` | 숫자 하단 |

### 1-3. 세부 항목 행 (공제 내역, 환율 목록 등)

```
│  국민연금          185,850 원  │
```

| 요소 | 토큰 |
|------|------|
| 항목 레이블 | `textStyleCaption` |
| 항목 값 | `textStyleValue` |

---

## 2. 카드 / 컨테이너

| 속성 | 토큰 | 예외 |
|------|------|------|
| 카드 borderRadius | `radiusCard` (16) | — |
| 카드 내부 패딩 (기본) | `paddingCard` (EdgeInsets.all(20)) | — |
| 카드 내부 패딩 (섹션 헤더 행) | `paddingCardInner` (16) × symmetric | 헤더 h:16, 항목 h:16 |
| 입력 필드 내부 패딩 | `paddingInputField` (h:20 v:14) | — |
| 칩 내부 패딩 | `paddingChip` (h:14 v:8) | — |
| 화면 수평 패딩 | `paddingScreenH` (16) | — |

> 카드 배경·테두리·그림자 색상은 화면별 `*_colors.dart`에서 정의한다.

---

## 3. 키패드

| 속성 | 토큰 | 비고 |
|------|------|------|
| 버튼 높이 (기본 — 기본·환율·부가세·더치페이) | `heightButtonLarge` (68) | |
| 버튼 높이 (소형 — 단위 변환·날짜·실수령액) | `heightButtonMedium` (56) | |
| 버튼 borderRadius | `radiusInput` (12) | InkWell + Container 동일 적용 |
| 숫자 텍스트 | `textStyleKeypadNumber` | |
| 연산자·기호 텍스트 | `textStyleKeypadOperator` | |
| 백스페이스 아이콘 크기 | `sizeKeypadBackspace` (26) | |

---

## 4. 바텀시트

### 구조

```
┌──────────────────────────────────┐  ← borderRadius: radiusBottomSheet (20)
│          ━━━━━━                  │  ← 핸들
│                                  │  ← 콘텐츠 (화면별)
│  ┌──────── 확인 ────────────┐  │  ← 확인 버튼
└──────────────────────────────────┘
```

| 속성 | 토큰 |
|------|------|
| 시트 상단 borderRadius | `radiusBottomSheet` (20) |
| 핸들 너비 | `widthSheetHandle` (36) |
| 핸들 높이 | `heightSheetHandle` (4) |
| 핸들 borderRadius | `radiusSheetHandle` (2) |
| 핸들 하단 여백 | `spacingSheetHandle` (20) |
| 확인 버튼 높이 | `heightButtonPrimary` (52) |
| 확인 버튼 borderRadius | `radiusInput` (12) |

---

## 5. 스텝 버튼 (±)

인원 수 조절, 부양가족 수 조절 등 정수값을 1씩 올리고 내리는 버튼.

```
  ┌──────┐        ┌──────┐
  │  −   │  1명   │  +   │
  └──────┘        └──────┘
```

| 속성 | 토큰 |
|------|------|
| 버튼 크기 (정사각형) | `sizeStepButton` (36) |
| borderRadius | `radiusStepButton` (8) |
| 아이콘 크기 | `sizeIconStep` (18) |

> 활성/비활성 배경·테두리 색상은 화면별 `*_colors.dart` 참조.

---

## 6. 드롭다운 / 조절 바

단위 선택, 통화 선택처럼 값을 선택하거나 ±를 포함한 컨트롤 행.

```
  [−]   [100만 ▾]   [+]
```

| 속성 | 토큰 |
|------|------|
| 컨트롤 높이 (드롭다운, ± 버튼) | `heightControl` (44) |
| 드롭다운 borderRadius | `radiusChip` (20) |
| 드롭다운 아이콘 크기 | `sizeIconDropdown` (18) |
| 드롭다운 텍스트 | `textStyleBody` w600 |

---

## 7. 슬라이더

| 속성 | 토큰 |
|------|------|
| 트랙 높이 | `heightSliderTrack` (4) |
| Thumb 반지름 | `radiusSliderThumb` (10) |
| 오버레이 반지름 | `radiusSliderOverlay` (18) |
| 범위 레이블 텍스트 | `textStyleLabelMedium` |

---

## 8. 칩 / 탭 레이블

| 속성 | 토큰 |
|------|------|
| 칩 borderRadius | `radiusChip` (20) |
| 칩 내부 패딩 | `paddingChip` (h:14 v:8) |
| 칩 텍스트 | `textStyleChip` |
| 탭 활성 텍스트 | `textStyleChip` + w700 |
| 태그·뱃지 borderRadius | `radiusTag` (6) |

---

## 9. 섹션 레이블

| 역할 | 토큰 |
|------|------|
| AppBar 타이틀 | `textStyleAppBarTitle` |
| 바텀시트 제목 | `textStyleSheetTitle` |
| 카드·섹션 제목 ("실수령액", "총 금액") | `textStyleSectionTitle` |
| 일반 레이블 ("부양가족 수", "인원") | `textStyleBody` |
| 보조 설명, 단위 텍스트 | `textStyleCaption` |
| 수치 강조 (보조 값) | `textStyleValue` |

---

## 10. 애니메이션

| 상황 | 토큰 |
|------|------|
| 버튼·칩 활성/비활성 전환 | `durationFast` (150ms) |
| 카드·오버레이 등장 | `durationNormal` (200ms) |
| 페이지·탭 전환 | `durationPage` (280ms) |

---

## 신규 추가된 토큰 (이 문서 기준)

이 컨벤션 수립 시점에 `AppTokens`에 추가된 토큰 목록.

| 토큰 | 값 | 분류 |
|------|----|------|
| `widthSheetHandle` | 36 | Bottom Sheet |
| `heightSheetHandle` | 4 | Bottom Sheet |
| `radiusSheetHandle` | 2 | Bottom Sheet |
| `spacingSheetHandle` | 20 | Bottom Sheet |
| `heightButtonPrimary` | 52 | Button |
| `heightControl` | 44 | Control |
| `sizeStepButton` | 36 | Control |
| `radiusStepButton` | 8 | Control |
| `radiusSliderOverlay` | 18 | Slider |
| `durationFast` | 150ms | Animation |
| `durationNormal` | 200ms | Animation |
| `durationPage` | 280ms | Animation |
