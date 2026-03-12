import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/data_strings.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../vat_calculator_colors.dart';

// ──────────────────────────────────────────
// 세율 참고 Bottom Sheet
// ──────────────────────────────────────────
class TaxRateInfoSheet extends StatelessWidget {
  const TaxRateInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final rates = DataStrings.vatTaxRates(locale);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kVatBg1, kVatBg2],
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
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.vat_label_taxRateRef,
                style: CmSheet.titleText.copyWith(color: Colors.white),
              ),
            ),
          ),
          const Divider(color: kVatDivider, thickness: 0.5, height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: rates.length,
              separatorBuilder: (_, __) => const Divider(
                color: kVatDivider,
                thickness: CmSheet.dividerThickness,
                height: CmSheet.dividerHeight,
              ),
              itemBuilder: (_, index) {
                final (flag, country, taxName, rate) = rates[index];
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
