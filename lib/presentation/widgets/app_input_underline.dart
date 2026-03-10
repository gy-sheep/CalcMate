import 'package:flutter/material.dart';

enum InputUnderlineStyle {
  /// 부모 너비 전체에 걸쳐 밑줄을 그린다.
  full,

  /// 자식 텍스트 너비만큼만 밑줄을 그린다.
  textWidth,

  /// 밑줄을 표시하지 않는다.
  none,
}

/// 키패드 입력 영역을 시각적으로 표시하는 밑줄 위젯.
///
/// [style]에 따라 전체 너비([InputUnderlineStyle.full]) 또는
/// 텍스트 너비([InputUnderlineStyle.textWidth])로 밑줄을 표시한다.
/// 색상은 각 화면의 테마에 따라 [color]로 주입한다.
class AppInputUnderline extends StatelessWidget {
  final Widget child;
  final InputUnderlineStyle style;
  final Color color;
  final double thickness;

  const AppInputUnderline({
    super.key,
    required this.child,
    this.style = InputUnderlineStyle.full,
    required this.color,
    this.thickness = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    if (style == InputUnderlineStyle.none) return child;

    final underline = Container(height: thickness, color: color);

    if (style == InputUnderlineStyle.textWidth) {
      return IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [child, underline],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [child, underline],
    );
  }
}
