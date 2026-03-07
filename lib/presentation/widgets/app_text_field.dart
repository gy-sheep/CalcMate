import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_design_tokens.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final Color textColor;
  final Color hintColor;
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;

  const AppTextField({
    super.key,
    required this.controller,
    required this.textColor,
    required this.hintColor,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.focusNode,
    this.inputFormatters,
    this.onChanged,
    this.prefixIcon,
    this.enabledBorder,
    this.focusedBorder,
  });

  /// 검색창 스타일. 외곽선·아이콘·색상은 기본값을 제공하며 필요 시 재정의 가능.
  AppTextField.search({
    Key? key,
    required TextEditingController controller,
    required String hintText,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    Color textColor = Colors.white,
    Color hintColor = Colors.white54,
    Color borderColor = Colors.white30,
    Color focusedBorderColor = Colors.white70,
  }) : this(
          key: key,
          controller: controller,
          hintText: hintText,
          onChanged: onChanged,
          focusNode: focusNode,
          textColor: textColor,
          hintColor: hintColor,
          prefixIcon: Icon(Icons.search, color: hintColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusInput),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusInput),
            borderSide: BorderSide(color: focusedBorderColor),
          ),
        );

  @override
  Widget build(BuildContext context) {
    final hasBorder = enabledBorder != null || focusedBorder != null;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: AppTokens.textStyleBody.copyWith(color: textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTokens.textStyleHint.copyWith(color: hintColor),
        prefixIcon: prefixIcon,
        border: hasBorder ? null : InputBorder.none,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        isDense: !hasBorder,
        contentPadding: hasBorder ? null : EdgeInsets.zero,
      ),
    );
  }
}
