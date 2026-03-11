import 'package:flutter/material.dart';

// Aged Newsprint — 뉴스프린트 테마
// ── Background ────────────────────────────────────────────────
const kSalaryBgTop    = Color(0xFFF5F0E8);   // aged newsprint
const kSalaryBgBottom = Color(0xFFEDE7DD);   // warm newsprint

// ── Accent ────────────────────────────────────────────────────
const kSalaryAccent      = Color(0xFF1A1A1A);   // ink black
const kSalaryAccentSoft  = Color(0x121A1A1A);
const kSalaryAccentGlow  = Color(0x301A1A1A);

// ── Gold (포인트) ─────────────────────────────────────────────
const kSalaryGold        = Color(0xFF8B6914);   // dark sepia gold
const kSalaryGoldSoft    = Color(0x158B6914);
const kSalaryGoldBorder  = Color(0x308B6914);

// ── Cards ─────────────────────────────────────────────────────
const kSalaryCardBg      = Color(0xFFFCF9F4);   // fresh newsprint
const kSalaryCardBorder  = Color(0xFFD6CEBC);   // aged edge
const kSalaryCardShadow  = Color(0x14000000);

// ── Tab / Divider ─────────────────────────────────────────────
const kSalaryTabDivider  = Color(0xFF9A9288);
const kSalaryDivider     = Color(0xFFD6CEBC);

// ── Text ──────────────────────────────────────────────────────
const kSalaryTextPrimary   = Color(0xFF1A1A1A);   // headline ink
const kSalaryTextSecondary = Color(0xFF4A4540);   // body ink
const kSalaryTextDisabled  = Color(0xFF8A8279);   // faded print

// ── Slider ────────────────────────────────────────────────────
const kSalarySliderTrack   = Color(0xFFD6CEBC);
const kSalarySliderActive  = kSalaryGold;

// ── Result Card ───────────────────────────────────────────────
const kSalaryResultBg      = Color(0xFFF0EBE0);   // column highlight
const kSalaryResultBorder  = Color(0xFFCCC4B4);   // ruled line

// ── Deduction Card ────────────────────────────────────────────
const kSalaryDeductionBg   = Color(0xFFFCF9F4);
const kSalaryDeductionLine = Color(0xFFD6CEBC);

/// 카드 공통 그림자
const kSalaryCardBoxShadow = [
  BoxShadow(color: kSalaryCardShadow, blurRadius: 8, offset: Offset(0, 2)),
];
