## 연결된 모든 기기에서 실행
```terminal
flutter run -d all
```

## xcode open
```
open ios/Runner.xcworkspace/
```

## Clean Build(iPhone 빌드 안될때)
```
flutter clean && flutter pub get && cd ios && rm -rf Pods Podfile.lock && pod install
```


## 릴리즈 빌드 명령어는
```
flutter build ios --release
```
