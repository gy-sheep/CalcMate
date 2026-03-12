import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../l10n/app_localizations.dart';
import '../config/app_config.dart';
/// 배너 광고 위젯.
/// 로드 전: 빈 영역 확보. 로드 완료 시 바로 표시.
/// [AppConfig.isPremium]이 true이면 높이 0으로 렌더링된다.
class AdBannerPlaceholder extends StatefulWidget {
  const AdBannerPlaceholder({super.key});

  /// Google AdSize.banner 기준 고정 높이
  static const double height = 50.0;

  /// Google 공식 테스트 배너 광고 ID
  static const String _testAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  State<AdBannerPlaceholder> createState() => _AdBannerPlaceholderState();
}

enum _AdState { loading, loaded, failed }

class _AdBannerPlaceholderState extends State<AdBannerPlaceholder> {
  BannerAd? _bannerAd;
  Widget? _adWidget;
  _AdState _state = _AdState.loading;

  @override
  void initState() {
    super.initState();
    if (!AppConfig.isPremium) {
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdBannerPlaceholder._testAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _adWidget = AdWidget(ad: ad as BannerAd);
              _state = _AdState.loaded;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          if (mounted) setState(() => _state = _AdState.failed);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppConfig.isPremium) return const SizedBox.shrink();

    return SizedBox(
      height: AdBannerPlaceholder.height,
      child: switch (_state) {
        _AdState.loading => const SizedBox.shrink(),
        _AdState.loaded => _adWidget ?? const SizedBox.shrink(),
        _AdState.failed => Container(
            color: const Color(0xFFE8E8E8),
            child: Center(
              child: Text(
                AppLocalizations.of(context).ad_bannerNotAvailable,
                style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
              ),
            ),
          ),
      },
    );
  }
}
