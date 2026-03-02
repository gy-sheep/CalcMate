# Firebase 셋업 및 배포 가이드

> **대상**: CalcMate Firebase Functions를 개발/배포하려는 경우
> **전제**: Flutter 개발 환경은 이미 구축되어 있다고 가정

---

## 앱 실행만 하는 경우

Firebase Functions 관련 설정이 **필요 없다.** 레포를 clone 후 아래만 실행하면 된다:

```bash
flutter pub get
flutter run
```

`firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`이 이미 레포에 포함되어 있으므로 추가 설정 없이 앱이 실행된다.

---

## 1. 개발 환경 셋업

### 1-1. Node.js 설치

```bash
brew install node
node --version    # v20.x.x 이상
```

### 1-2. Firebase CLI 설치

```bash
npm install -g firebase-tools
firebase --version    # 13.x.x 이상
```

> **PATH 문제 발생 시**: nvm을 사용하는 경우 `~/.zshrc`에 아래가 있는지 확인
> ```bash
> export NVM_DIR="$HOME/.nvm"
> [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
> ```

### 1-3. Firebase 로그인

```bash
firebase login
```

- 브라우저가 열리면 Google 계정으로 로그인
- 터미널에 `✓ Success! Logged in as xxx@gmail.com` 메시지가 나와야 완료

### 1-4. Functions 의존성 설치

레포를 clone한 후 `functions/` 디렉토리에서 npm 패키지를 설치한다:

```bash
cd functions
npm install
cd ..
```

> `firebase init`은 **실행하지 않는다.** `firebase.json`, `.firebaserc`, `firestore.rules` 등 설정 파일이 이미 레포에 포함되어 있다.

### 1-5. 환경 변수 설정

`functions/.env` 파일을 생성한다 (`.gitignore`에 포함되어 있으므로 레포에는 없음):

```bash
# functions/.env
OXR_APP_ID=여기에_Open_Exchange_Rates_APP_ID_입력
```

> APP_ID는 팀원에게 직접 전달받거나, [Open Exchange Rates](https://openexchangerates.org/signup/free)에서 새로 발급받는다.

### 셋업 요약 체크리스트

| # | 항목 | 명령어 |
|---|------|--------|
| 1 | Node.js 설치 | `brew install node` |
| 2 | Firebase CLI 설치 | `npm install -g firebase-tools` |
| 3 | Firebase 로그인 | `firebase login` |
| 4 | Functions 의존성 설치 | `cd functions && npm install` |
| 5 | 환경 변수 생성 | `functions/.env` 파일에 `OXR_APP_ID` 입력 |
| 6 | (선택) Java 설치 | `brew install openjdk` — 에뮬레이터 사용 시 필요 |

---

## 2. 빌드 및 배포

### 2-1. 코드 수정

`functions/src/index.ts` 파일을 수정한다.

### 2-2. 빌드 (TypeScript → JavaScript)

```bash
cd functions
npm run build
```

빌드 에러가 있으면 수정 후 다시 빌드한다.

### 2-3. (권장) 로컬 테스트

배포 전에 에뮬레이터로 테스트한다:

```bash
# 프로젝트 루트에서
firebase emulators:start
```

다른 터미널에서:
```bash
curl http://localhost:5001/calcmate-353ed/asia-northeast3/refreshExchangeRates
```

> HTTP 함수(`refreshExchangeRates`)는 에뮬레이터로 테스트 가능. Cloud Scheduler 함수는 에뮬레이터에서 HTTP로 직접 호출할 수 없다.

> **Java 미설치 시**: `brew install openjdk` 후 심링크 설정 필요
> ```bash
> sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
> ```

### 2-4. 배포

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
✓ Function URL (scheduledExchangeRateRefresh): 매 1시간마다 자동 실행 (HTTP URL 없음)
```

### 2-5. 배포 후 검증

**HTTP 함수 테스트** (수동 갱신 / 디버그용):
```bash
curl https://asia-northeast3-calcmate-353ed.cloudfunctions.net/refreshExchangeRates
```

환율 JSON이 정상 응답되면 배포 완료.

**Cloud Scheduler 확인**:
Firebase Console → Functions → 스케줄 탭에서 `scheduledExchangeRateRefresh`가 등록되어 있는지 확인한다. 매 1시간마다 자동으로 실행되어 Firestore의 환율 데이터를 최신으로 유지한다.

Firebase Console에서도 확인 가능:
- [Functions](https://console.firebase.google.com/project/calcmate-353ed/functions) — 함수 상태, 실행 로그
- [Firestore](https://console.firebase.google.com/project/calcmate-353ed/firestore) — `exchange_rates/latest` 문서 데이터

### 배포 요약

```
코드 수정 → npm run build → (에뮬레이터 테스트) → firebase deploy --only functions
```

---

## 3. 트러블슈팅

| 증상 | 원인 | 해결 |
|-----|-----|-----|
| `firebase deploy` 권한 오류 | 로그인 만료 | `firebase login --reauth` |
| 배포 후 404 | 리전 불일치 | URL에 `asia-northeast3`이 포함되어 있는지 확인 |
| Function 응답이 항상 `cached: true` | `refreshing` 플래그 고착 | Firebase Console → Firestore에서 `refreshing`을 `false`로 변경 |
| `npm run build` 타입 에러 | TypeScript 오류 | 에러 메시지 확인 후 코드 수정 |
| API 응답 에러 | APP_ID 문제 | `functions/.env`의 `OXR_APP_ID` 확인 |
| Firestore 읽기 시 권한 오류 | 보안 규칙 미배포 | `firebase deploy --only firestore:rules` |
| 에뮬레이터에서 외부 API 호출 실패 | 네트워크 문제 | 인터넷 연결 확인, `.env` 파일 위치 확인 |
| `npm run build` 타입 오류 | TypeScript 버전 불일치 | `cd functions && npm install` 재실행 |
