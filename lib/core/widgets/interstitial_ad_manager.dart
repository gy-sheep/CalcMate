import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/app_config.dart';

/// 전면 광고 매니저.
/// 앱 전체 기준 1시간에 1회, 첫 번째 화면 진입은 패스.
/// [AppConfig.isPremium]이 true이면 광고를 표시하지 않는다.
class InterstitialAdManager {
  InterstitialAdManager();

  /// Google 공식 테스트 전면 광고 ID
  static const String _testAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  int _screenEntryCount = 0;
  DateTime? _lastShownTime;
  InterstitialAd? _interstitialAd;

  /// 계산기 화면 진입 시 호출.
  /// 광고 표시 조건을 만족하면 토스트 + 전면 광고를 표시한다.
  void onScreenEntry(BuildContext context) {
    _screenEntryCount++;

    if (!_canShow) return;

    _showAdWithToast(context);
  }

  bool get _canShow {
    if (AppConfig.isPremium) return false;
    if (_screenEntryCount <= 1) return false;
    if (_lastShownTime == null) return true;
    return DateTime.now().difference(_lastShownTime!) >=
        const Duration(hours: 1);
  }

  void _showAdWithToast(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('광고가 표시됩니다'),
          duration: Duration(seconds: 1),
        ),
      );

    InterstitialAd.load(
      adUnitId: _testAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
          );
          ad.show();
          _lastShownTime = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          // 로드 실패 시 무시 — 다음 기회에 재시도
        },
      ),
    );
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
