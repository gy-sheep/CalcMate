import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../vat_calculator_colors.dart';

// ──────────────────────────────────────────
// 세율 참고 Bottom Sheet
// ──────────────────────────────────────────
class TaxRateInfoSheet extends StatelessWidget {
  const TaxRateInfoSheet({super.key});

  static const _rates = [
    ('KR', '대한민국', '부가가치세', '10%'),
    ('JP', '일본', '소비세 (일반)', '10%'),
    ('JP', '일본', '소비세 (경감세율)', '8%'),
    ('GB', '영국', 'VAT (표준)', '20%'),
    ('GB', '영국', 'VAT (경감)', '5%'),
    ('DE', '독일', 'VAT (표준)', '19%'),
    ('DE', '독일', 'VAT (경감)', '7%'),
    ('FR', '프랑스', 'VAT (표준)', '20%'),
    ('IT', '이탈리아', 'VAT (표준)', '22%'),
    ('ES', '스페인', 'VAT (표준)', '21%'),
    ('AU', '호주', 'GST', '10%'),
    ('CA', '캐나다', 'GST', '5%'),
    ('NZ', '뉴질랜드', 'GST', '15%'),
    ('SG', '싱가포르', 'GST', '9%'),
    ('IN', '인도', 'GST (표준)', '18%'),
    ('CN', '중국', 'VAT (일반)', '13%'),
    ('BR', '브라질', 'ICMS (일반)', '17%'),
    ('US', '미국', 'Sales Tax', '주마다 상이'),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(CmSheet.radius)),
      ),
      height: MediaQuery.of(context).size.height * CmSheet.listHeightRatio,
      child: Column(
        children: [
          Container(
            width: CmSheet.handleWidth,
            height: CmSheet.handleHeight,
            margin: const EdgeInsets.only(
              top: CmSheet.handleTopSpacing,
              bottom: CmSheet.handleBottomSpacing,
            ),
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(CmSheet.handleRadius),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '세율 참고',
              style: CmSheet.titleText.copyWith(color: Colors.white),
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
                thickness: CmSheet.dividerThickness,
                height: CmSheet.dividerHeight,
              ),
              itemBuilder: (_, index) {
                final (flag, country, taxName, rate) = _rates[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      CountryFlag.fromCountryCode(
                        flag,
                        theme: const ImageTheme(
                          width: CmFlag.medium,
                          height: CmFlag.medium,
                          shape: Circle(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              country,
                              style: CmSheet.itemTitle.copyWith(color: Colors.white),
                            ),
                            Text(
                              taxName,
                              style: CmSheet.itemSubtext.copyWith(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        rate,
                        style: textStyle16.copyWith(color: Colors.white),
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
