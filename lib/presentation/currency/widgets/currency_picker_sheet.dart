import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/data_strings.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/models/currency_info.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/widgets/app_text_field.dart';
import '../currency_calculator_colors.dart';

class CurrencyPickerSheet extends StatefulWidget {
  final List<CurrencyInfo> currencies;
  final String selectedCode;
  final Set<String> usedCodes;
  final String? fromCode;

  const CurrencyPickerSheet({
    super.key,
    required this.currencies,
    required this.selectedCode,
    required this.usedCodes,
    this.fromCode,
  });

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  String _query = '';
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showCenterToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(radiusInput),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 1), () => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final filtered = widget.currencies
        .where((c) =>
            c.code.toLowerCase().contains(_query.toLowerCase()) ||
            DataStrings.currencyName(c.code, locale).contains(_query))
        .toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kCurrencyBg1, kCurrencyBg2],
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
          Expanded(
            child: Padding(
              padding: CmSheet.padding,
              child: Column(
                children: [
                  AppTextField.search(
                    controller: _controller,
                    hintText: AppLocalizations.of(context).currency_search_hint,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(
                        color: Colors.white24,
                        thickness: CmSheet.dividerThickness,
                        height: CmSheet.dividerHeight,
                      ),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final isSelected = item.code == widget.selectedCode;
                        final isUsed = widget.usedCodes.contains(item.code);
                        return ListTile(
                          leading: CountryFlag.fromCurrencyCode(
                            item.code,
                            theme: const ImageTheme(
                              width: CmFlag.medium,
                              height: CmFlag.medium,
                              shape: Circle(),
                            ),
                          ),
                          title: Text(
                            item.code,
                            style: CmSheet.itemTitle.copyWith(
                              color: isUsed ? Colors.white38 : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            DataStrings.currencyName(item.code, locale),
                            style: textStyleCaption.copyWith(
                              color: isUsed ? Colors.white24 : Colors.white60,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                          onTap: () {
                            if (isUsed) {
                              final l10n = AppLocalizations.of(context);
                              final message = item.code == widget.fromCode
                                  ? l10n.currency_toast_baseCurrency
                                  : l10n.currency_toast_alreadySelected;
                              _showCenterToast(context, message);
                              return;
                            }
                            Navigator.pop(context, item.code);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
