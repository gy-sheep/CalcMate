import 'dart:math';

import 'package:flutter/material.dart';

// ── 상환 방식 ─────────────────────────────────────────────────────────
enum RepayType { annuity, equalPrincipal, bullet }

extension RepayTypeLabel on RepayType {
  String get label {
    switch (this) {
      case RepayType.annuity:
        return '원리금균등';
      case RepayType.equalPrincipal:
        return '원금균등';
      case RepayType.bullet:
        return '만기일시';
    }
  }
}

// ── 계산 ──────────────────────────────────────────────────────────────

/// 원리금균등 월 납입금
double calcAnnuityPayment(double principal, double annualRate, int termMonths) {
  if (annualRate <= 0) return principal / termMonths;
  final r = annualRate / 100 / 12;
  final p = pow(1 + r, termMonths).toDouble();
  return principal * r * p / (p - 1);
}

/// 월납입금 → 최대 대출 가능금액 (원리금균등 기준)
double calcMaxLoan(double monthly, double annualRate, int termMonths) {
  if (annualRate <= 0) return monthly * termMonths;
  final r = annualRate / 100 / 12;
  final p = pow(1 + r, termMonths).toDouble();
  return monthly * (p - 1) / (r * p);
}

/// 상환 방식별 첫 달 납입금
double calcFirstPayment(
    double principal, double annualRate, int termMonths, RepayType type) {
  final r = annualRate / 100 / 12;
  switch (type) {
    case RepayType.annuity:
      return calcAnnuityPayment(principal, annualRate, termMonths);
    case RepayType.equalPrincipal:
      return principal / termMonths + principal * r;
    case RepayType.bullet:
      return principal * r;
  }
}

/// 총 상환금
double calcTotalPayment(
    double principal, double annualRate, int termMonths, RepayType type) {
  final r = annualRate / 100 / 12;
  switch (type) {
    case RepayType.annuity:
      return calcAnnuityPayment(principal, annualRate, termMonths) * termMonths;
    case RepayType.equalPrincipal:
      // 첫달 납입금 + 마지막달 납입금 평균 × 기간
      final firstInterest = principal * r;
      final lastInterest = (principal / termMonths) * r;
      return principal + (firstInterest + lastInterest) / 2 * termMonths;
    case RepayType.bullet:
      return principal + principal * r * termMonths;
  }
}

double calcTotalInterest(double principal, double totalPayment) =>
    totalPayment - principal;

// ── 상환 일정 데이터 ────────────────────────────────────────────────────

class AmortizationRow {
  final int month;
  final double payment;
  final double principal;
  final double interest;
  final double balance;

  const AmortizationRow({
    required this.month,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
  });
}

List<AmortizationRow> calcAmortization(
    double principal, double annualRate, int termMonths, RepayType type) {
  final r = annualRate / 100 / 12;
  final rows = <AmortizationRow>[];
  double balance = principal;

  for (int m = 1; m <= termMonths; m++) {
    final interest = balance * r;
    late double principalPaid;
    late double payment;

    switch (type) {
      case RepayType.annuity:
        payment = calcAnnuityPayment(principal, annualRate, termMonths);
        principalPaid = payment - interest;
      case RepayType.equalPrincipal:
        principalPaid = principal / termMonths;
        payment = principalPaid + interest;
      case RepayType.bullet:
        principalPaid = m == termMonths ? principal : 0;
        payment = interest + principalPaid;
    }

    principalPaid = principalPaid.clamp(0, balance);
    balance = (balance - principalPaid).clamp(0, double.infinity);

    rows.add(AmortizationRow(
      month: m,
      payment: payment,
      principal: principalPaid,
      interest: interest,
      balance: balance,
    ));
  }

  return rows;
}

/// 연도별 누적 원금/이자 (차트용)
class YearlyAccum {
  final int year;
  final double cumPrincipal;
  final double cumInterest;

  const YearlyAccum(
      {required this.year,
      required this.cumPrincipal,
      required this.cumInterest});
}

List<YearlyAccum> calcYearlyAccum(
    double principal, double annualRate, int termYears, RepayType type) {
  final rows =
      calcAmortization(principal, annualRate, termYears * 12, type);

  // 5개 구간으로 균등 분할
  final yearMarks = <int>[];
  final step = (termYears / 5).ceil().clamp(1, 100);
  for (int y = step; y < termYears; y += step) {
    yearMarks.add(y);
  }
  yearMarks.add(termYears);

  final result = <YearlyAccum>[];
  double cumP = 0, cumI = 0;

  for (final row in rows) {
    cumP += row.principal;
    cumI += row.interest;

    final yearDone = row.month ~/ 12;
    final isLastMonth = row.month % 12 == 0;
    if (isLastMonth && yearMarks.contains(yearDone)) {
      result.add(YearlyAccum(
          year: yearDone, cumPrincipal: cumP, cumInterest: cumI));
    }
  }

  return result;
}

// ── 숫자 포맷 ──────────────────────────────────────────────────────────

String formatWon(double amount) {
  final n = amount.round();
  final isNeg = n < 0;
  final str = n.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
    buf.write(str[i]);
  }
  return '${isNeg ? '-' : ''}₩${buf.toString()}';
}

String shortWon(double amount) {
  if (amount >= 1e8) {
    final eok = (amount / 1e8);
    final man = ((amount % 1e8) / 1e4).round();
    if (man == 0) return '${eok.toInt()}억';
    return '${eok.toInt()}억 ${man}만'; // ignore: unnecessary_brace_in_string_interps
  }
  if (amount >= 1e4) {
    return '${(amount / 1e4).round()}만';
  }
  return amount.toInt().toString();
}

// ── 색상 ──────────────────────────────────────────────────────────────

const kLoanBgTop = Color(0xFF0A1628);
const kLoanBgBottom = Color(0xFF162035);
const kLoanPrincipalColor = Color(0xFF4A90D9);
const kLoanInterestColor = Color(0xFFFF7043);
const kLoanAccent = Color(0xFF7BB8E8);
const kLoanCardBg = Color(0x14FFFFFF);
const kLoanDivider = Color(0x1FFFFFFF);
