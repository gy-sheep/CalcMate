import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../l10n/app_localizations.dart';
import '../config/app_config.dart';

/// 배너 광고 위젯.
/// 광고 로드 실패 시 placeholder UI를 표시한다.
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

class _AdBannerPlaceholderState extends State<AdBannerPlaceholder> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

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
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
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

    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        height: AdBannerPlaceholder.height,
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Fallback placeholder
    return Container(
      height: AdBannerPlaceholder.height,
      color: const Color(0xFFE8E8E8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFAAAAAA)),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              AppLocalizations.of(context)!.common_adLabel,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Advertisement',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFAAAAAA),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
