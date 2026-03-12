import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/app_config.dart';
import '../utils/app_toast.dart';

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

  /// 광고가 전면을 덮고 있는 동안 true.
  bool _isAdShowing = false;
  bool get isAdShowing => _isAdShowing;

  /// 광고 표시 중 보류된 토스트 (광고 종료 후 표시).
  BuildContext? _pendingContext;
  String? _pendingToast;
  ToastType _pendingType = ToastType.info;

  /// 계산기 화면 진입 시 호출.
  /// 광고 표시 조건을 만족하면 광고를 로드 후 표시한다.
  void onScreenEntry(BuildContext context) {
    _screenEntryCount++;

    if (!_canShow) return;

    _loadAd(context);
  }

  bool get _canShow {
    if (AppConfig.isPremium) return false;
    if (_screenEntryCount <= 1) return false;
    if (_lastShownTime == null) return true;
    return DateTime.now().difference(_lastShownTime!) >=
        const Duration(hours: 1);
  }

  void _loadAd(BuildContext context) {
    InterstitialAd.load(
      adUnitId: _testAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _onAdClosed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _onAdClosed();
            },
          );
          // 토스트 먼저 표시 → 딜레이 후 광고 표시
          showAppToast(context, '광고가 표시됩니다');
          Future.delayed(const Duration(milliseconds: 800), () {
            _isAdShowing = true;
            ad.show();
            _lastShownTime = DateTime.now();
          });
        },
        onAdFailedToLoad: (error) {
          // 로드 실패 — 토스트·카운트 변경 없이 다음 기회에 재시도
        },
      ),
    );
  }

  void _onAdClosed() {
    _isAdShowing = false;
    if (_pendingToast != null && _pendingContext != null) {
      showAppToast(_pendingContext!, _pendingToast!, type: _pendingType);
    }
    _pendingToast = null;
    _pendingContext = null;
    _pendingType = ToastType.info;
  }

  /// 광고 표시 중이면 보류, 아니면 즉시 표시.
  void showToastOrEnqueue(BuildContext context, String message, {ToastType type = ToastType.info}) {
    if (_isAdShowing) {
      _pendingContext = context;
      _pendingToast = message;
      _pendingType = type;
    } else {
      showAppToast(context, message, type: type);
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
