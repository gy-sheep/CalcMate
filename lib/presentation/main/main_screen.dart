import 'dart:ui';

import 'package:calcmate/presentation/calculator/basic_calculator_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/calc_mode_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 0;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    final calcCards = [
      CalcModeCard(
        title: '기본 계산기',
        description: '사칙연산 및 공학 계산',
        icon: Icons.calculate,
        imagePath: 'assets/images/backgrounds/basic_calculator.png',
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const BasicCalculatorScreen(
                title: '기본 계산기',
                icon: Icons.calculate,
                color: Colors.blue,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child,
            ),
          );
        },
      ),
      CalcModeCard(
        title: '환율 계산기',
        description: '실시간 전 세계 환율 변환',
        icon: Icons.currency_exchange,
        imagePath: 'assets/images/backgrounds/exchange_rate.png',
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const BasicCalculatorScreen(
                title: '환율 계산기',
                icon: Icons.currency_exchange,
                color: Colors.green,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child,
            ),
          );
        },
      ),
      CalcModeCard(
        title: '단위 변환기',
        description: '길이, 무게, 넓이 등 변환',
        icon: Icons.straighten,
        imagePath: 'assets/images/backgrounds/unit_converter.png',
        onTap: () {},
      ),
      CalcModeCard(
        title: '부가세 계산기',
        description: '부가세 포함/별도 계산',
        icon: Icons.receipt_long,
        imagePath: 'assets/images/backgrounds/vat_calculator.png',
        onTap: () {},
      ),
      CalcModeCard(
        title: '나이 계산기',
        description: '만 나이, 띠, 별자리 확인',
        icon: Icons.cake,
        imagePath: 'assets/images/backgrounds/age_calculator.png',
        onTap: () {},
      ),
      CalcModeCard(
        title: '날짜 계산기',
        description: '디데이 및 날짜 간격 계산',
        icon: Icons.calendar_month,
        imagePath: 'assets/images/backgrounds/date_calculator.png',
        onTap: () {},
      ),
      CalcModeCard(
        title: '대출 계산기',
        description: '월납입금 및 총이자 계산',
        icon: Icons.account_balance,
        imagePath: 'assets/images/backgrounds/loan_calculator.png',
        onTap: () {},
      ),
      CalcModeCard(
        title: '실수령액 계산기',
        description: '연봉 기준 세후 실수령액 계산',
        icon: Icons.payments,
        imagePath: 'assets/images/backgrounds/salary_calculator.png',
        onTap: () {},
      ),
      CalcModeCard(
        title: '할인 계산기',
        description: '할인율 적용 최종금액 계산',
        icon: Icons.local_offer,
        imagePath: 'assets/images/backgrounds/discount_calculator.png',
        onTap: () {},
      ),
      CalcModeCard(
        title: '더치페이 계산기',
        description: '인원수별 1/N 금액 계산',
        icon: Icons.group,
        imagePath: 'assets/images/backgrounds/dutch_pay.png',
        onTap: () {},
      ),
      CalcModeCard(
        title: '전월세 계산기',
        description: '전세↔월세 전환 및 보증금 계산',
        icon: Icons.apartment,
        imagePath: 'assets/images/backgrounds/rent_calculator.png',
        onTap: () {},
      ),
      CalcModeCard(
        title: '취득세 계산기',
        description: '매매가 기준 취득세 계산',
        icon: Icons.real_estate_agent,
        imagePath: 'assets/images/backgrounds/acquisition_tax.png',
        onTap: () {},
      ),
      CalcModeCard(
        title: 'BMI 계산기',
        description: '신장·체중 기준 체질량지수 계산',
        icon: Icons.monitor_weight,
        imagePath: 'assets/images/backgrounds/bmi_calculator.png',
        onTap: () {},
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: _isScrolled
                ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: _isScrolled
                  ? Colors.white.withOpacity(0.75)
                  : Theme.of(context).colorScheme.surface,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: const Text('Calcmate'),
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: () {
                      // TODO: 설정 화면으로 이동
                    },
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.only(top: topPadding + 16, bottom: 16),
          itemCount: calcCards.length,
          itemBuilder: (context, index) {
            return calcCards[index];
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16),
        ),
      ),
    );
  }
}
