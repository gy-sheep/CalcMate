# 더치페이 — 화면 디자인

> 구현 참조용. 레이아웃·위젯·스타일·색상을 한 곳에서 확인한다.
> 색상 상수는 `dutch_pay_colors.dart` 참조.

---

## 배경

| 속성 | 값 |
|------|----|
| 종류 | `LinearGradient` · topLeft → bottomRight (3색) |
| 좌상 | `kDutchBg1` #FFF0F8 (라이트 핑크) |
| 중간 | `kDutchBg2` #F5E8FF (라벤더) |
| 우하 | `kDutchBg3` #EEE4FF (바이올렛) |
| 비고 | `extendBodyBehindAppBar: true` → 그라디언트가 상태바 뒤까지 연장 |

---

## 레이아웃 & 스타일

```
┌──────────────────────────────────┐
│  ←  더치페이                     │  ← ❶ AppBar
├──────────────────────────────────┤
│  [ 1/N  |  각자 계산 ]           │  ← ❷ 탭바 (탄성 스트레치)
├──────────────────────────────────┤
│                                  │
│   ← 탭 0: 균등 분배 (1/N) →     │  ← ❸ 균등 분배 뷰
│   ← 탭 1: 각자 계산 →           │     ❹ 각자 계산 뷰
│                                  │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  ← ❺ 스크롤 페이드 (탭 0)
├──────────────────────────────────┤  ← ❻ 구분선
│  7   8   9                       │  ← ❼ 키패드 (탭 0 전용)
│  4   5   6                       │
│  1   2   3                       │
│  00  0   ⌫                      │
└──────────────────────────────────┘
```

> **구조 메모**: `DutchPayTabBar` + `PageView(2 pages)` + `AdBannerPlaceholder`.
> 탭 0(1/N)은 `ScrollFadeView(상단)` + `Divider` + `DutchPayKeypad(하단 고정)` 분할.
> 탭 1(각자 계산)은 키패드 없이 독립 레이아웃.

---

## ❶ AppBar

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❶ | 뒤로가기 아이콘 | `Icon(arrow_back_ios)` | `sizeAppBarBackIcon` 20 | `kDutchTextPrimary` |
| ❶ | 타이틀 | `Text` | `textStyleAppBarTitle` 18sp / w600 | `kDutchTextPrimary` |

> `backgroundColor: Colors.transparent` / `elevation: 0` / `scrolledUnderElevation: 0` / `centerTitle: false`

---

## ❷ 탭바 (`DutchPayTabBar` → `AppAnimatedTabBar`)

탭 2개: `['1/N', '각자 계산']`. PageView 오프셋과 실시간 연동.

| 속성 | 값 |
|------|----|
| 탭 행 높이 | 40 |
| 칩 배경 | `kDutchAccent` 12% |
| 칩 테두리 | `kDutchAccent` 25% / radius:20 |
| 칩 글로우 | `kDutchAccent` 25% / blur:8 / spread:1 |
| 하단 언더라인 (전체) | 1px `kDutchDivider` |
| 하단 언더라인 (활성) | 2px `kDutchAccent` + 글로우 (`kDutchAccent` 60% / blur:6 / spread:1) |
| 칩 패드 비율 | 양쪽 0.18 |
| 스트레치 이징 | 좌: `easeInCubic` / 우: `easeOutCubic` |
| 외부 패딩 | `fromLTRB(16, 0, 16, 12)` |

**탭 레이블 애니메이션** (pageOffset 기반 실시간)

| 상태 | 폰트 | 스케일 | 색상 |
|------|------|--------|------|
| 활성 (distance = 0) | `textStyleChip` 14sp / w600 | 1.08× | `kDutchAccent` |
| 비활성 (distance ≥ 1) | `textStyleChip` 14sp / w400 | 1.0× | `kDutchTextTertiary` |
| 중간 | `Color.lerp` | `1.0 + (1 - distance) * 0.08` | lerp 보간 |

---

## ❸ 균등 분배 뷰 (`EqualSplitView`)

```
┌──────────────────────────────────┐
│  총 금액                          │
│  ┌────────────────────────────┐  │
│  │                 45,000  원 │  │  ← 금액 카드
│  └────────────────────────────┘  │
│  인원     [−]  4명  [+]         │  ← 인원 조절
│  정산 단위      [100원 단위 ▾]   │  ← 정산 단위 (한국만)
│  ┌────────────────────────────┐  │
│  │  1인당                     │  │  ← 결과 카드
│  │  11,250원                  │  │
│  └────────────────────────────┘  │
│  ┌────── 결과 공유 ──────────┐  │  ← 공유 버튼
│  └────────────────────────────┘  │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  ← 스크롤 페이드
├──────────────────────────────────┤  ← 구분선
│  키패드                           │
└──────────────────────────────────┘
```

### 금액 카드 (_AmountCard)

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | 컨테이너 | `Container` | padding: h:20 v:14 | 배경: `kDutchCardBg` / radius:16 / border: `kDutchDivider` |
| ❸ | "총 금액" | `Text` | `textStyleCaption` 14sp / w400 | `kDutchTextTertiary` |
| ❸ | 금액 | `Text` | `textStyleResult32` 32sp / w300 | `kDutchTextPrimary` |
| ❸ | "원" | `Text` | `textStyleBody` 16sp / w400 | `kDutchTextTertiary` |

> 라벨→금액: 6dp / 금액↔"원": 4dp

### 인원 조절 (_PeopleRow)

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | "인원" | `Text` | `textStyleBody` 16sp / w500 | `kDutchTextPrimary` |
| ❸ | 인원 수 "N명" | `Text` | `textStyleResult18` 18sp / w600 | `kDutchTextPrimary` |
| ❸ | ± 버튼 | `AnimatedContainer` (150ms) | 36×36 / circle | 활성: bg `kDutchAccent` 12% · border `kDutchAccent` 40% / 비활성: bg 투명 · border `kDutchDivider` |
| ❸ | ± 아이콘 | `Icon` | `sizeIconStep` 18 | 활성: `kDutchAccent` / 비활성: `kDutchTextTertiary` |

> 범위: 2 ~ 30명

### 정산 단위 (_RemainderRow) — 한국 전용

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | "정산 단위" | `Text` | `textStyleBody` 16sp / w500 | `kDutchTextSecondary` |
| ❸ | 단위 피커 | `Container` | padding: h:14 v:8 / radius:20 | 배경: `kDutchCardBg` / border: `kDutchDivider` |
| ❸ | 단위 텍스트 | `Text` | `textStyleBody` 16sp / w500 | `kDutchTextPrimary` |
| ❸ | 드롭다운 아이콘 | `Icon(expand_more)` | `sizeIconDropdown` 18 | `kDutchTextSecondary` |

**정산 단위 바텀시트**

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| — | 시트 제목 "정산 단위" | `Text` | `textStyleSheetTitle` 18sp / w600 | `kDutchTextPrimary` |

### 팁 선택 (_TipRow) — 해외 전용

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | "팁 추가" | `Text` | `textStyleBody` 16sp / w500 | `kDutchTextSecondary` |
| ❸ | 팁 칩 (0%/10%/15%/20%/직접) | `AnimatedContainer` (150ms) | padding: h:16 v:8 / radius:20 | 선택: bg `kDutchAccent` · border `kDutchAccent` / 미선택: bg `kDutchCardBg` · border `kDutchDivider` |
| ❸ | 칩 텍스트 | `Text` | `textStyleChip` 14sp | 선택: `Colors.white` w600 / 미선택: `kDutchTextPrimary` w400 |

> 팁 라벨→칩 행: 8dp / 칩 간격: right 8dp

### 결과 카드 (_ResultCard)

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | 컨테이너 | `Container` | padding: 20 / radius:16 | bg 그라디언트 `kDutchAccent` 8%→3% / border: `kDutchAccent` 20% |
| ❸ | 빈 상태 | `Text` | `textStyleBody` 16sp / w400 | `kDutchTextTertiary` |
| ❸ | "1인당" | `Text` | `textStyleCaption` 14sp / w400 | `kDutchTextTertiary` |
| ❸ | 금액 | `Text` | `textStyleResult36` 36sp / w700 / letterSpacing:-1 | `kDutchAccent` |
| ❸ | "원" | `Text` | `textStyleCaption` 14sp / w400 | `kDutchTextTertiary` |

**끝수 처리 결과 (한국, 나머지 발생 시)**

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | 참여자 행 라벨 | `Text` | `textStyleBody` 16sp / w400 | `kDutchTextSecondary` |
| ❸ | 참여자 행 금액 | `Text` | `textStyleResult22` 22sp / w600 | `kDutchTextPrimary` |
| ❸ | 구분선 | `Divider` | height:20 | `kDutchDivider` 50% |
| ❸ | 총무 행 라벨 | `Text` | `textStyleBody` 16sp / w600 | `kDutchTextPrimary` |
| ❸ | 총무 행 금액 | `Text` | `textStyleResult22` 22sp / w700 | `kDutchAccent` |

### 공유 버튼 (_ShareBtn)

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❸ | 컨테이너 | `Container` | height:52 / radius:16 | 활성: 그라디언트 `#F48FB1`→`kDutchAccent` / 비활성: `kDutchDivider` |
| ❸ | 그림자 (활성만) | `BoxShadow` | — | `kDutchAccent` 30% / blur:12 / offset:(0,4) |
| ❸ | 아이콘 | `Icon(share_outlined)` | `sizeIconSmall` 20 | `Colors.white` |
| ❸ | "결과 공유" | `Text` | `textStyleValue` 16sp / w600 | `Colors.white` |
| ❸ | 투명도 | `AnimatedOpacity` (200ms) | — | 결과 있으면 1.0 / 없으면 0.4 |

---

## ❹ 각자 계산 뷰 (`IndividualSplitView`)

```
┌──────────────────────────────────┐
│  [A] [B] [C]  [+ 추가] [편집]   │  ← 참여자 바
├──────────────────────────────────┤
│  ┌────────────────────────────┐  │
│  │  짜장면    A B    8,000원  │  │  ← 메뉴 리스트
│  │  짬뽕      B C    9,000원  │  │
│  │  탕수육   A B C  24,000원  │  │
│  └────────────────────────────┘  │
│  ┌──── + 메뉴 추가 ──────────┐  │  ← 메뉴 추가 버튼
│  └────────────────────────────┘  │
├──────────────────────────────────┤  ← 구분선
│  총 합계              41,000원   │  ← 결과 섹션
│  ─────────────────────────────  │
│  A  14,667원                    │
│  B  21,667원                    │
│  C  14,666원                    │
│  ┌──── 결과 공유 ──────────┐    │  ← 공유 버튼
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

### 참여자 바 (_ParticipantsBar)

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❹ | 외부 패딩 | — | — | h:16 v:10 |
| ❹ | 참여자 칩 | `ParticipantChip` | — | 배경·텍스트: 인덱스별 순환 (10색) |
| ❹ | "+ 추가" 버튼 | `Container` | padding: h:10 v:5 / radius:20 | border: `kDutchAccent` 40% |
| ❹ | 추가 아이콘 | `Icon(add)` | `sizeIconXSmall` 16 | `kDutchAccent` |
| ❹ | "추가" 텍스트 | `Text` | `textStyleChip` 14sp | `kDutchAccent` |
| ❹ | "편집"/"완료" | `Container` (칩 스타일) | `textStyleChip` 14sp / w500 | `kDutchAccent` · border: `kDutchAccent` 40% / radius:20 |

> 칩 간격: right 8dp / 칩→추가 버튼: 8dp / 추가→편집: 12dp / 참여자 상한: 10명

### ParticipantChip

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| — | 컨테이너 | `AnimatedContainer` (150ms) | padding: h:12 v:6 / radius:20 | 일반: bg `chipBg` · border `chipText` 30% / 선택: bg `chipText` 15% · border `chipText` 100% (w:1.5) |
| — | 선택 표시 | `Icon(check_circle / radio_button_unchecked)` | `sizeIconXSmall` 16 | `chipText` |
| — | 사람 아이콘 | `Icon(person)` | `sizeIconXSmall` 16 | 일반: `chipText` / 비선택: `chipText` 60% |
| — | 이름 | `Text` | `textStyleChip` 14sp / w700 | 일반: `chipText` / 비선택: `chipText` 60% |
| — | 삭제 아이콘 | `Icon(close)` | `sizeIconXSmall` 16 | `chipText` |

### 메뉴 리스트 (_ItemList)

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❹ | 배경 | `ColoredBox` | — | `kDutchReceiptBg` |
| ❹ | 빈 상태 | `Text` | `textStyleBody` 16sp / w400 | `kDutchTextTertiary` |
| ❹ | 메뉴명 | `Text` | `textStyleBody` 16sp / w500 | `kDutchTextPrimary` |
| ❹ | 담당자 칩 | `Container` | padding: h:6 v:2 / radius:4 | bg: `kDutchChipBg[idx]` |
| ❹ | 담당자 아이콘 | `Icon(person)` | `textStyleLabelSmall.fontSize` 10 | `kDutchChipText[idx]` |
| ❹ | 담당자 텍스트 | `Text` | `textStyleLabelSmall` 10sp / w600 | `kDutchChipText[idx]` |
| ❹ | 금액 | `Text` | `textStyleValue` 16sp / w600 | 편집 중: `kDutchAccent` / 일반: `kDutchTextPrimary` |
| ❹ | 편집 아이콘 (기본 상태) | `Icon(edit_outlined)` | `sizeIconXSmall` 16 / padding-right:8 | `kDutchTextTertiary` 60% |
| ❹ | 편집 중 표시 바 (편집 상태) | `Container` | w:3 h:36 / radius:2 / margin-right:10 | `kDutchAccent` |
| ❹ | 항목 패딩 | — | — | h:16 v:12 |
| ❹ | 구분선 | `Divider` | indent:16 endIndent:16 | `kDutchDivider` 50% |

> 담당자 칩 간격: spacing 4dp / 스크롤 페이드: 40dp (항목 3개 초과 시)

### 메뉴 추가 버튼 (_AddMenuButton)

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❹ | 컨테이너 | `Container` | height:48 / radius:16 | bg: `kDutchAccent` 10% / border: `kDutchAccent` 30% |
| ❹ | 아이콘 | `Icon(add_circle_outline)` | `sizeIconSmall` 20 | `kDutchAccent` |
| ❹ | "메뉴 추가" | `Text` | `textStyleValue` 16sp / w600 | `kDutchAccent` |

> 아이콘↔텍스트: 8dp / 외부 패딩: fromLTRB(16, 8, 16, 8)

### 결과 섹션 (_ResultSection)

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❹ | "총 합계" | `Text` | `textStyleCaption` 14sp / w400 | `kDutchTextSecondary` |
| ❹ | 총 금액 | `Text` | `textStyleValue` 16sp / w600 | `kDutchTextPrimary` |
| ❹ | 구분선 | `Divider` | height:1 | `kDutchDivider` 50% |
| ❹ | 참여자 아이콘 | `Icon(person)` | `sizeIconXSmall` 16 | `kDutchChipText[idx]` |
| ❹ | 참여자 이름 | `Text` | `textStyleBody` 16sp / w500 | `kDutchTextPrimary` |
| ❹ | 참여자 금액 | `Text` | `textStyleValue` 16sp / w600 | `kDutchTextPrimary` |
| ❹ | 빈 상태 | `Text` | `textStyleBody` 16sp | `kDutchTextTertiary` |

> 합계→구분선: 8dp / 구분선→참여자: 8dp / 참여자 maxHeight: 88 / 참여자 행 간격: v:3

### 공유 버튼 (_ShareResultBtn)

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❹ | 컨테이너 | `Container` | height:48 / radius:16 | 그라디언트: `#F48FB1`→`kDutchAccent` |
| ❹ | 그림자 | `BoxShadow` | — | `kDutchAccent` 30% / blur:12 / offset:(0,4) |
| ❹ | 아이콘 | `Icon(share_outlined)` | `sizeIconSmall` 20 | `Colors.white` |
| ❹ | "결과 공유" | `Text` | `textStyleValue` 16sp / w600 | `Colors.white` |

---

## ❺ 스크롤 페이드

탭 0(균등 분배)에서만 사용. 하단 도달 시 (8px 이내) 페이드 비표시.

| 속성 | 값 |
|------|----|
| 위젯 | `ScrollFadeView` (공통 위젯) |
| 높이 | 48 |
| 그라디언트 | `kDutchBg3` 0% → 70% → 100% |
| stops | `[0.0, 0.6, 1.0]` |
| 패딩 | `fromLTRB(16, 8, 16, 16)` |

---

## ❻ 구분선

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❻ | 구분선 | `Divider` | thickness:0.5 / height:1 | `kDutchDivider` |

---

## ❼ 키패드 (`DutchPayKeypad`) — 탭 0 전용

**레이아웃**: 4행 × 3열

```
┌─────────┬─────────┬─────────┐
│    7    │    8    │    9    │
├─────────┼─────────┼─────────┤
│    4    │    5    │    6    │
├─────────┼─────────┼─────────┤
│    1    │    2    │    3    │
├─────────┼─────────┼─────────┤
│   00    │    0    │    ⌫   │
└─────────┴─────────┴─────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| ❼ | 컨테이너 배경 | `Container` | — | `kDutchBg1` 98% / 상단 border: `kDutchDivider` |
| ❼ | 0~9 · 00 | `Text` | `textStyleKeypadNumber` 22sp / w400 | `kDutchTextPrimary` |
| ❼ | ⌫ | `Icon(backspace_outlined)` | `sizeKeypadBackspace` 26 | `kDutchTextSecondary` |
| ❼ | 버튼 높이 | `SizedBox` | — | 58 |
| ❼ | 스플래시 | `InkWell` | — | `kDutchAccent` 8% |

---

## 메뉴 입력 시트 (`_MenuInputSheet`)

메뉴 추가 또는 편집 시 표시되는 바텀 시트.

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| — | 시트 배경 | — | radius: top `radiusBottomSheet` 20 | `Colors.white` |
| — | 핸들 | `Container` | w:36 h:4 / radius:2 | `kDutchDivider` |
| — | 제목 ("메뉴 추가"/"메뉴 수정") | `Text` | `textStyleSheetTitle` 18sp / w600 | `kDutchTextPrimary` |
| — | 입력 필드 컨테이너 | `Container` | padding: h:12 v:8 / radius:12 | `kDutchInputBg` |
| — | 입력 텍스트 | `TextField` | `textStyleBody` 16sp | `kDutchTextPrimary` |
| — | 힌트 텍스트 | — | — | `kDutchTextTertiary` |
| — | 참여자 선택 | `ParticipantChip` | showSelectIndicator: true | 인덱스별 순환 색상 |
| — | 삭제 버튼 (편집 시) | `Container` | height:48 / radius:16 | bg: `Colors.red.shade50` / border: `Colors.red.shade200` |
| — | 삭제 텍스트 | `Text` | `textStyleValue` 16sp / w600 | `Colors.red.shade400` |
| — | 확인 버튼 | `AnimatedContainer` (150ms) | height:48 / radius:16 | 활성: 그라디언트 `#F48FB1`→`kDutchAccent` / 비활성: `kDutchDivider` |
| — | 확인 텍스트 | `Text` | `textStyleValue` 16sp / w600 | 활성: `Colors.white` / 비활성: `kDutchTextTertiary` |

> 입력 필드 비율: 이름 flex:3 / 금액 flex:2 / 필드 간격: 8dp

---

## 영수증 공유 시트 (`ShareSheet`)

영수증 스타일 이미지를 생성하여 공유.

```
┌──────────────────────────────────┐
│  ╔════════════════════════════╗  │
│  ║  CalcMate                  ║  │  ← 스캘럽 상단
│  ║  더치페이                   ║  │
│  ║  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  ║  │  ← 점선
│  ║  총 금액      45,000원    ║  │
│  ║  인원              4명    ║  │
│  ║  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  ║  │
│  ║  1인당        11,250원    ║  │  ← 강조
│  ║                            ║  │
│  ║          2026.03.07        ║  │
│  ╚════════════════════════════╝  │  ← 스캘럽 하단
│                                  │
│  ┌──── 공유하기 ─────────────┐  │
│  └────────────────────────────┘  │
│            닫기                   │
└──────────────────────────────────┘
```

| # | 영역 | 위젯 | 폰트 | 색상 |
|---|------|------|------|------|
| — | 영수증 배경 | `ClipPath` (스캘럽) | padding: 24→32 | `kDutchReceiptBg` |
| — | 스캘럽 반경 | `_ReceiptClipper` | radius:5 / gap:6 | — |
| — | "CalcMate" | `Text` | 13sp / w700 / letterSpacing:1.5 (인라인) | `kDutchAccent` |
| — | "더치페이" | `Text` | 18sp / w700 (인라인) | `kDutchTextPrimary` |
| — | 점선 | `_DashedPainter` | strokeWidth:1 / dash:6 / space:4 | `kDutchReceiptDash` |
| — | 행 라벨 | `Text` | 13sp (인라인) | `kDutchTextSecondary` |
| — | 행 값 | `Text` | 13sp / w500 (인라인) | `kDutchTextPrimary` |
| — | 강조 행 값 | `Text` | 13sp / w700 (인라인) | `kDutchAccent` |
| — | 개별 메뉴명 | `Text` | 11sp (인라인) | `kDutchTextTertiary` |
| — | 날짜 | `Text` | 12sp (인라인) | `kDutchTextTertiary` |
| — | "공유하기" 버튼 | `AnimatedContainer` (200ms) | height:52 / radius:16 | 그라디언트: `#F48FB1`→`kDutchAccent` |
| — | "닫기" | `Text` | `textStyleBody` 16sp / w400 | `kDutchTextTertiary` |

> 이미지 내보내기: `pixelRatio: 3.0` / `Share.shareXFiles`

---

## 간격 요약

| 위치 | 값 |
|------|----|
| 화면 수평 패딩 | `paddingScreenH` 16 |
| 탭바 하단 여백 | 12 |
| 금액 카드 내부 패딩 | h:20 v:14 |
| 카드 간 간격 (1/N) | 14 |
| 결과 카드 내부 패딩 | 20 |
| 참여자 바 패딩 | h:16 v:10 |
| 메뉴 항목 패딩 | h:16 v:12 |
| 결과 섹션 패딩 | fromLTRB(16, 12, 16, 12) |
| 키패드 버튼 높이 | 58 |
| 공유 버튼 높이 (1/N) | 52 |
| 공유 버튼 높이 (각자) | 48 |
| 스크롤 페이드 높이 | 48 |

---

## 애니메이션

| 대상 | 시간 | 곡선 |
|------|------|------|
| PageView 전환 | 300ms | `easeInOut` |
| 탭바 칩·언더라인 | pageOffset 실시간 | 좌: `easeInCubic` / 우: `easeOutCubic` |
| 탭 레이블 스케일 | pageOffset 실시간 | 선형 보간 |
| 인원 ± 버튼 | 150ms | `AnimatedContainer` |
| 팁 칩 선택 | 150ms | `AnimatedContainer` |
| 참여자 칩 | 150ms | `AnimatedContainer` |
| 공유 버튼 투명도 | 200ms | `AnimatedOpacity` |
| 확인/공유 버튼 | 150ms / 200ms | `AnimatedContainer` |

---

## 참여자 칩 색상 (10색 순환)

| idx | 이름 | 배경 (`kDutchChipBg`) | 텍스트 (`kDutchChipText`) |
|-----|------|-----------------------|---------------------------|
| 0 | A | `#FFBBCB` 핑크 | `#AA1E48` 다크 핑크 |
| 1 | B | `#D0AAFF` 라벤더 | `#5820AA` 딥 퍼플 |
| 2 | C | `#AAEACC` 민트 | `#1A6040` 포레스트 |
| 3 | D | `#FFCFAA` 피치 | `#884000` 번트 오렌지 |
| 4 | E | `#B2DFFF` 스카이 | `#185080` 네이비 |
| 5 | F | `#FFEEAA` 레몬 | `#706000` 올리브 |
| 6 | G | `#FFAACC` 로즈 | `#AA2055` 크림슨 |
| 7 | H | `#CCF2B0` 라임 | `#286010` 다크 라임 |
| 8 | I | `#FFBBAA` 살구 | `#882010` 러스트 |
| 9 | J | `#B0CCFF` 코발트 | `#183880` 다크 코발트 |

---

## 색상 팔레트

| 상수 | hex / 값 | 용도 |
|------|---------|------|
| `kDutchBg1` | `#FFF0F8` | 배경 그라디언트 좌상 (라이트 핑크) · 키패드 배경 |
| `kDutchBg2` | `#F5E8FF` | 배경 그라디언트 중간 (라벤더) |
| `kDutchBg3` | `#EEE4FF` | 배경 그라디언트 우하 (바이올렛) · 스크롤 페이드 색상 |
| `kDutchAccent` | `#E8547A` | 주요 강조 (결과, 탭, 버튼, 칩 선택) |
| `kDutchTextPrimary` | `#3D0B1E` | 주 텍스트 (딥 버건디) |
| `kDutchTextSecondary` | `#8B4060` | 보조 텍스트 (뮤트 로즈) |
| `kDutchTextTertiary` | `#BB7A99` | 3차 텍스트 (소프트 모브) |
| `kDutchDivider` | `#EEC4D4` | 구분선 (소프트 핑크) |
| `kDutchCardBg` | `#FFEEF4` | 카드 배경 (라이트 핑크) |
| `kDutchInputBg` | `#FFE0EE` | 입력 필드 배경 (로즈 틴트) |
| `kDutchReceiptBg` | `#FFFBFC` | 영수증 배경 (니어 화이트) |
| `kDutchReceiptDash` | `#E0B0C4` | 영수증 점선 |
| 공유 버튼 그라디언트 시작 | `#F48FB1` | 핑크 (인라인, 상수 아님) |
