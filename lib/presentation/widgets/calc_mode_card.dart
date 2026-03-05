import 'package:flutter/material.dart';

class CalcModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String imagePath;
  final VoidCallback? onTap;
  final Widget? trailingOverride;

  const CalcModeCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.imagePath,
    this.onTap,
    this.trailingOverride,
  });

  Widget _buildImage() {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(color: Colors.blueGrey),
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
          Positioned.fill(
            child: _buildImage(),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0x99000000),
                    Color(0x33000000),
                  ],
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(offset: Offset(-1.5, -1.5), color: Colors.black26),
                                Shadow(offset: Offset( 1.5, -1.5), color: Colors.black26),
                                Shadow(offset: Offset(-1.5,  1.5), color: Colors.black26),
                                Shadow(offset: Offset( 1.5,  1.5), color: Colors.black26),
                              ],
                            ),
                          ),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    trailingOverride ?? CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.white.withValues(alpha: 0.8),
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
