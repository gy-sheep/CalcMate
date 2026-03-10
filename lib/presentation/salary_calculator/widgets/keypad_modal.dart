import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/utils/number_formatter.dart';
import '../salary_calculator_colors.dart';

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

        return Container(
          decoration: const BoxDecoration(
            color: kSalaryBgTop,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(CmSheet.radius)),
          ),
          padding: CmKeypad.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                width: CmSheet.handleWidth,
                height: CmSheet.handleHeight,
                margin: const EdgeInsets.only(
                    bottom: CmSheet.handleBottomSpacing),
                decoration: BoxDecoration(
                  color: kSalaryCardBorder,
                  borderRadius:
                      BorderRadius.circular(CmSheet.handleRadius),
                ),
              ),
              // 입력 표시
              Container(
                width: double.infinity,
                padding: CmInputCard.padding,
                decoration: BoxDecoration(
                  color: kSalaryDeductionBg,
                  borderRadius:
                      BorderRadius.circular(CmInputCard.radius),
                  border: Border.all(
                      color: kSalaryGold.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        input.isEmpty
                            ? '0'
                            : NumberFormatter.addCommas(
                                (int.tryParse(input) ?? 0).toString()),
                        style: CmInputCard.inputText
                            .copyWith(color: kSalaryTextPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CmKeypad.displaySpacing),
              // 키패드
              ...[
                ['7', '8', '9'],
                ['4', '5', '6'],
                ['1', '2', '3'],
                ['00', '0', '⌫'],
              ].map((row) => Padding(
                    padding: const EdgeInsets.only(bottom: CmKeypad.rowSpacing),
                    child: Row(
                      children: row.map((key) {
                        final isBack = key == '⌫';
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: CmKeypad.buttonSpacingH),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                    CmKeypad.buttonRadius),
                                onTap: isBack
                                    ? backspace
                                    : () => append(key),
                                onLongPress: isBack
                                    ? () => setModal(() => input = '')
                                    : null,
                                child: Container(
                                  height: keypadButtonHeightMedium,
                                  decoration: BoxDecoration(
                                    color: isBack
                                        ? kSalaryGoldSoft
                                        : kSalaryCardBg,
                                    borderRadius: BorderRadius.circular(
                                        CmKeypad.buttonRadius),
                                    border: Border.all(
                                      color: isBack
                                          ? kSalaryGold.withValues(
                                              alpha: 0.4)
                                          : kSalaryCardBorder,
                                    ),
                                  ),
                                  child: Center(
                                    child: isBack
                                        ? Icon(Icons.backspace_outlined,
                                            color: kSalaryGold,
                                            size: keypadBackspaceSize)
                                        : Text(
                                            key,
                                            style: keypadNumberText
                                                .copyWith(
                                                    color:
                                                        kSalaryTextPrimary),
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
                    0, CmKeypad.rowSpacing, 0,
                    MediaQuery.of(ctx).padding.bottom + CmKeypad.bottomPadding),
                child: SizedBox(
                  width: double.infinity,
                  height: keypadButtonHeightPrimary,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSalaryAccent,
                      foregroundColor: kSalaryBgTop,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(radiusInput),
                      ),
                    ),
                    onPressed: confirm,
                    child: Text(
                      '확인',
                      style: inputFieldInnerLabel.copyWith(
                        color: kSalaryBgTop,
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
