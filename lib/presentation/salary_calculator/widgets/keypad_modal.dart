import 'package:flutter/material.dart';

import '../../../core/widgets/number_keypad.dart';
import '../salary_calculator_colors.dart';

/// 급여 직접 입력 키패드 모달.
///
/// [showNumberKeypad]의 급여 계산기 전용 래퍼.
void showSalaryKeypad(
  BuildContext context, {
  required int initialSalary,
  required ValueChanged<int> onConfirm,
}) {
  showNumberKeypad(
    context,
    initialValue: 0,
    onConfirm: onConfirm,
    colors: KeypadColors(
      sheetBg: kSalaryBg1,
      handle: kSalaryCardBorder,
      inputBg: kSalaryDeductionBg,
      inputBorder: kSalaryGold.withValues(alpha: 0.4),
      inputText: kSalaryTextPrimary,
      keyBg: kSalaryCardBg,
      keyBorder: kSalaryCardBorder,
      keyText: kSalaryTextPrimary,
      backKeyBg: kSalaryGoldSoft,
      backKeyBorder: kSalaryGold.withValues(alpha: 0.4),
      backIcon: kSalaryGold,
      confirmBg: kSalaryAccent,
      confirmText: kSalaryBg1,
    ),
  );
}
