# UI 토큰 컨벤션

> CalcMate 계산기 화면을 구현할 때 **어떤 토큰을 어떤 상황에서 써야 하는지** 정의한 문서.
> 토큰 값 자체는 `lib/core/theme/app_design_tokens.dart` 참조.

---

## 기본 원칙

- `fontSize`를 직접 숫자로 쓰지 않는다. 반드시 컴포넌트 토큰(`Cm*.text*`) 또는 전역 TextStyle 상수를 사용하고 `.copyWith(color:)`로 색상만 주입한다.
- `BorderRadius`, 패딩, 크기도 동일하다. 토큰이 있으면 반드시 토큰을 쓴다.
- 토큰이 없는 값은 위젯 파일 상단에 `_k*` 로컬 상수로 선언하고 사용한다.
- 컴포넌트에 해당하는 `Cm*` 토큰 클래스가 있으면 전역 상수보다 우선 사용한다.

---

## 전역 상수

### 간격 / 크기

| 상수 | 값 | 용도 |
|------|-----|------|
| `screenPaddingH` | 16 | 화면 좌우 기본 패딩 |
| `spacingSection` | 16 | 카드/섹션 간 수직 간격 |
| `spacingUnit` | 6 | 숫자 ↔ 단위 텍스트 간격 |
| `radiusCard` | 16 | 카드/컨테이너 기본 borderRadius |
| `radiusInput` | 12 | 입력 필드 borderRadius |

### TextStyle

| 상수 | fontSize | weight | 용도 |
|------|----------|--------|------|
| `textStyleCaption` | 12 | w400 | 보조 설명, 단위, 소형 레이블 |
| `rowLabel` | 16 | w500 | 레이블 + 컨트롤 구조의 행 레이블 ("부양가족 수" 등) |
| `sectionLabel` | 14 | w600 | 섹션 타이틀 레이블 (생년월일, 날짜 선택 등) |
| `textStyle16` | 16 | w600 | 본문 텍스트 |
| `textStyle18` | 18 | w400 | 결과/변환값 (목록 내 결과 행 등) |
| `textStyle52` | 52 | w300 | 대형 단독 수치 (BMI 수치 등) |
| `textLargeInput` | 40 | w300 | 대형 입력값 표시 |
| `textMediumResult` | 22 | w400 | 중형 결과값 |
| `textEmptyGuide` | 16 | w400 | 빈 상태 안내 메시지 |
| `inputFieldInnerLabel` | 16 | w400 | 입력 필드 내부 텍스트 |
| `modalButtonLabel` | 16 | w400 | 모달 확인 버튼 레이블 |

### 키패드

| 상수 | 값 | 용도 |
|------|-----|------|
| `keypadButtonHeightLarge` | 68 | 버튼 높이 기본형 (기본·환율·부가세 계산기) |
| `keypadButtonHeightMedium` | 56 | 버튼 높이 중형 (단위 변환기) |
| `keypadButtonHeightPrimary` | 52 | 확인 버튼 높이 |
| `keypadBackspaceSize` | 26 | 백스페이스 아이콘 크기 |
| `keypadNumberText` | 22 / w400 | 숫자 버튼 텍스트 |
| `keypadOperatorText` | 28 / w400 | 연산자/등호 버튼 텍스트 |

---

## 1. 금액 / 결과 표시

### 1-1. 숫자 크기 선택 기준

| 컨텍스트 | 토큰 | 대표 사용처 |
|---------|------|-----------|
| 화면 전체를 채우는 단독 대형 수치 | `textStyle52` (52/w300) | BMI 수치 |
| 카드 내 결과 숫자 | `CmResultCard.resultText` (40/w300) | 실수령액, 부가세 |
| 카드 내 입력 숫자 | `CmInputCard.inputText` (32/w300) | 급여 입력 카드 |
| 나란히 표시되는 변환 쌍 | `CmCurrencyRow.amountText` (28/w300) | 환율 계산기 |
| 중형 단독 결과값 | `textMediumResult` (22/w400) | 날짜 계산기 |
| 목록 내 결과 행 | `textStyle18` (18/w400) | 단위 변환기 |

### 1-2. 금액 카드 내부 구성 요소

```
┌────────────────────────────────┐
│  실수령액                       │  ← 카드 타이틀 (CmResultCard.titleText)
│                                │
│              3,737,310 원      │  ← 결과 숫자 (CmResultCard.resultText)
│                                │    단위 (CmResultCard.unitText)
│        연 환산 44,847,720 원   │  ← 보조 텍스트 (CmResultCard.subText)
└────────────────────────────────┘
```

**CmInputCard (입력 표시 카드)**

| 요소 | 토큰 | fontSize / weight |
|------|------|------------------|
| 카드 타이틀 ("연봉", "총 금액") | `CmInputCard.titleText` | 14 / w800 |
| 입력 숫자 | `CmInputCard.inputText` | 32 / w300 |
| 단위 ("원", "USD") | `CmInputCard.unitText` | 16 / w400 |
| 보조 텍스트 ("월 3,750,000 원") | `CmInputCard.subText` | 14 / w400 |

**CmResultCard (결과 표시 카드)**

| 요소 | 토큰 | fontSize / weight |
|------|------|------------------|
| 카드 타이틀 ("실수령액") | `CmResultCard.titleText` | 14 / w800 |
| 결과 숫자 | `CmResultCard.resultText` | 40 / w300 |
| 단위 ("원") | `CmResultCard.unitText` | 16 / w400 |
| 보조 텍스트 ("연 환산", "연 실수령") | `CmResultCard.subText` | 14 / w400 |

### 1-3. 세부 항목 행 (`CmListCard`)

공제 내역, 세율 목록 등 헤더 + 항목 구조의 카드.

| 요소 | 토큰 | fontSize / weight |
|------|------|------------------|
| 헤더 레이블 ("공제 합계") | `CmListCard.headerLabel` | 15 / w600 |
| 헤더 합계 금액 | `CmListCard.headerValue` | 16 / w600 |
| 항목 레이블 ("국민연금") | `CmListCard.itemLabel` | 14 / w400 |
| 항목 금액 | `CmListCard.itemValue` | 15 / w600 |

---

## 2. 카드 / 컨테이너

| 속성 | 토큰 | 값 |
|------|------|-----|
| 카드 borderRadius | `radiusCard` | 16 |
| 입력 카드 내부 패딩 | `CmInputCard.padding` | h:20 v:18 |
| 결과 카드 내부 패딩 | `CmResultCard.padding` | all 20 |
| 목록 카드 헤더 패딩 | `CmListCard.headerPadding` | h:16 v:14 |
| 목록 카드 항목 패딩 | `CmListCard.itemPadding` | h:16 v:12 |
| 화면 수평 패딩 | `screenPaddingH` | 16 |

> 카드 배경·테두리·그림자 색상은 화면별 `*_colors.dart`에서 정의한다.

---

## 3. 키패드

| 속성 | 토큰 | 비고 |
|------|------|------|
| 버튼 높이 (기본 — 기본·환율·부가세·더치페이) | `keypadButtonHeightLarge` (68) | |
| 버튼 높이 (중형 — 단위 변환·날짜·실수령액) | `keypadButtonHeightMedium` (56) | |
| 확인 버튼 높이 | `keypadButtonHeightPrimary` (52) | |
| 버튼 borderRadius | `radiusInput` (12) | InkWell + Container 동일 적용 |
| 숫자 텍스트 | `keypadNumberText` (22/w400) | |
| 연산자·기호 텍스트 | `keypadOperatorText` (28/w400) | |
| 백스페이스 아이콘 크기 | `keypadBackspaceSize` (26) | |
| 모달 내부 패딩 | `CmKeypad.padding` | fromLTRB(16,12,16,0) |
| 입력 표시 패딩 | `CmKeypad.displayPadding` | h:20 v:16 |
| 입력 표시 ↔ 키패드 간격 | `CmKeypad.displaySpacing` (16) | |
| 행 간격 | `CmKeypad.rowSpacing` (8) | |
| 버튼 좌우 간격 | `CmKeypad.buttonSpacingH` (4) | |

---

## 4. 바텀시트 (`CmSheet`)

```
┌──────────────────────────────────┐  ← borderRadius: CmSheet.radius (20)
│          ━━━━━━                  │  ← 핸들
│                                  │  ← 콘텐츠 (화면별)
│  ┌──────── 확인 ────────────┐  │  ← 확인 버튼
└──────────────────────────────────┘
```

| 속성 | 토큰 | 값 |
|------|------|-----|
| 시트 상단 borderRadius | `CmSheet.radius` | 20 |
| 핸들 너비 | `CmSheet.handleWidth` | 40 |
| 핸들 높이 | `CmSheet.handleHeight` | 4 |
| 핸들 borderRadius | `CmSheet.handleRadius` | 2 |
| 핸들 상단 여백 | `CmSheet.handleTopSpacing` | 12 |
| 핸들 하단 여백 | `CmSheet.handleBottomSpacing` | 16 |
| 확인 버튼 높이 | `keypadButtonHeightPrimary` | 52 |
| 확인 버튼 borderRadius | `radiusInput` | 12 |
| 시트 내부 패딩 | `CmSheet.padding` | all 16 |
| 시트 제목 | `CmSheet.titleText` | 18 / w600 |
| 아이템 타이틀 | `CmSheet.itemTitle` | 16 / w400 |
| 아이템 서브텍스트 | `CmSheet.itemSubtext` | 14 / w400 |

---

## 5. 스텝 버튼 (`CmRoundButton` + `CmStepValue`)

인원 수 조절, 부양가족 수 조절 등 정수값을 1씩 올리고 내리는 버튼.

```
  ┌──────┐        ┌──────┐
  │  −   │  1명   │  +   │
  └──────┘        └──────┘
```

| 속성 | 토큰 | 값 |
|------|------|-----|
| 소형 버튼 | `CmRoundButton.small` | size:24 / radius:12 / iconSize:16 |
| 중형 버튼 (기본) | `CmRoundButton.medium` | size:28 / radius:14 / iconSize:18 |
| 대형 버튼 | `CmRoundButton.large` | size:32 / radius:16 / iconSize:20 |
| 값 표시 텍스트 | `CmStepValue.text` | 18 / w600 |
| 값 표시 너비 | `CmStepValue.width` | 44 |

> 활성/비활성 배경·테두리 색상은 화면별 `*_colors.dart` 참조.

---

## 6. 드롭다운 (`CmDropdown`) / 슬라이더 (`CmSlider`)

**CmDropdown**

| 속성 | 토큰 | 값 |
|------|------|-----|
| 높이 | `CmDropdown.height` | 44 |
| borderRadius | `CmDropdown.radius` | 10 |
| 텍스트 | `CmDropdown.text` | 16 / w600 |
| 아이콘 크기 | `CmDropdown.iconSize` | 18 |

**CmSlider**

| 속성 | 토큰 | 값 |
|------|------|-----|
| 트랙 높이 | `CmSlider.trackHeight` | 4 |
| Thumb 반지름 | `CmSlider.thumbRadius` | 10 |
| 오버레이 반지름 | `CmSlider.overlayRadius` | 18 |
| 범위 레이블 텍스트 | `CmSlider.rangeLabel` | 14 / w500 |

---

## 7. 탭 / 칩 (`CmTab`)

| 속성 | 토큰 | 값 |
|------|------|-----|
| 칩 borderRadius | `CmTab.radius` | 20 |
| 칩 내부 패딩 | `CmTab.padding` | h:14 v:8 |
| 칩/탭 텍스트 | `CmTab.text` | 14 / w500 |
| 탭 활성 텍스트 | `CmTab.text` + `.copyWith(fontWeight: FontWeight.w700)` | |
| 탭 행 높이 | `CmTab.height` | 48 |
| 아이콘 크기 | `CmTab.iconSize` | 16 |

---

## 8. 섹션 레이블

| 역할 | 토큰 | fontSize / weight |
|------|------|------------------|
| AppBar 타이틀 | `CmAppBar.titleText` | 20 / w700 |
| 바텀시트 제목 | `CmSheet.titleText` | 18 / w600 |
| 입력/결과 카드 타이틀 | `CmInputCard.titleText` / `CmResultCard.titleText` | 14 / w800 |
| 목록 카드 헤더 | `CmListCard.headerLabel` | 15 / w600 |
| 섹션 레이블 (날짜 선택 등) | `sectionLabel` | 14 / w600 |
| 행 레이블 ("부양가족 수" 등) | `rowLabel` | 16 / w500 |
| 보조 설명, 단위 텍스트 | `textStyleCaption` | 12 / w400 |

---

## 사용 패턴

```dart
// 입력 카드 타이틀
Text('연봉', style: CmInputCard.titleText.copyWith(color: kColor))

// 결과 카드 결과값
Text(amount, style: CmResultCard.resultText.copyWith(color: kColor))

// 전역 캡션 텍스트 (보조 설명, 단위)
Text('원', style: textStyleCaption.copyWith(color: kColor))

// 키패드 버튼 — 연산자 여부에 따라 분기
style: (isOperator
    ? keypadOperatorText
    : keypadNumberText
  ).copyWith(color: _textColor)
```
