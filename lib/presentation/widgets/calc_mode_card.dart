import 'package:flutter/material.dart';

class CalcModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String imagePath;
  final VoidCallback onTap;

  const CalcModeCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.imagePath,
    required this.onTap,
  });

  Widget _buildImage() {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: Colors.blueGrey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 배경 Hero: 이미지가 확장되며 fadeout
          Positioned.fill(
            child: Hero(
              tag: 'calc_bg_$title',
              flightShuttleBuilder: (_, animation, __, ___, ____) {
                return FadeTransition(
                  opacity: Tween<double>(begin: 1.0, end: 0.0).animate(animation),
                  child: _buildImage(),
                );
              },
              child: _buildImage(),
            ),
          ),
          // 그라디언트 오버레이: 이미지 위에 씌워 텍스트 가독성 확보
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0x99000000), // 60% black
                    Color(0x33000000), // 20% black
                  ],
                ),
              ),
            ),
          ),
          // 콘텐츠: 아이콘/텍스트 Hero는 배경 Hero와 형제 관계
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'calc_icon_$title',
                      child: Material(
                        color: Colors.transparent,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: Icon(icon, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
