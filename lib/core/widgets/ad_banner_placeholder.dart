import 'package:flutter/material.dart';

import '../config/app_config.dart';

/// 광고 배너 플레이스홀더.
/// 실제 광고 연동 전까지 레이아웃 공간을 예약한다.
/// 연동 시 이 위젯의 build()를 BannerAd 위젯으로 교체한다.
/// [AppConfig.isPremium]이 true이면 높이 0으로 렌더링된다.
class AdBannerPlaceholder extends StatelessWidget {
  const AdBannerPlaceholder({super.key});

  /// Google AdSize.banner 기준 고정 높이
  static const double height = 50.0;

  @override
  Widget build(BuildContext context) {
    if (AppConfig.isPremium) return const SizedBox.shrink();

    return Container(
      height: height,
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
            child: const Text(
              '광고',
              style: TextStyle(
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
