import 'package:flutter/material.dart';

class BasicCalculatorScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const BasicCalculatorScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'calc_icon_$title',
              child: Material(
                color: Colors.transparent,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Hero(
              tag: 'calc_title_$title',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 실제 화면 배경 (이미지 fadeout 후 표시)
          Positioned.fill(
            child: Container(color: color),
          ),
          // 배경 Hero 도착지: 투명 Container (이미지가 fadeout되며 착지)
          Positioned.fill(
            child: Hero(
              tag: 'calc_bg_$title',
              child: Container(),
            ),
          ),
          const Center(
            child: Text(
              '기본 계산기 화면',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}
