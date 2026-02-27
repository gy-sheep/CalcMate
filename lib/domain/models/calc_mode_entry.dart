import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'calc_mode_entry.freezed.dart';

@freezed
class CalcModeEntry with _$CalcModeEntry {
  const factory CalcModeEntry({
    required String id,
    required String title,
    required String description,
    required IconData icon,
    required String imagePath,
    @Default(true) bool isVisible,
    required int order,
  }) = _CalcModeEntry;
}
