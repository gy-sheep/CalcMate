import 'package:calcmate/core/theme/app_design_tokens.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

class CurrencyCodeButton extends StatelessWidget {
  final String code;
  final VoidCallback onTap;

  const CurrencyCodeButton({
    super.key,
    required this.code,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CountryFlag.fromCurrencyCode(
              code,
              theme: const ImageTheme(
                width: AppTokens.sizeFlagMedium,
                height: AppTokens.sizeFlagMedium,
                shape: Circle(),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              code,
              style: AppTokens.textStyleLabelMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
