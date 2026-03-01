# Firebase Functions 개발 환경 셋업 가이드

> **대상**: 다른 컴퓨터에서 CalcMate Firebase Functions를 개발/배포하려는 경우
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

## Firebase Functions 개발 환경 셋업

Firebase Functions 코드를 수정하거나 배포해야 하는 경우 아래 과정을 따른다.

### 1. Node.js 설치

```bash
brew install node
```

설치 확인:
```bash
node --version    # v20.x.x 이상
```

### 2. Firebase CLI 설치

```bash
npm install -g firebase-tools
```

설치 확인:
```bash
firebase --version    # 13.x.x 이상
```

> **PATH 문제 발생 시**: nvm을 사용하는 경우 `~/.zshrc`에 아래가 있는지 확인
> ```bash
> export NVM_DIR="$HOME/.nvm"
> [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
> ```

### 3. Firebase 로그인

```bash
firebase login
```

- 브라우저가 열리면 Google 계정으로 로그인
- 터미널에 `✓ Success! Logged in as xxx@gmail.com` 메시지가 나와야 완료

### 4. Functions 의존성 설치

레포를 clone한 후 `functions/` 디렉토리에서 npm 패키지를 설치한다:

```bash
cd functions
npm install
cd ..
```

> `firebase init`은 **실행하지 않는다.** `firebase.json`, `.firebaserc`, `firestore.rules` 등 설정 파일이 이미 레포에 포함되어 있다.

### 5. 환경 변수 설정

`functions/.env` 파일을 생성한다 (`.gitignore`에 포함되어 있으므로 레포에는 없음):

```bash
# functions/.env
OXR_APP_ID=여기에_Open_Exchange_Rates_APP_ID_입력
```

> APP_ID는 팀원에게 직접 전달받거나, [Open Exchange Rates](https://openexchangerates.org/signup/free)에서 새로 발급받는다.

### 6. 셋업 완료 확인

```bash
# 빌드 테스트
cd functions && npm run build && cd ..

# 에뮬레이터 실행 (Java 필요)
firebase emulators:start

# 다른 터미널에서 테스트
curl http://localhost:5001/calcmate-353ed/asia-northeast3/refreshExchangeRates
```

환율 JSON이 응답되면 셋업 완료.

> **Java 미설치 시**: `brew install openjdk` 후 심링크 설정 필요
> ```bash
> sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
> ```

---

## 셋업 요약 체크리스트

| # | 항목 | 명령어 |
|---|------|--------|
| 1 | Node.js 설치 | `brew install node` |
| 2 | Firebase CLI 설치 | `npm install -g firebase-tools` |
| 3 | Firebase 로그인 | `firebase login` |
| 4 | Functions 의존성 설치 | `cd functions && npm install` |
| 5 | 환경 변수 생성 | `functions/.env` 파일에 `OXR_APP_ID` 입력 |
| 6 | (선택) Java 설치 | `brew install openjdk` — 에뮬레이터 사용 시 필요 |
