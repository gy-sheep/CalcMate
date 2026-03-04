import 'package:flutter/material.dart';

import '../../core/theme/app_design_tokens.dart';

/// 앱 공통 세그먼트 컨트롤.
///
/// 2개 이상의 항목 중 하나를 선택하는 토글 위젯.
/// 화면별 색상 테마는 [trackColor], [thumbColor], [activeTextColor],
/// [inactiveTextColor] 파라미터로 주입한다.
///
/// ```dart
/// AppSegmentControl<VatMode>(
///   value: state.mode,
///   segments: const [
///     (VatMode.exclusive, '부가세 별도'),
///     (VatMode.inclusive, '부가세 포함'),
///   ],
///   onChanged: (v) => vm.handleIntent(VatCalculatorIntent.modeChanged(v)),
///   trackColor: Colors.white10,
///   thumbColor: Color(0xFF7C3AED),
/// );
/// ```
class AppSegmentControl<T> extends StatelessWidget {
  const AppSegmentControl({
    super.key,
    required this.value,
    required this.segments,
    required this.onChanged,
    this.trackColor,
    this.thumbColor = Colors.white,
    this.activeTextColor,
    this.inactiveTextColor,
  }) : assert(segments.length >= 2);

  /// 현재 선택된 값
  final T value;

  /// (값, 레이블) 쌍의 목록 (최소 2개)
  final List<(T, String)> segments;

  final ValueChanged<T> onChanged;

  /// 트랙(배경) 색상
  final Color? trackColor;

  /// 선택된 항목의 thumb 색상
  final Color thumbColor;

  /// 선택된 항목의 텍스트 색상 (null이면 thumbColor의 반대 명도 자동 결정)
  final Color? activeTextColor;

  /// 미선택 항목의 텍스트 색상
  final Color? inactiveTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTokens.heightSegment,
      decoration: BoxDecoration(
        color: trackColor ?? Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: segments.map((seg) {
          final isSelected = seg.$1 == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(seg.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isSelected ? thumbColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    seg.$2,
                    style: TextStyle(
                      color: isSelected
                          ? (activeTextColor ?? Colors.black87)
                          : (inactiveTextColor ?? Colors.white60),
                      fontSize: AppTokens.fontSizeBody,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
