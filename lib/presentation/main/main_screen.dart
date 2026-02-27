import 'package:calcmate/presentation/calculator/basic_calculator_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/calc_mode_card.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calcCards = [
      CalcModeCard(
        title: '기본 계산기',
        description: '사칙연산 및 공학 계산',
        icon: Icons.calculate,
        imagePath: 'assets/images/basic_calculator.png',
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
        // imagePath: 'assets/images/exchange_rate.png',
        imagePath: 'assets/images/basic_calculator.jpg',
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
        // imagePath: 'assets/images/unit_converter.jpg',
        imagePath: 'assets/images/basic_calculator.png',
        onTap: () {},
      ),
      CalcModeCard(
        title: '부가세 계산기',
        description: '부가세 포함/별도 계산',
        icon: Icons.receipt_long,
        // imagePath: 'assets/images/vat_calculator.jpg',
        imagePath: 'assets/images/basic_calculator.png',
        onTap: () {},
      ),
      CalcModeCard(
        title: '나이 계산기',
        description: '만 나이, 띠, 별자리 확인',
        icon: Icons.cake,
        // imagePath: 'assets/images/age_calculator.jpg',
        imagePath: 'assets/images/basic_calculator.png',
        onTap: () {},
      ),
      CalcModeCard(
        title: '날짜 계산기',
        description: '디데이 및 날짜 간격 계산',
        icon: Icons.calendar_month,
        // imagePath: 'assets/images/date_calculator.jpg',
        imagePath: 'assets/images/basic_calculator.png',
        onTap: () {},
      ),
    ];

    return Scaffold(
      appBar: AppBar(
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
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
