/// 앱 전역 설정 플래그.
/// 개발 중 광고 영역 등 유료/무료 분기 동작을 제어한다.
class AppConfig {
  AppConfig._();

  /// true: 광고 미표시 (개발 중 또는 유료 버전)
  /// false: 광고 표시 (무료 버전)
  static const bool isPremium = false;
}
