# Calcmate

> 생활 속 계산, 하나로 해결

---

## ✨ 주요 기능

| 기능 | 설명 |
|------|------|
| 기본 계산기 | 사칙연산 및 공학 계산 |
| 환율 계산기 | 실시간 전 세계 환율 변환 |
| 단위 변환기 | 길이, 무게, 넓이 등 변환 |
| 부가세 계산기 | 부가세 포함/별도 계산 |
| 나이 계산기 | 만 나이, 띠, 별자리 확인 |
| 날짜 계산기 | 디데이 및 날짜 간격 계산 |
| 대출 계산기 | 복리 및 할부 상환 계산 |
| 실수령액 계산기 | 연봉 기준 세금/4대보험 차감 후 월급 계산 |
| 할인 계산기 | 정가 + 할인율 → 최종 금액 계산 |
| 더치페이 계산기 | 금액 + 인원수 → 1인 부담액 계산 |
| 전월세 계산기 | 전세/월세 전환, 보증금 이자 환산 |
| 취득세 계산기 | 부동산 매매가 기준 취득세 산출 |
| BMI 계산기 | 신장/체중 입력 → BMI 및 체중 분류 |

---

## 🚀 아키텍처 및 개발 원칙

이 프로젝트는 깨끗하고 확장 가능하며, 테스트가 용이한 아키텍처를 지향합니다.

### 1. 기술 스택 (Tech Stack)
- **Framework**: Flutter
- **Language**: Dart
- **State Management & DI**: Riverpod
- **Networking**: Dio
- **API Interface**: Retrofit
- **Serialization**: Freezed, json_serializable

### 2. 핵심 패턴 (Core Patterns)

#### **MVVM (Model-View-ViewModel)**
- **View**: Flutter Widget (Stateless/ConsumerWidget)으로 UI를 담당합니다.
- **ViewModel**: Riverpod의 `Notifier`를 사용하여 UI 상태를 관리하고 비즈니스 로직을 연결합니다.
- **Model**: `Entity`와 `DTO`를 통해 데이터를 구조화합니다.

#### **UseCase (Domain Layer)**
- 비즈니스 로직의 최소 단위로, 하나의 명확한 사용자 작업(예: `CalculateResult`, `UpdateExchangeRate`)을 담당합니다.
- Repository 인터페이스를 주입받아 데이터 레이어와 프레젠테이션 레이어를 연결하는 브릿지 역할을 수행합니다.
- 플랫폼이나 프레임워크에 독립적인 순수 Dart 코드로 작성되어 테스트가 용이합니다.

### 3. 개발 원칙 (Principles)
- **클린 아키텍처 (Clean Architecture)**: 관심사를 `Data`, `Domain`, `Presentation` 계층으로 엄격하게 분리합니다.
- **테스트 주도 개발 (TDD)**: 구현에 앞서 단위 테스트 코드를 작성하여 로직을 검증합니다.
- **불변 상태 (Immutable State)**: 상태를 불변 객체로 관리하여 예측 가능한 UI를 유지합니다.
- **사용자 경험 우선 (UI/UX First)**: 직관적이고 사용자 친화적인 인터페이스를 최우선으로 고려합니다.

---

## 📂 프로젝트 구조 (Project Structure)

프로젝트는 다음과 같은 클린 아키텍처 기반의 폴더 구조를 가집니다.

```text
lib/
├── core/              # 공통 유틸리티, 테마, DI 설정 등
│   ├── di/            # Dependency Injection 설정
│   ├── network/       # Network Client (Dio) 설정
│   └── theme/         # 앱 테마 (Color, Typography)
├── data/              # Data Layer: API 통신, 로컬 DB, Repository 구현체
│   ├── api/           # Retrofit 인터페이스
│   ├── models/        # DTO (Data Transfer Object)
│   └── repositories/  # Repository Implementation
├── domain/            # Domain Layer: 비즈니스 로직의 핵심 (순수 Dart)
│   ├── entities/      # 앱 전반에서 사용하는 순수 모델
│   ├── repositories/  # Repository Interface (추상 클래스)
│   └── usecases/      # 특정 비즈니스 로직 단위 (UseCase)
└── presentation/      # Presentation Layer: UI 및 상태 관리 (MVVM)
    ├── main/          # 메인 화면 (계산기)
    ├── exchange/      # 환율 계산기 화면
    └── widgets/       # 공통 UI 컴포넌트
```
