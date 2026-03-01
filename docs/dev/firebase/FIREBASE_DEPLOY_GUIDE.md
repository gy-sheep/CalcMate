# Firebase Functions 배포 가이드

> **전제**: [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md)의 개발 환경 셋업이 완료된 상태

---

## 코드 수정 후 배포 과정

### 1. 코드 수정

`functions/src/index.ts` 파일을 수정한다.

### 2. 빌드 (TypeScript → JavaScript)

```bash
cd functions
npm run build
```

빌드 에러가 있으면 수정 후 다시 빌드한다.

### 3. (권장) 로컬 테스트

배포 전에 에뮬레이터로 테스트한다:

```bash
# 프로젝트 루트에서
firebase emulators:start
```

다른 터미널에서:
```bash
curl http://localhost:5001/calcmate-353ed/asia-northeast3/refreshExchangeRates
```

### 4. 배포

```bash
# 프로젝트 루트에서 실행

# Functions만 배포
firebase deploy --only functions

# Firestore 보안 규칙만 배포
firebase deploy --only firestore:rules

# 둘 다 배포
firebase deploy --only functions,firestore:rules
```

배포 성공 시 출력:
```
✓ Function URL (refreshExchangeRates(asia-northeast3)):
  https://asia-northeast3-calcmate-353ed.cloudfunctions.net/refreshExchangeRates
```

### 5. 배포 후 검증

```bash
curl https://asia-northeast3-calcmate-353ed.cloudfunctions.net/refreshExchangeRates
```

환율 JSON이 정상 응답되면 배포 완료.

Firebase Console에서도 확인 가능:
- [Functions](https://console.firebase.google.com/project/calcmate-353ed/functions) — 함수 상태, 실행 로그
- [Firestore](https://console.firebase.google.com/project/calcmate-353ed/firestore) — `exchange_rates/latest` 문서 데이터

---

## 배포 요약

```
코드 수정 → npm run build → (에뮬레이터 테스트) → firebase deploy --only functions
```

---

## 트러블슈팅

| 증상 | 원인 | 해결 |
|-----|-----|-----|
| `firebase deploy` 권한 오류 | 로그인 만료 | `firebase login --reauth` |
| 배포 후 404 | 리전 불일치 | URL에 `asia-northeast3`이 포함되어 있는지 확인 |
| Function 응답이 항상 `cached: true` | `refreshing` 플래그 고착 | Firebase Console → Firestore에서 `refreshing`을 `false`로 변경 |
| `npm run build` 타입 에러 | TypeScript 오류 | 에러 메시지 확인 후 코드 수정 |
| API 응답 에러 | APP_ID 문제 | `functions/.env`의 `OXR_APP_ID` 확인 |
