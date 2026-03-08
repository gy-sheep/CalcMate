# 부가세 계산기 구현 명세

> **브랜치**: `fix/vat-checkbox-tap-target`
> **목적**: 체크박스 → 인라인 토글 교체, 모드별 결과 카드 구조 변경

---

## 프로젝트 구조 및 작업 범위

> 기본 아키텍처: [`docs/architecture/ARCHITECTURE.md`](../architecture/ARCHITECTURE.md) 참고

**작업 파일**

| 파일 | 작업 |
|------|------|
| `lib/presentation/vat_calculator/widgets/receipt_card.dart` | 수정 — 체크박스 제거, `VatModeToggle` 추가, 결과 행 구조 변경 |
| `lib/presentation/vat_calculator/vat_calculator_viewmodel.dart` | 유지 — 변경 없음 |
| `lib/domain/models/vat_calculator_state.dart` | 유지 — 변경 없음 |
| `lib/domain/usecases/vat_calculate_usecase.dart` | 유지 — 변경 없음 |

**데이터 흐름**

```
[VatModeToggle 탭]
    └─ VatCalculatorIntent.modeChanged(mode)
        └─ VatCalculatorViewModel._onModeChanged()
            └─ state.copyWith(mode: mode)
                └─ ReceiptCard rebuild
                    ├─ 첫 번째 행: 공급가액 or 합계 (모드에 따라)
                    ├─ 부가세 행
                    └─ 강조 행: 합계 or 공급가액 (모드에 따라)
```

---

## 배경 및 문제

| 문제 | 영향 |
|------|------|
| 체크박스 터치 영역이 20×20px로 너무 작음 | 탭이 불규칙하게 인식됨 |
| "부가세 별도" 라벨이 입력 모드를 직관적으로 설명하지 못함 | 소비자가 합계금액 입력 모드로 전환해야 함을 인지하기 어려움 |
| 두 모드 모두 동일한 결과 행 순서(공급가액→부가세→합계)로 표시 | 합계금액 모드에서 알고 싶은 공급가액이 강조되지 않음 |

---

## 목표

- 인라인 토글(`공급가액 | 합계금액`)로 모드 전환 의도를 명확히 전달
- 모드에 따라 결과 카드 행 순서와 강조 행이 달라져, 항상 "계산된 값"이 강조됨
- 계산 로직(`VatCalculateUseCase`) 변경 없음

---

## 구현 범위

### 1. `lib/presentation/vat_calculator/widgets/receipt_card.dart`

영수증 카드 위젯. 이번 작업의 유일한 변경 파일.

**주요 구성 요소**

- `ReceiptCard`: 카드 전체 레이아웃. `isExclusive` 플래그로 모드 분기
- `VatModeToggle`: 인라인 토글 위젯 (신규 추가)
- `_buildTaxRateRow()`: 세율 행 빌더 — 변경 없음
- `ReceiptRow`: 일반 결과 행 — 변경 없음

**`VatModeToggle` 설계**

```dart
class VatModeToggle extends StatelessWidget {
  final VatMode mode;
  final ValueChanged<VatMode> onChanged;
}
```

- `Row(mainAxisAlignment: start)` — 아래 결과 행 라벨과 좌측 정렬 일치
- 각 옵션: `GestureDetector(HitTestBehavior.opaque)` + `Padding(vertical: 4)`
- 구분선: `Container(w:1, h:14, color: kVatReceiptDash)` / 좌우 margin: 12
- 선택 스타일: `kVatReceiptText` / w600
- 미선택 스타일: `kVatReceiptSecondary` / w400

**결과 카드 모드별 분기**

```
isExclusive == true (공급가액 모드):
  ReceiptRow(label: '공급가액', amount: supplyAmount)
  _buildTaxRateRow()                                   ← 부가세
  실선 구분선
  강조 행: label='합계', value=totalAmount

isExclusive == false (합계금액 모드):
  ReceiptRow(label: '합계', amount: totalAmount)
  _buildTaxRateRow()                                   ← 부가세
  실선 구분선
  강조 행: label='공급가액', value=supplyAmount
```

**설계 결정**

- 체크박스 대신 인라인 토글: 두 옵션이 동시에 보여 전환 가능성을 즉시 인지할 수 있음
- 결과 행 순서 변경: "입력값 → 부가세 → 계산된 값(강조)" 흐름으로 통일
- 입력 라벨(`공급가액 입력` / `합계금액 입력`) 미사용: 토글 자체가 맥락을 전달하므로 불필요

---

## 상태 / ViewModel / UseCase

### `VatMode` (변경 없음)

```dart
enum VatMode { exclusive, inclusive }
// exclusive: 공급가액 입력 → 부가세·합계 계산
// inclusive: 합계 입력 → 공급가액·부가세 역산
```

### `VatCalculatorIntent.modeChanged` (변경 없음)

```dart
VatCalculatorIntent.modeChanged(VatMode mode)
// → _onModeChanged(): 세율 편집 중이면 applyTaxRate 후 모드 전환
```

### `VatCalculateUseCase.execute()` (변경 없음)

| 모드 | 입력 | 계산 |
|------|------|------|
| exclusive | 공급가액 | 부가세 = 공급가액 × 세율, 합계 = 공급가액 + 부가세 |
| inclusive | 합계 | 공급가액 = ⌊합계 / (1 + 세율/100)⌋, 부가세 = 합계 − 공급가액 |

---

## 구현 순서

```
1. receipt_card.dart
   ├─ 입력 라벨 제거
   ├─ 체크박스 GestureDetector → VatModeToggle 교체
   ├─ 결과 행 구조 모드별 분기 (if/else)
   └─ VatModeToggle 위젯 클래스 추가
2. flutter analyze로 오류 확인
```

---

## 범위 외 (이번 작업 제외)

- 세율 로직 변경 — 현재 UseCase 그대로 유지
- 키패드 변경 — 변경 없음
- 애니메이션 전환 효과 — 현재 즉시 전환
