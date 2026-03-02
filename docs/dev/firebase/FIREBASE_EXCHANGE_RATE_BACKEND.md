# Firebase 서버리스 백엔드 — 환율 캐싱 시스템 구현 명세

> **분류**: Firebase 서버리스 백엔드
> **목적**: Firebase Blaze 플랜 기반으로 환율 캐싱 레이어를 구축한다. Open Exchange Rates API를 통해 1시간마다 환율을 갱신하고, Firestore를 캐시 저장소로 사용하여 앱 사용자 수에 무관하게 API 호출을 최소화한다.
> **관련 문서**: [`EXCHANGE_RATE_CALCULATOR.md`](../EXCHANGE_RATE_CALCULATOR.md) — Flutter 앱 측 환율 계산기 구현 명세. 본 문서의 Firebase 백엔드를 데이터 소스로 사용한다.

---

## 문서 읽는 순서

```
1. 본 문서 (FIREBASE_EXCHANGE_RATE_BACKEND.md)
   → Firebase 백엔드 환경 구축 + Function 배포까지 완료

2. EXCHANGE_RATE_CALCULATOR.md
   → Flutter 앱에서 Firebase 연동 + 환율 계산기 UI 구현
```

---

## 0. 개발 환경 및 배포

셋업, 빌드, 배포 절차는 [`FIREBASE_GUIDE.md`](FIREBASE_GUIDE.md) 참고.

---

## 1. 전략 개요

### 배경

| 요구사항 | 해결 방식 |
|---------|----------|
| 1시간마다 환율 갱신 | Open Exchange Rates (무료 1,000회/월, Hourly 업데이트) |
| 사용자 수 증가에도 API 한도 초과 방지 | Firestore 캐싱 (앱이 Firestore를 직접 읽기) |
| 서버 구축/관리 없이 구현 | Firebase Spark 플랜 (서버리스) |
| 완전 무료 | Spark 플랜 무료 한도 내 운영 |

### 의사 결정 기록 (ADR)

#### ADR-1: 왜 Open Exchange Rates인가?

무료 + 1시간 갱신 + 충분한 호출 한도를 동시에 만족하는 유일한 API.

| API | 무료 갱신 주기 | 월 한도 | TTL 1시간 가능 |
|-----|-------------|--------|--------------|
| Frankfurter | 일 1회 | 무제한 | ❌ 데이터 일 1회만 변경 |
| fawazahmed0 | 일 1회 | 무제한 (CDN) | ❌ 데이터 일 1회만 변경 |
| 한국수출입은행 | 영업일 1회 | 1,000/일 | ❌ 데이터 영업일 1회만 변경 |
| CurrencyFreaks | 일 1회 (무료) | 1,000/월 | ❌ 무료는 일 1회 |
| ExchangeRatesAPI | 일 1회 (무료) | 100/월 | ❌ 한도 부족 |
| **Open Exchange Rates** | **1시간** | **1,000/월** | **✅ (720회/월 사용)** |

**제약사항**: 무료 플랜은 USD 기준 통화 고정. 앱에서 교차환율 계산으로 해결 (A→B = rates[B]/rates[A]).

#### ADR-2: 왜 구조 B (Firestore 직접 읽기)인가?

| 비교 | 구조 A (매번 Function) | **구조 B (Firestore 직접 읽기)** |
|-----|---------------------|---------------------------|
| Function 실행/일 | DAU 수만큼 | **~24회** |
| Firestore 읽기/일 | DAU 수만큼 | DAU 수만큼 |
| 병목 | Function 한도 | Firestore 50,000읽기/일 |
| 최대 무료 DAU | ~66,000 | **~50,000** |

구조 A는 사용자가 늘수록 Function 실행 횟수가 비례 증가하여 한도 초과 위험이 있다.
구조 B는 Function 호출을 TTL 만료 시에만 한정하여, Function 한도를 사실상 소모하지 않는다.

#### ADR-3: 왜 Spark 플랜인가?

| 비교 | Spark (무료) | Blaze (종량제) |
|-----|------------|--------------|
| 비용 | $0 | 한도 내 $0 (초과 시 과금) |
| 신용카드 | 불필요 | 필요 |
| Cloud Functions | ✅ (무료 할당량 내) | ✅ |
| HTTP 트리거 | ✅ | ✅ |
| 외부 HTTP 요청 | ✅ | ✅ |
| Cloud Scheduler | ❌ | ✅ |

Blaze 플랜으로 전환하여 Cloud Scheduler를 도입했다. `scheduledExchangeRateRefresh` 함수가 매 정각(`0 * * * *`) 자동으로 실행되어 Firestore 환율 데이터를 갱신한다. 앱 요청 기반 온디맨드 갱신(`refreshExchangeRates`)은 수동 테스트용으로 유지한다.

#### ADR-4: 왜 교차환율 계산은 앱에서 하는가?

| | 앱에서 계산 | Firebase에서 계산 |
|-|-----------|----------------|
| 연산 | 나눗셈 1회 (무시 가능) | 동일 |
| 통화 전환 시 | 즉시 (네트워크 없음) | Function 재호출 필요 |
| Firestore 문서 크기 | 168개 환율 (~2KB) | 168 x 168 = 28,224쌍 |
| 오프라인 | 캐시만으로 모든 쌍 변환 가능 | 사전 계산된 쌍만 가능 |

USD 기준 데이터 1세트만 있으면 168개 통화 간 모든 조합을 클라이언트에서 즉시 계산 가능.

### 아키텍처 (구조 B: Firestore 직접 읽기)

```
[Cloud Scheduler] ──── 매 정각 ────► [scheduledExchangeRateRefresh]
                                              │
                                              ├── Open Exchange Rates API 호출
                                              │     GET https://openexchangerates.org/api/latest.json?app_id={APP_ID}
                                              │
                                              └── Firestore 문서 업데이트 (exchange_rates/latest)


[Flutter 앱]
     │
     ├── 1. 로컬 캐시 확인 (SharedPreferences, TTL 1시간)
     │       → 유효 → 캐시 데이터 사용
     │
     └── 2. 캐시 만료 → Firestore 직접 읽기 (exchange_rates/latest)
                              → Cloud Scheduler가 최신 데이터 유지 보장
```

---

## 2. Firebase 플랜 및 비용 분석

### Spark 플랜 (무료) 기능 범위

| 기능 | 가능 여부 | 비고 |
|-----|----------|-----|
| Cloud Functions 배포 | ✅ | 무료 할당량 내에서 가능 |
| HTTP 트리거 Function | ✅ | 본 프로젝트에서 사용하는 방식 |
| 외부 HTTP 요청 (fetch) | ✅ | Open Exchange Rates API 호출에 필요 |
| Firestore 읽기/쓰기 | ✅ | 앱의 환율 데이터 조회에 사용 |
| Cloud Scheduler (스케줄 함수) | ❌ | ✅ (Blaze 전환 완료) |

### 무료 한도 vs 예상 사용량

| 항목 | Spark 무료 한도 | 예상 사용량 | 여유 |
|-----|--------------|----------|-----|
| Functions 실행 | 2,000,000회/월 | ~720회/월 (TTL 만료 트리거) | 99.96% 여유 |
| Firestore 읽기 | 50,000회/일 | DAU 수만큼 | 5만 DAU까지 무료 |
| Firestore 쓰기 | 20,000회/일 | ~24회/일 | 99.88% 여유 |
| Firestore 저장 | 1 GiB | ~1 KB (단일 문서) | 무제한급 여유 |
| Open Exchange Rates | 1,000회/월 | ~720회/월 | 280회 여유 |

### 비용 결론

**$0** — 모든 사용량이 무료 한도 내. 신용카드 등록 불필요 (Spark 플랜).

---

## 3. 외부 API 스펙

### Open Exchange Rates (Forever Free)

| 항목 | 값 |
|-----|-----|
| 가입 | https://openexchangerates.org/signup/free (신용카드 불필요) |
| 엔드포인트 | `https://openexchangerates.org/api/latest.json` |
| 인증 | Query Parameter `app_id` |
| 기준 통화 | USD 고정 (무료 플랜 제약) |
| 갱신 주기 | 1시간마다 |
| 월 호출 한도 | 1,000회 |
| 지원 통화 | 168개 |
| HTTPS | ✅ |
| 주말/공휴일 | 금요일 마감 환율 유지 (Forex 시장 24/5 운영) |

**요청 예시**

```
GET https://openexchangerates.org/api/latest.json?app_id=YOUR_APP_ID
```

**응답 예시**

```json
{
  "disclaimer": "Usage subject to terms: https://openexchangerates.org/terms",
  "license": "https://openexchangerates.org/license",
  "timestamp": 1709308800,
  "base": "USD",
  "rates": {
    "KRW": 1320.45,
    "JPY": 150.23,
    "EUR": 0.9215,
    "GBP": 0.7892,
    "CNY": 7.1985
  }
}
```

**교차환율 계산**: 앱 클라이언트에서 수행 (ADR-4 참고). 상세 공식은 [`EXCHANGE_RATE_CALCULATOR.md`](../EXCHANGE_RATE_CALCULATOR.md)의 "핵심 설계: 교차환율 계산" 참고.

---

## 4. Firestore 설계

### 컬렉션 구조

```
exchange_rates/                    # 컬렉션
└── latest                         # 문서 (단일)
    ├── base: "USD"                # String — 기준 통화 (항상 USD)
    ├── rates: {                   # Map<String, Number> — USD 대비 각 통화 환율
    │     "KRW": 1320.45,
    │     "JPY": 150.23,
    │     "EUR": 0.9215,
    │     ...
    │   }
    ├── timestamp: 1709308800000   # Number (Unix ms) — 마지막 갱신 시각
    ├── source: "open_exchange_rates"  # String — 데이터 출처
    └── refreshing: false          # Boolean — Double Check Lock 플래그
```

### 보안 규칙

아래 내용을 `firestore.rules` 파일에 작성한다:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // exchange_rates 컬렉션: 앱에서 읽기만 허용, 쓰기는 Function만 허용
    match /exchange_rates/{document} {
      allow read: if true;
      allow write: if false;  // Function은 Admin SDK로 우회하므로 이 규칙에 영향받지 않음
    }

    // 그 외 모든 컬렉션: 기본 차단
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

- **읽기**: 모든 클라이언트 허용 (환율은 공개 데이터)
- **쓰기**: 클라이언트 차단. Firebase Function은 Admin SDK를 사용하므로 보안 규칙을 우회하여 쓰기 가능

---

## 5. Firebase Function 구현 명세

### 함수 개요

| 항목 | 값 |
|-----|-----|
| 함수 이름 | `refreshExchangeRates` |
| 트리거 | HTTP (onRequest) |
| 런타임 | Node.js 20 |
| 리전 | asia-northeast3 (서울) |
| 메모리 | 256 MB |
| 타임아웃 | 30초 |

### Double Check Locking 로직

TTL 만료 시 여러 앱이 동시에 Function을 호출할 수 있다. Firestore Transaction을 이용해 단일 요청만 외부 API를 호출하도록 보장한다.

```
refreshExchangeRates 호출
│
├── 1. Firestore Transaction 시작
│     └─ exchange_rates/latest 문서 읽기
│
├── 2. TTL 확인 (timestamp + 1시간 < 현재)
│     ├─ 유효 → 현재 데이터 그대로 반환 (API 미호출)
│     └─ 만료 → 3단계
│
├── 3. refreshing 플래그 확인
│     ├─ true → 다른 요청이 갱신 중 → 현재 데이터 반환 (대기)
│     └─ false → refreshing = true로 설정 → 4단계
│
├── 4. Open Exchange Rates API 호출
│     └─ GET /api/latest.json?app_id={APP_ID}
│
├── 5. Firestore 문서 업데이트
│     ├─ rates: 새 환율 데이터
│     ├─ timestamp: 현재 시각 (Unix ms)
│     └─ refreshing: false
│
└── 6. 갱신된 데이터 JSON 응답
```

### Function 코드 구조

```
functions/
├── src/
│   └── index.ts               # refreshExchangeRates 함수 (이 파일만 직접 작성)
├── package.json               # 의존성 (아래에서 수정 필요)
├── tsconfig.json              # TypeScript 설정 (자동 생성, 수정 불필요)
└── .env                       # 환경 변수 (직접 생성)
```

### Step 1: 의존성 확인

`firebase init`으로 자동 생성된 `functions/package.json`에 이미 필요한 의존성이 포함되어 있다.
아래 항목이 있는지 확인한다:

```json
{
  "dependencies": {
    "firebase-admin": "^12.x.x",
    "firebase-functions": "^6.x.x"
  }
}
```

> `node-fetch`는 별도 설치 불필요. Node.js 20은 전역 `fetch`를 기본 내장하고 있다.

### Step 2: 환경 변수 설정

[`FIREBASE_GUIDE.md`](FIREBASE_GUIDE.md) 1-5 참고. `functions/.env`에 `OXR_APP_ID`를 설정한다.

### Step 3: index.ts 작성 (배포 가능한 완성 코드)

`functions/src/index.ts` 파일의 전체 내용을 아래로 교체한다:

```typescript
/**
 * CalcMate — 환율 캐싱 Firebase Function
 *
 * 역할:
 *   앱에서 TTL 만료 시 호출되어 Open Exchange Rates API로부터
 *   최신 환율을 가져와 Firestore에 캐싱한다.
 *
 * 호출 방식:
 *   GET https://asia-northeast3-{PROJECT_ID}.cloudfunctions.net/refreshExchangeRates
 *
 * Double Check Locking:
 *   여러 앱이 동시에 호출해도 Firestore Transaction으로
 *   단 한 번만 외부 API를 호출하도록 보장한다.
 */

import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { onRequest } from "firebase-functions/v2/https";
import { defineString } from "firebase-functions/params";

// Firebase Admin 초기화
initializeApp();

// 환경 변수
const OXR_APP_ID = defineString("OXR_APP_ID");

// 상수
const TTL_MS = 3_600_000; // 1시간 (밀리초)
const DOC_PATH = "exchange_rates/latest";
const OXR_URL = "https://openexchangerates.org/api/latest.json";

/**
 * refreshExchangeRates
 *
 * 1. Firestore에서 현재 환율 문서를 읽는다
 * 2. TTL이 유효하면 그대로 반환한다 (API 미호출)
 * 3. TTL이 만료되었으면 Double Check Locking으로 단일 요청만 API를 호출한다
 * 4. 갱신된 환율을 Firestore에 저장하고 반환한다
 */
export const refreshExchangeRates = onRequest(
  {
    region: "asia-northeast3",  // 서울 리전
    memory: "256MiB",
    timeoutSeconds: 30,
    cors: true,                 // Flutter 웹 빌드 대비 CORS 허용
  },
  async (req, res) => {
    const db = getFirestore();
    const docRef = db.doc(DOC_PATH);

    try {
      // ── Phase 1: Transaction으로 TTL + Double Check Lock 확인 ──
      const cachedData = await db.runTransaction(async (tx) => {
        const doc = await tx.get(docRef);
        const data = doc.data();

        // 문서가 존재하고 TTL 유효 → 현재 데이터 반환 (API 미호출)
        if (data && (Date.now() - data.timestamp) < TTL_MS) {
          return data;
        }

        // 다른 요청이 이미 갱신 중 → 현재 데이터 반환 (중복 호출 방지)
        if (data?.refreshing === true) {
          return data;
        }

        // refreshing 플래그 설정 (이 요청이 갱신 담당)
        if (doc.exists) {
          tx.update(docRef, { refreshing: true });
        }

        return null; // null → Transaction 외부에서 API 호출 진행
      });

      // TTL 유효 또는 다른 요청이 갱신 중 → 캐시 데이터 반환
      if (cachedData) {
        res.json({
          base: cachedData.base,
          rates: cachedData.rates,
          timestamp: cachedData.timestamp,
          source: cachedData.source,
          cached: true,
        });
        return;
      }

      // ── Phase 2: Open Exchange Rates API 호출 ──
      const apiRes = await fetch(`${OXR_URL}?app_id=${OXR_APP_ID.value()}`);

      if (!apiRes.ok) {
        throw new Error(`API responded with status ${apiRes.status}`);
      }

      const apiData = await apiRes.json();

      // ── Phase 3: Firestore 업데이트 ──
      const newData = {
        base: apiData.base,           // "USD"
        rates: apiData.rates,         // { KRW: 1320.45, JPY: 150.23, ... }
        timestamp: Date.now(),        // 갱신 시각 (Unix ms)
        source: "open_exchange_rates",
        refreshing: false,            // 갱신 완료
      };

      await docRef.set(newData);

      res.json({
        ...newData,
        cached: false,
      });

    } catch (error) {
      // API 실패 시 refreshing 플래그 해제
      try {
        await docRef.update({ refreshing: false });
      } catch {
        // 문서 자체가 없는 경우 무시
      }

      console.error("Exchange rate refresh failed:", error);
      res.status(500).json({
        error: "Failed to fetch exchange rates",
        message: error instanceof Error ? error.message : "Unknown error",
      });
    }
  }
);
```

### Step 4-5: 빌드, 테스트, 배포

[`FIREBASE_GUIDE.md`](FIREBASE_GUIDE.md) Section 2 참고.

---

## 6. Flutter 앱 연동

> 상세 구현은 [`EXCHANGE_RATE_CALCULATOR.md`](../EXCHANGE_RATE_CALCULATOR.md)에서 다룬다.
> 여기서는 Firebase 연동에 필요한 최소한의 설정만 기술한다.

### 필요 패키지

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^3.x.x
  cloud_firestore: ^5.x.x
```

### FlutterFire 초기화 (Step-by-Step)

```bash
# 1. FlutterFire CLI 설치 (한 번만)
dart pub global activate flutterfire_cli

# 2. Firebase 연동 설정 (CalcMate 루트에서 실행)
flutterfire configure

# 선택:
# → 프로젝트: calcmate-xxxxx
# → 플랫폼: Android, iOS (필요한 것 선택)
#
# 자동 생성: lib/firebase_options.dart
```

```dart
// main.dart에 추가
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: CalcMateApp()));
}
```

### 앱에서의 호출 흐름 (완성 코드)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ExchangeRateRemoteDataSource {
  final FirebaseFirestore _firestore;

  static const _collection = 'exchange_rates';
  static const _document = 'latest';

  ExchangeRateRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Firestore에서 환율 데이터를 읽는다.
  /// Cloud Scheduler가 매 정각 최신 데이터를 유지하므로
  /// 앱에서는 단순히 Firestore를 읽기만 하면 된다.
  Future<ExchangeRateDto?> fetchFromFirestore() async {
    final doc = await _firestore
        .collection(_collection)
        .doc(_document)
        .get();

    if (!doc.exists || doc.data() == null) return null;
    return ExchangeRateDto.fromJson(doc.data()!);
  }
}
```

> **변경 이력**: Cloud Scheduler 도입 이전에는 `triggerRefresh()` 메서드로 앱이 직접 Firebase Function을 호출하여 환율을 갱신했다. Cloud Scheduler가 자동 갱신을 보장하므로 이 로직이 제거되었다.

---

## 7. 구축 및 배포 순서

셋업부터 배포까지의 전체 절차는 [`FIREBASE_GUIDE.md`](FIREBASE_GUIDE.md) 참고.
Flutter 앱 연동은 [`EXCHANGE_RATE_CALCULATOR.md`](../EXCHANGE_RATE_CALCULATOR.md) 참고.

---

## 8. 환경 변수 관리

| 변수 | 위치 | 용도 | Git 포함 |
|-----|-----|-----|---------|
| `OXR_APP_ID` | `functions/.env` | Open Exchange Rates API 키 | ❌ (.gitignore) |
| Firebase Function URL | Flutter 앱 환경 설정 | Function HTTP 엔드포인트 | ✅ (비밀 아님) |
| Firebase 프로젝트 설정 | `lib/firebase_options.dart` | 앱-Firebase 연결 정보 | ✅ (자동 생성) |

**보안 주의**: `OXR_APP_ID`는 Firebase Functions 서버에만 저장한다. Flutter 앱 코드에 포함하지 않는다.

---

## 9. 모니터링 및 장애 대응

### 장애 시나리오

| 시나리오 | 대응 |
|---------|-----|
| Open Exchange Rates API 장애 | Firestore에 마지막 유효 데이터 유지, 앱은 캐시 사용 |
| Firebase Function 오류 | 앱이 Firestore 기존 데이터 사용 (만료되더라도) |
| Firestore 읽기 실패 | SharedPreferences 로컬 캐시 fallback |
| 모든 소스 실패 | 앱에서 "환율 정보를 불러올 수 없습니다" 오류 메시지 |
| Open Exchange Rates 월 한도 초과 | 이미 Firestore에 캐시된 데이터로 운영 (최대 1시간 지연) |
| refreshing 플래그가 true로 고착 | Function 내 catch 블록에서 해제. 만약 해제 실패 시 Firebase Console에서 수동 해제 |

### 트러블슈팅

빌드/배포 관련 트러블슈팅은 [`FIREBASE_GUIDE.md`](FIREBASE_GUIDE.md) Section 3 참고.

**무료 한도 알림**: Firebase Console에서 예산 알림을 설정하여 예상치 못한 사용량 증가를 감지한다.

---

## 10. 범위 외 (향후 작업)

- ~~**Cloud Scheduler 기반 자동 갱신**~~ — ✅ 완료 (Blaze 전환 후 `scheduledExchangeRateRefresh` 도입, 매 정각 자동 갱신)
- **Firestore 오프라인 영속성** — `cloud_firestore`의 내장 오프라인 캐시 활용 검토
- **다중 API 소스** — Open Exchange Rates 장애 시 Frankfurter 등으로 자동 전환
- **환율 히스토리 저장** — Firestore에 일별 환율 기록 저장 (차트 표시용)
- **API 키 로테이션** — Firebase Secret Manager로 키 관리 고도화
