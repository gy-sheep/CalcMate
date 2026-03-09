import 'package:flutter/material.dart';

import '_loan_calc_helper.dart';
import 'prototype_a_screen.dart';
import 'prototype_b_screen.dart';
import 'prototype_c_screen.dart';
import 'prototype_d_screen.dart';

class LoanPrototypeHub extends StatelessWidget {
  const LoanPrototypeHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLoanBgTop,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: kLoanBgTop,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          '대출 계산기',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kLoanBgTop, kLoanBgBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'UI 안(案) 비교',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '4가지 화면 구성을 확인하고 최종 방향을 결정합니다.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _PrototypeCard(
                        label: '안 A',
                        title: '표준 입력형',
                        description: '조건 입력 → 결과 확인.\n익숙한 계산기 흐름.',
                        color: const Color(0xFF1E3A5F),
                        accentColor: const Color(0xFF4A90D9),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PrototypeAScreen()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PrototypeCard(
                        label: '안 B',
                        title: '결과 우선형',
                        description: '진입 즉시 결과 노출.\n슬라이더로 조건 탐색.',
                        color: const Color(0xFF1A3B2E),
                        accentColor: const Color(0xFF4CAF7D),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PrototypeBScreen()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PrototypeCard(
                        label: '안 C',
                        title: '타임라인형',
                        description: '대출 여정을 바 차트로 시각화.\n"30년이 어떤 의미인지" 체감.',
                        color: const Color(0xFF3B2A1A),
                        accentColor: const Color(0xFFFF9800),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PrototypeCScreen()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PrototypeCard(
                        label: '안 D',
                        title: '목표 역산형',
                        description: '"월 얼마 낼 수 있어?" 에서 시작.\n최대 대출 가능금액을 역산.',
                        color: const Color(0xFF2E1A3B),
                        accentColor: const Color(0xFFAB47BC),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PrototypeDScreen()),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrototypeCard extends StatelessWidget {
  final String label;
  final String title;
  final String description;
  final Color color;
  final Color accentColor;
  final VoidCallback onTap;

  const _PrototypeCard({
    required this.label,
    required this.title,
    required this.description,
    required this.color,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.4),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
