import 'package:flutter/material.dart';

// Black Onyx + Brilliant Silver
const kSalaryBgTop    = Color(0xFF0A0A0F);   // 깊은 블랙
const kSalaryBgBottom = Color(0xFF141420);   // 약간 밝은 블랙

const kSalaryAccent      = Color(0xFFE8ECF2);   // 브릴리언트 실버 (핵심 강조)
const kSalaryAccentSoft  = Color(0x14E8ECF2);
const kSalaryAccentGlow  = Color(0x40E8ECF2);

const kSalaryGold        = Color(0xFFF0F4FF);   // 밝은 실버 화이트 (금액 하이라이트)
const kSalaryGoldSoft    = Color(0x1EF0F4FF);
const kSalaryGoldBorder  = Color(0x40E8ECF2);

const kSalaryCardBg      = Color(0xFF1A1A28);   // 다크 카드
const kSalaryCardBorder  = Color(0xFF2A2A3A);
const kSalaryCardShadow  = Color(0x28000000);

const kSalaryTabDivider  = Color(0xFF7A7A96);
const kSalaryDivider     = Color(0xFF222230);

const kSalaryTextPrimary   = Color(0xFFF0EDE6);   // 아이보리 화이트
const kSalaryTextSecondary = Color(0xFFC8C6D2);   // 미디엄 그레이
const kSalaryTextDisabled  = Color(0xFF4A4A58);

const kSalarySliderTrack   = Color(0xFF2A2A3A);
const kSalarySliderActive  = kSalaryAccent;

const kSalaryResultBg      = Color(0xFF1E1E2C);   // 결과 카드
const kSalaryResultBorder  = Color(0xFF303042);

const kSalaryDeductionBg   = Color(0xFF1A1A28);   // 공제 카드
const kSalaryDeductionLine = Color(0xFF2A2A3A);

/// 카드 공통 그림자
const kSalaryCardBoxShadow = [
  BoxShadow(color: kSalaryCardShadow, blurRadius: 8, offset: Offset(0, 2)),
];
