import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/utils/number_formatter.dart';
import '../net_pay_calculator_colors.dart';

/// 급여 직접 입력 키패드 모달.
///
/// [showSalaryKeypad]로 호출하면 바텀시트를 띄우고,
/// 확인 시 [onConfirm]에 입력값을 전달한다.
void showSalaryKeypad(
  BuildContext context, {
  required int initialSalary,
  required ValueChanged<int> onConfirm,
}) {
  String input = initialSalary > 0 ? initialSalary.toString() : '';

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setModal) {
        void append(String digit) {
          setModal(() {
            if (input.length >= 10) return;
            if (input.isEmpty && digit == '0') return;
            input += digit;
          });
        }

        void backspace() {
          setModal(() {
            if (input.isNotEmpty) {
              input = input.substring(0, input.length - 1);
            }
          });
        }

        void confirm() {
          final val = int.tryParse(input) ?? 0;
          onConfirm(val.clamp(0, 9999999999));
          Navigator.pop(ctx);
        }

        String displayText() {
          if (input.isEmpty) return '0 원';
          final n = int.tryParse(input) ?? 0;
          return '${NumberFormatter.addCommas(n.toString())} 원';
        }

        return Container(
          decoration: const BoxDecoration(
            color: kNetPayBgTop,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppTokens.radiusBottomSheet)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                width: AppTokens.widthSheetHandle,
                height: AppTokens.heightSheetHandle,
                margin: const EdgeInsets.only(
                    bottom: AppTokens.spacingSheetHandle),
                decoration: BoxDecoration(
                  color: kNetPayCardBorder,
                  borderRadius:
                      BorderRadius.circular(AppTokens.radiusSheetHandle),
                ),
              ),
              // 입력 표시
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: kNetPayDeductionBg,
                  borderRadius:
                      BorderRadius.circular(AppTokens.radiusInput),
                  border: Border.all(
                      color: kNetPayGold.withValues(alpha: 0.4)),
                ),
                child: Text(
                  displayText(),
                  textAlign: TextAlign.right,
                  style: AppTokens.textStyleResult36
                      .copyWith(color: kNetPayTextPrimary),
                ),
              ),
              const SizedBox(height: 16),
              // 키패드
              ...[
                ['7', '8', '9'],
                ['4', '5', '6'],
                ['1', '2', '3'],
                ['00', '0', '⌫'],
              ].map((row) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: row.map((key) {
                        final isBack = key == '⌫';
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: isBack
                                    ? backspace
                                    : () => append(key),
                                onLongPress: isBack
                                    ? () => setModal(() => input = '')
                                    : null,
                                child: Container(
                                  height: AppTokens.heightButtonMedium,
                                  decoration: BoxDecoration(
                                    color: isBack
                                        ? kNetPayGoldSoft
                                        : kNetPayCardBg,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isBack
                                          ? kNetPayGold.withValues(
                                              alpha: 0.4)
                                          : kNetPayCardBorder,
                                    ),
                                  ),
                                  child: Center(
                                    child: isBack
                                        ? Icon(Icons.backspace_outlined,
                                            color: kNetPayGold,
                                            size: AppTokens
                                                .sizeKeypadBackspace)
                                        : Text(
                                            key,
                                            style: AppTokens
                                                .textStyleKeypadNumber
                                                .copyWith(
                                                    color:
                                                        kNetPayTextPrimary),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )),
              // 확인 버튼
              Padding(
                padding: EdgeInsets.fromLTRB(
                    0, 8, 0, MediaQuery.of(ctx).padding.bottom + 16),
                child: SizedBox(
                  width: double.infinity,
                  height: AppTokens.heightButtonPrimary,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kNetPayAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusInput),
                      ),
                    ),
                    onPressed: confirm,
                    child: Text(
                      '확인',
                      style: AppTokens.textStyleBody.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
