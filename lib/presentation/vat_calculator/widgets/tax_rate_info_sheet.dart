import 'package:flutter/material.dart';

import '../vat_calculator_colors.dart';

// ──────────────────────────────────────────
// 세율 참고 Bottom Sheet
// ──────────────────────────────────────────
class TaxRateInfoSheet extends StatelessWidget {
  const TaxRateInfoSheet({super.key});

  static const _rates = [
    ('🇰🇷', '대한민국', '부가가치세', '10%'),
    ('🇯🇵', '일본', '소비세 (일반)', '10%'),
    ('🇯🇵', '일본', '소비세 (경감세율)', '8%'),
    ('🇬🇧', '영국', 'VAT (표준)', '20%'),
    ('🇬🇧', '영국', 'VAT (경감)', '5%'),
    ('🇩🇪', '독일', 'VAT (표준)', '19%'),
    ('🇩🇪', '독일', 'VAT (경감)', '7%'),
    ('🇫🇷', '프랑스', 'VAT (표준)', '20%'),
    ('🇮🇹', '이탈리아', 'VAT (표준)', '22%'),
    ('🇪🇸', '스페인', 'VAT (표준)', '21%'),
    ('🇦🇺', '호주', 'GST', '10%'),
    ('🇨🇦', '캐나다', 'GST', '5%'),
    ('🇳🇿', '뉴질랜드', 'GST', '15%'),
    ('🇸🇬', '싱가포르', 'GST', '9%'),
    ('🇮🇳', '인도', 'GST (표준)', '18%'),
    ('🇨🇳', '중국', 'VAT (일반)', '13%'),
    ('🇧🇷', '브라질', 'ICMS (일반)', '17%'),
    ('🇺🇸', '미국', 'Sales Tax', '주마다 상이'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kVatGradientTop, kVatGradientBottom],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '세율 참고',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.white54, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: kVatDivider, thickness: 0.5, height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: _rates.length,
              separatorBuilder: (_, __) => const Divider(
                color: kVatDivider,
                thickness: 0.3,
                height: 1,
              ),
              itemBuilder: (_, index) {
                final (flag, country, taxName, rate) = _rates[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Text(flag,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              country,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              taxName,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        rate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
