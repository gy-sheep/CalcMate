import 'package:flutter/material.dart';

/// 개별 단위 정의.
/// [ratio]가 null이면 특수 변환 대상 (온도, 연비).
class UnitDef {
  final String code;
  final String label;
  final double? ratio;

  const UnitDef({
    required this.code,
    required this.label,
    this.ratio,
  });
}

/// 단위 카테고리 정의.
class UnitCategory {
  final String code;
  final String name;
  final IconData icon;
  final List<UnitDef> units;
  final String defaultCode;

  const UnitCategory({
    required this.code,
    required this.name,
    required this.icon,
    required this.units,
    required this.defaultCode,
  });
}
