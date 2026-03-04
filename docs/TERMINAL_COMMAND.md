## 연결된 모든 기기에서 실행
```terminal
flutter run -d all
```

## xcode open
```
open ios/Runner.xcworkspace/
```

## 1. Clean Build(iPhone 빌드 안될때)
```
flutter clean && flutter pub get && cd ios && rm -rf Pods Podfile.lock && pod install
```
