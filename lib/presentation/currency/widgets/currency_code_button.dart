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
                width: 32,
                height: 32,
                shape: Circle(),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              code,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
