# Calcmate Implementation Roadmap

이 문서는 Calcmate 앱의 실제 구현 단계와 마일스톤을 기록합니다.

---

## 단계 1: UI 프로토타이핑 (UI Prototyping)
- [ ✓ ] **메인 화면 UI**: `presentation/main/main_screen.dart`에 계산기 모드 선택 리스트 레이아웃 작성
- [ ✓ ] **기본 테마 구축**: `core/theme/`에 라이트/다크 모드 색상 팔레트 정의

## 단계 2: 프로젝트 기초 설정 (Foundation)
- [ ] **Dependency 설정**: `pubspec.yaml`에 Riverpod, Dio, Retrofit, Freezed 등 추가 및 `pub get`
- [ ] **DI 인프라**: `core/di/`에 Dio 및 API 클라이언트 Provider 설정
- [ ] **Lint & Analysis**: `analysis_options.yaml` 설정으로 코드 컨벤션 유지

## 단계 3: 기본 계산기 기능 (Basic Calculator)
- [ ✓ ] **화면 이동 (Navigation)**: '기본 계산기' 카드 클릭 시 계산기 화면으로 이동 로직 추가
- [ ] **Presentation (UI)**:
    - [ ] `basic_calculator_screen.dart` 파일 생성 및 기본 레이아웃 작성 (결과창, 버튼 패드)
- [ ] **Domain & Logic**:
    - [ ] **Domain Entity**: 수식과 결과를 담을 `CalculatorEntity` 정의
    - [ ] **Logic 구현**: 수식 파싱 및 계산 로직 (TDD로 진행, `domain/usecases`)
    - [ ] **State Management**: Riverpod `Notifier`를 이용한 계산 상태 관리

## 단계 4: 환율 계산기 기능 (Exchange Rate)
- [ ] **Data Layer**:
    - [ ] Retrofit을 이용한 API 인터페이스 정의 (`data/api`)
    - [ ] JSON 직렬화를 위한 DTO 작성 및 코드 생성 (`data/models`)
    - [ ] Repository 구현체 작성
- [ ] **Domain Layer**: 환율 정보를 가져오고 계산하는 UseCase 작성
- [ ] **Presentation**: 환율 선택 및 입력 UI 구현

## 단계 5: 추가 편의 기능 (Advanced Features)
- [ ] **단위 변환기**: 무게, 길이, 부피 등 변환 로직 및 UI
- [ ] **날짜 계산기**: 디데이, 날짜 차이 계산 기능
- [ ] **대출/이자 계산기**: 복리 및 할부 상환 로직 구현

## 단계 6: 다듬기 및 배포 (Polishing)
- [ ] **로컬 저장소**: `shared_preferences`를 이용한 계산 기록 저장
- [ ] **애니메이션**: 버튼 클릭 피드백 및 화면 전환 효과 추가
- [ ] **아이콘 & 스플래시**: 앱 아이콘 설정 및 Splash Screen 구현
- [ ] **안드로이드/iOS 최적화**: 각 플랫폼별 권한 및 설정 체크
