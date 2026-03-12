import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../l10n/app_localizations.dart';
import '../config/app_config.dart';
import '../utils/app_toast.dart';

/// 전면 광고 매니저.
/// 앱 전체 기준 5분에 1회, 첫 번째 화면 진입은 패스.
/// [AppConfig.isPremium]이 true이면 광고를 표시하지 않는다.
class InterstitialAdManager {
  InterstitialAdManager();

  /// Google 공식 테스트 전면 광고 ID
  static const String _testAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  int _screenEntryCount = 0;
  DateTime? _lastShownTime;
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;

  /// 광고가 전면을 덮고 있는 동안 true.
  bool _isAdShowing = false;
  bool get isAdShowing => _isAdShowing;

  /// 광고 표시 중 보류된 토스트 (광고 종료 후 표시).
  BuildContext? _pendingContext;
  String? _pendingToast;
  ToastType _pendingType = ToastType.info;

  /// 다음 전면 광고를 미리 로드한다.
  /// 첫 번째 화면 진입 후 또는 광고 표시 후 호출.
  void preload() {
    if (AppConfig.isPremium) return;
    if (_interstitialAd != null || _isLoading) return;

    _isLoading = true;
    InterstitialAd.load(
      adUnitId: _testAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;
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
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
        },
      ),
    );
  }

  /// 계산기 화면 진입 시 호출.
  /// 광고가 미리 로드되어 있으면 즉시 표시, 없으면 패스.
  void onScreenEntry(BuildContext context) {
    _screenEntryCount++;

    if (!_canShow) {
      // 첫 화면 진입 후 preload 시작
      if (_screenEntryCount == 1) preload();
      return;
    }

    _showAd(context);
  }

  bool get _canShow {
    if (AppConfig.isPremium) return false;
    if (_screenEntryCount <= 1) return false;
    if (_interstitialAd == null) return false;
    if (_lastShownTime == null) return true;
    return DateTime.now().difference(_lastShownTime!) >=
        const Duration(minutes: 5);
  }

  void _showAd(BuildContext context) {
    final ad = _interstitialAd!;
    _interstitialAd = null;

    showAppToast(context, AppLocalizations.of(context).ad_interstitialToast);
    Future.delayed(const Duration(milliseconds: 800), () {
      _isAdShowing = true;
      ad.show();
      _lastShownTime = DateTime.now();
    });
  }

  void _onAdClosed() {
    _isAdShowing = false;
    if (_pendingToast != null && _pendingContext != null) {
      showAppToast(_pendingContext!, _pendingToast!, type: _pendingType);
    }
    _pendingToast = null;
    _pendingContext = null;
    _pendingType = ToastType.info;
    // 다음 광고를 미리 로드
    preload();
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
