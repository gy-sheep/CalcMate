import 'package:flutter/material.dart';

import '../theme/app_design_tokens.dart';
import '../../domain/utils/number_formatter.dart';

/// 숫자 입력 키패드 모달 색상 테마.
class KeypadColors {
  final Color sheetBg;
  final Color handle;
  final Color inputBg;
  final Color inputBorder;
  final Color inputText;
  final Color keyBg;
  final Color keyBorder;
  final Color keyText;
  final Color backKeyBg;
  final Color backKeyBorder;
  final Color backIcon;
  final Color confirmBg;
  final Color confirmText;

  const KeypadColors({
    required this.sheetBg,
    required this.handle,
    required this.inputBg,
    required this.inputBorder,
    required this.inputText,
    required this.keyBg,
    required this.keyBorder,
    required this.keyText,
    required this.backKeyBg,
    required this.backKeyBorder,
    required this.backIcon,
    required this.confirmBg,
    required this.confirmText,
  });
}

/// 공통 숫자 입력 키패드 바텀시트.
///
/// [initialValue]로 초기값을 전달하고, 확인 시 [onConfirm]에 입력값을 반환한다.
void showNumberKeypad(
  BuildContext context, {
  required int initialValue,
  required ValueChanged<int> onConfirm,
  required KeypadColors colors,
  int maxDigits = 10,
  required String confirmLabel,
}) {
  String input = initialValue > 0 ? initialValue.toString() : '';

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setModal) {
        void append(String digit) {
          setModal(() {
            if (input.length >= maxDigits) return;
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
          decoration: BoxDecoration(
            color: colors.sheetBg,
            borderRadius: const BorderRadius.vertical(
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
                  color: colors.handle,
                  borderRadius:
                      BorderRadius.circular(CmSheet.handleRadius),
                ),
              ),
              // 입력 표시
              Container(
                width: double.infinity,
                padding: CmInputCard.padding,
                decoration: BoxDecoration(
                  color: colors.inputBg,
                  borderRadius:
                      BorderRadius.circular(CmInputCard.radius),
                  border: Border.all(color: colors.inputBorder),
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
                            .copyWith(color: colors.inputText),
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
                    padding:
                        const EdgeInsets.only(bottom: CmKeypad.rowSpacing),
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
                                        ? colors.backKeyBg
                                        : colors.keyBg,
                                    borderRadius: BorderRadius.circular(
                                        CmKeypad.buttonRadius),
                                    border: Border.all(
                                      color: isBack
                                          ? colors.backKeyBorder
                                          : colors.keyBorder,
                                    ),
                                  ),
                                  child: Center(
                                    child: isBack
                                        ? Icon(Icons.backspace_outlined,
                                            color: colors.backIcon,
                                            size: keypadBackspaceSize)
                                        : Text(
                                            key,
                                            style: keypadNumberText
                                                .copyWith(
                                                    color: colors.keyText),
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
                    0,
                    CmKeypad.rowSpacing,
                    0,
                    MediaQuery.of(ctx).padding.bottom +
                        CmKeypad.bottomPadding),
                child: SizedBox(
                  width: double.infinity,
                  height: keypadButtonHeightPrimary,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.confirmBg,
                      foregroundColor: colors.confirmText,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(radiusInput),
                      ),
                    ),
                    onPressed: confirm,
                    child: Text(
                      confirmLabel,
                      style: inputFieldInnerLabel.copyWith(
                        color: colors.confirmText,
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
