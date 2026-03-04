import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../core/widgets/ad_banner_placeholder.dart';
import '../../domain/models/vat_calculator_state.dart';
import '../../domain/usecases/vat_calculate_usecase.dart';
import 'vat_calculator_colors.dart';
import 'vat_calculator_viewmodel.dart';
import 'widgets/receipt_card.dart';
import 'widgets/tax_rate_info_sheet.dart';
import 'widgets/vat_number_pad.dart';

// ──────────────────────────────────────────
// 메인 화면
// ──────────────────────────────────────────
class VatCalculatorScreen extends ConsumerStatefulWidget {
  final String title;

  const VatCalculatorScreen({
    super.key,
    required this.title,
  });

  @override
  ConsumerState<VatCalculatorScreen> createState() =>
      _VatCalculatorScreenState();
}

class _VatCalculatorScreenState extends ConsumerState<VatCalculatorScreen> {
  void _showToast(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 120,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (entry.mounted) entry.remove();
    });
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vatCalculatorViewModelProvider);
    final vm = ref.read(vatCalculatorViewModelProvider.notifier);

    ref.listen(
      vatCalculatorViewModelProvider.select((s) => s.toastMessage),
      (_, next) {
        if (next != null) {
          _showToast(next);
          vm.clearToast();
        }
      },
    );

    final vatResult = vm.vatResult;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppTokens.fontSizeAppBarTitle,
            fontWeight: AppTokens.weightAppBarTitle,
          ),
        ),
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kVatGradientTop, kVatGradientBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ReceiptCard(
                  state: state,
                  vm: vm,
                  vatResult: vatResult,
                  onTaxRateInfoTapped: () => _showTaxRateInfo(context),
                ),
              ),
              const Divider(
                  color: kVatDivider, thickness: 0.5, height: 1),
              VatNumberPad(
                onKeyTap: (key) => vm.handleIntent(
                    VatCalculatorIntent.keyTapped(key)),
              ),
              const AdBannerPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaxRateInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TaxRateInfoSheet(),
    );
  }
}
